package main

import (
	"bytes"
	"context"
	"crypto/rand"
	"crypto/sha256"
	"embed"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"io"
	"log"
	"net/http"
	"net/url"
	"os"
	"sort"
	"strings"
	"time"

	"github.com/aws/aws-sdk-go-v2/aws"
	v4 "github.com/aws/aws-sdk-go-v2/aws/signer/v4"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/feature/dynamodb/attributevalue"
	"github.com/aws/aws-sdk-go-v2/service/dynamodb"
	"github.com/aws/aws-sdk-go-v2/service/dynamodb/types"
	"github.com/aws/aws-sdk-go-v2/service/s3"
)

//go:embed web/index.html
var web embed.FS

const maxImage = 5 << 20

type photo struct {
	ID          string `json:"id" dynamodbav:"id"`
	Title       string `json:"title" dynamodbav:"title"`
	Description string `json:"description" dynamodbav:"description"`
	S3Key       string `json:"s3_key" dynamodbav:"s3_key"`
	CreatedAt   string `json:"created_at" dynamodbav:"created_at"`
	URL         string `json:"url" dynamodbav:"-"`
}
type objectStore interface {
	PutObject(context.Context, *s3.PutObjectInput, ...func(*s3.Options)) (*s3.PutObjectOutput, error)
	DeleteObject(context.Context, *s3.DeleteObjectInput, ...func(*s3.Options)) (*s3.DeleteObjectOutput, error)
}
type metadataStore interface {
	PutItem(context.Context, *dynamodb.PutItemInput, ...func(*dynamodb.Options)) (*dynamodb.PutItemOutput, error)
	Scan(context.Context, *dynamodb.ScanInput, ...func(*dynamodb.Options)) (*dynamodb.ScanOutput, error)
}
type notification struct {
	Email       string `json:"email"`
	Status      string `json:"status"`
	PhotoID     string `json:"photo_id"`
	Title       string `json:"title"`
	Description string `json:"description"`
}
type app struct {
	objects                    objectStore
	metadata                   metadataStore
	bucket, table, cdn, folder string
	notify                     func(context.Context, notification) error
}

// Metadata nhập tay có thể chỉ chứa tên file; metadata do app tạo chứa đầy đủ S3 key.
func (a *app) objectKey(name string) string {
	name = strings.TrimLeft(name, "/")
	if strings.Contains(name, "/") {
		return name // Đã có folder: giữ nguyên, không thêm photos lần nữa.
	}
	folder := strings.Trim(strings.TrimSpace(a.folder), "/")
	if folder == "" {
		folder = "photos"
	}
	return folder + "/" + name
}

func (a *app) photoURL(key string) string {
	path := url.URL{Path: "/" + a.objectKey(key)}
	return strings.TrimRight(a.cdn, "/") + path.EscapedPath()
}

func writeJSON(w http.ResponseWriter, status int, value any) {
	w.Header().Set("Content-Type", "application/json")
	w.Header().Set("Cache-Control", "no-store")
	w.WriteHeader(status)
	_ = json.NewEncoder(w).Encode(value)
}
func (a *app) routes() http.Handler {
	mux := http.NewServeMux()
	mux.HandleFunc("GET /{$}", func(w http.ResponseWriter, r *http.Request) {
		content, _ := web.ReadFile("web/index.html")
		w.Header().Set("Content-Type", "text/html; charset=utf-8")
		_, _ = w.Write(content)
	})
	mux.HandleFunc("GET /healthz", func(w http.ResponseWriter, r *http.Request) { _, _ = w.Write([]byte("ok")) })
	mux.HandleFunc("GET /api/photos", a.list)
	mux.HandleFunc("POST /api/photos", a.upload)
	return mux
}

func (a *app) list(w http.ResponseWriter, r *http.Request) {
	ctx, cancel := context.WithTimeout(r.Context(), 15*time.Second)
	defer cancel()
	photos := []photo{}
	var cursor map[string]types.AttributeValue
	for {
		out, err := a.metadata.Scan(ctx, &dynamodb.ScanInput{TableName: aws.String(a.table), ExclusiveStartKey: cursor, ConsistentRead: aws.Bool(true)})
		if err != nil {
			log.Printf("scan: %v", err)
			writeJSON(w, 502, map[string]string{"error": "Không đọc được metadata. Kiểm tra quyền DynamoDB và tên table."})
			return
		}
		var page []photo
		if err = attributevalue.UnmarshalListOfMaps(out.Items, &page); err != nil {
			writeJSON(w, 502, map[string]string{"error": "Metadata không hợp lệ."})
			return
		}
		photos = append(photos, page...)
		cursor = out.LastEvaluatedKey
		if len(cursor) == 0 {
			break
		}
	}
	for i := range photos {
		photos[i].URL = a.photoURL(photos[i].S3Key)
	}
	sort.Slice(photos, func(i, j int) bool { return photos[i].CreatedAt > photos[j].CreatedAt })
	writeJSON(w, 200, photos)
}

func (a *app) notifyResult(n notification) string {
	// A disconnected browser must not cancel the notification for an upload already saved.
	ctx, cancel := context.WithTimeout(context.Background(), 8*time.Second)
	defer cancel()
	if err := a.notify(ctx, n); err != nil {
		log.Printf("notify photo=%s: %v", n.PhotoID, err)
		return "failed"
	}
	return "accepted"
}
func (a *app) upload(w http.ResponseWriter, r *http.Request) {
	r.Body = http.MaxBytesReader(w, r.Body, maxImage+(1<<20))
	if err := r.ParseMultipartForm(maxImage); err != nil {
		if r.MultipartForm != nil {
			_ = r.MultipartForm.RemoveAll()
		}
		writeJSON(w, 400, map[string]string{"error": "Form không hợp lệ hoặc quá lớn. Ảnh tối đa 5 MiB."})
		return
	}
	defer r.MultipartForm.RemoveAll()
	email := strings.TrimSpace(r.FormValue("email"))
	title := strings.TrimSpace(r.FormValue("title"))
	description := strings.TrimSpace(r.FormValue("description"))
	n := notification{Email: email, Status: "failed", Title: title, Description: description}
	fail := func(status int, message string) {
		result := a.notifyResult(n)
		writeJSON(w, status, map[string]string{"upload": "failed", "notification": result, "error": message})
	}
	if title == "" || len(title) > 200 || len(description) > 1000 {
		fail(400, "Tiêu đề bắt buộc, tối đa 200 byte; mô tả tối đa 1000 byte.")
		return
	}
	file, _, err := r.FormFile("photo")
	if err != nil {
		fail(400, "Chưa chọn ảnh.")
		return
	}
	defer file.Close()
	data, err := io.ReadAll(io.LimitReader(file, maxImage+1))
	if err != nil || len(data) == 0 || len(data) > maxImage {
		fail(400, "Ảnh rỗng, không đọc được hoặc quá 5 MiB.")
		return
	}
	contentType := http.DetectContentType(data)
	ext := map[string]string{"image/jpeg": ".jpg", "image/png": ".png", "image/webp": ".webp"}[contentType]
	if ext == "" {
		fail(400, "Chỉ nhận ảnh JPEG, PNG hoặc WebP.")
		return
	}
	var idBytes [16]byte
	if _, err = rand.Read(idBytes[:]); err != nil {
		fail(500, "Không tạo được ID ảnh.")
		return
	}
	id := hex.EncodeToString(idBytes[:])
	key := a.objectKey(id + ext)
	n.PhotoID = id
	ctx, cancel := context.WithTimeout(r.Context(), 25*time.Second)
	defer cancel()
	_, err = a.objects.PutObject(ctx, &s3.PutObjectInput{Bucket: aws.String(a.bucket), Key: aws.String(key), Body: bytes.NewReader(data), ContentType: aws.String(contentType), CacheControl: aws.String("public,max-age=300")})
	if err != nil {
		log.Printf("put object photo=%s: %v", id, err)
		fail(502, "Không lưu được ảnh lên S3.")
		return
	}
	item := photo{ID: id, Title: title, Description: description, S3Key: key, CreatedAt: time.Now().UTC().Format(time.RFC3339Nano)}
	record, err := attributevalue.MarshalMap(item)
	if err == nil {
		_, err = a.metadata.PutItem(ctx, &dynamodb.PutItemInput{TableName: aws.String(a.table), Item: record})
	}
	if err != nil {
		log.Printf("put metadata photo=%s: %v", id, err)
		cleanupCtx, cleanupCancel := context.WithTimeout(context.Background(), 5*time.Second)
		_, cleanupErr := a.objects.DeleteObject(cleanupCtx, &s3.DeleteObjectInput{Bucket: aws.String(a.bucket), Key: aws.String(key)})
		cleanupCancel()
		if cleanupErr != nil {
			log.Printf("manual cleanup required key=%s: %v", key, cleanupErr)
		}
		fail(502, "Không lưu được metadata; đã thử dọn ảnh vừa upload. Kiểm tra log nếu dọn thất bại.")
		return
	}
	n.Status = "success"
	delivery := a.notifyResult(n)
	item.URL = a.photoURL(item.S3Key)
	// Notification failure does not undo a successful photo upload.
	writeJSON(w, 201, map[string]any{"upload": "success", "notification": delivery, "photo": item})
}

func signedNotifier(cfg aws.Config, endpoint string) func(context.Context, notification) error {
	client := &http.Client{Timeout: 7 * time.Second, CheckRedirect: func(*http.Request, []*http.Request) error { return http.ErrUseLastResponse }}
	return func(ctx context.Context, n notification) error {
		body, err := json.Marshal(n)
		if err != nil {
			return err
		}
		req, err := http.NewRequestWithContext(ctx, "POST", endpoint, bytes.NewReader(body))
		if err != nil {
			return err
		}
		req.Header.Set("Content-Type", "application/json")
		credentials, err := cfg.Credentials.Retrieve(ctx)
		if err != nil {
			return err
		}
		hash := sha256.Sum256(body)
		if err = v4.NewSigner().SignHTTP(ctx, credentials, req, hex.EncodeToString(hash[:]), "execute-api", cfg.Region, time.Now()); err != nil {
			return err
		}
		resp, err := client.Do(req)
		if err != nil {
			return err
		}
		defer resp.Body.Close()
		_, _ = io.Copy(io.Discard, io.LimitReader(resp.Body, 4096))
		if resp.StatusCode != http.StatusOK {
			return fmt.Errorf("notification API HTTP %d", resp.StatusCode)
		}
		return nil
	}
}
func required(name string) string {
	value := strings.TrimSpace(os.Getenv(name))
	if value == "" || strings.Contains(value, "REPLACE") {
		log.Fatalf("Set %s in .env", name)
	}
	return value
}
func main() {
	region := required("AWS_REGION")
	endpoint := required("NOTIFY_URL")
	parsed, err := url.Parse(endpoint)
	if err != nil || parsed.Scheme != "https" || parsed.Host == "" {
		log.Fatal("NOTIFY_URL must be HTTPS")
	}
	cdn := strings.TrimRight(required("CLOUDFRONT_URL"), "/")
	cfg, err := config.LoadDefaultConfig(context.Background(), config.WithRegion(region))
	if err != nil {
		log.Fatal(err)
	}
	a := &app{
		objects:  s3.NewFromConfig(cfg),
		metadata: dynamodb.NewFromConfig(cfg),
		bucket:   required("S3_BUCKET"),
		table:    required("DYNAMODB_TABLE"),
		cdn:      cdn,
		folder:   os.Getenv("S3_FOLDER"),
		notify:   signedNotifier(cfg, endpoint),
	}
	addr := os.Getenv("LISTEN_ADDR")
	if addr == "" {
		addr = "127.0.0.1:8080"
	}
	server := &http.Server{Addr: addr, Handler: a.routes(), ReadHeaderTimeout: 5 * time.Second, ReadTimeout: 35 * time.Second, WriteTimeout: 50 * time.Second, IdleTimeout: 60 * time.Second}
	log.Printf("Photo Gallery listening on %s", addr)
	log.Fatal(server.ListenAndServe())
}
