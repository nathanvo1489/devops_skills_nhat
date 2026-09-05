# Phần lệnh CLI: 8h

## CLI là gì

- CLI là viết tắt của Command Line Interface — giao diện dòng lệnh.
- Thay vì bấm chuột vào nút, menu và cửa sổ, bạn nhập lệnh bằng bàn phím để điều khiển máy tính.
- Mọi ứng dụng phần mềm cài trên Linux thì đều có CLI tool để dùng dòng lệnh sử dụng

## Hỏi tương tác:

> Tại sao phải học CLI

## Linux là gì?

- Linux là kernel — nhân hệ điều hành (chưa phải là hệ điều hành hoàn chỉnh)
- Linux kernel giống như động cơ.
  Ubuntu, Debian và Amazon Linux giống như những chiếc xe hoàn chỉnh:
  - Linux kernel  = Động cơ
  - Ubuntu        = Một mẫu xe hoàn chỉnh
  - Amazon Linux  = Một mẫu xe khác, tối ưu cho AWS
  - Debian        = Một mẫu xe khác

## Cài Ubuntu 26.04 bằng docker

- dùng lệnh trong slide
- đợi các bạn tải xong
- chỉ các cách truy cập terminal của ubuntu mới run
  - dùng exec trong docker desktop
  - dùng terminal/cmd trên máy host:

    ```bash
    docker exec -it ubuntu-demo bash
    ```

  - dùng bên terminus cho đẹp

## Sài câu lệnh CLI:

### `ls` = list

- `ls -l`: xuống dòng cho đẹp
- `ls -a`: hiện thêm các file ẩn
- `ls -la`: vừa xuống dòng vừa hiện các file ẩn (hay dùng)

---

### `cd` = change directory

- Dùng để chuyển sang thư mục khác.
- `cd` hoặc `cd ~` Về thư mục cá nhân của user đó (Desktop/Home)

---

### `pwd` = print working directory

- Dùng để hiển thị đường dẫn thư mục hiện tại.

---

### `mkdir` = make directory

Dùng để tạo thư mục mới.

---

### `rm` = remove

Dùng để xóa file hoặc thư mục.

- `-r` = recursive: xóa thư mục và toàn bộ file, thư mục con bên trong
- `-f` = force: ép xóa, không hỏi xác nhận và thường bỏ qua lỗi file không tồn tại

---

### `cp` = copy

- Copy file: `cp file.txt file-copy.txt`
- Copy thư mục: `cp -r folder-a folder-b`
- `-r` = recursive — copy đệ quy toàn bộ thư mục con và file bên trong.

---

### `mv` = move

dùng để di chuyển hoặc đổi tên file và thư mục.

```bash
mv file.txt /home/ubuntu/project/
```

---

### `find` nghĩa là tìm kiếm.

```bash
cd /
find . -name *.config
```

Nó dùng để tìm file hoặc thư mục theo tên, loại, kích thước, thời gian sửa đổi và nhiều điều kiện khác.

**Cú pháp cơ bản:**

```bash
find <nơi bắt đầu tìm> <điều kiện>
```

---

### `df` = disk free Dùng để xem tổng dung lượng

- `du` = disk usage Dùng để xem một file hoặc thư mục đang chiếm bao nhiêu dung lượng. Nêu không qui định file nào thì sẽ show đệ quy
- `-h` = human-readable, hiển thị dễ đọc như KB, MB, GB.
- thường dùng để theo dõi, tìm file nào đang chiếm nhiều dung lượng

---

### `free -h`

`free -h` dùng để xem tình trạng RAM và swap trên Linux theo định dạng dễ đọc.

- `total`: tổng RAM
- `used`: RAM đang được dùng
- `free`: RAM hoàn toàn chưa dùng
- `buff/cache`: RAM Linux dùng làm cache
- `available`: RAM thực tế còn có thể cấp cho ứng dụng
- `Swap`: vùng ổ đĩa dùng hỗ trợ khi RAM thiếu

---

### `top`, `ps`, `ps aux`

dùng để xem tình trạng hệ thống theo thời gian thực:

- giống taskmanager bên window và Activity Monitor bên mac
- nhấn enter sẽ lặp tức cập nhật
- `a` → process của tất cả user có terminal
- `u` → hiển thị chi tiết theo user, CPU, RAM
- `x` → bao gồm process không gắn với terminal

---

### `sudo`: đòi quyền admin

- bên window sẽ là chuột phải chọn run as administrator

![Mô tả hình](./image1.png)

Hệ thống phân quyền trên Linux chủ yếu dựa trên 3 đối tượng:

- `owner` = chủ sở hữu file/folder
- `group` = một nhóm user được gom chung để cùng nhận một bộ quyền. Group nó chỉ là một danh sách gồm nhiều user để cấp quyền chung.
- `others` = tất cả user còn lại, không phải owner và cũng không thuộc group đó

Và 3 loại quyền:

- `r 4` → read    → đọc file/ liệt kê thư mục
- `w 2` → write   → ghi, sửa
- `x 1` → execute → thực thi (nếu là file đi vào thư mục bằng cd)

```text
- --- ---
```

### Ký tự đầu tiên:

- là dấu `"-"` → file
- là chữ `"d"` → directory
- là chữ `"l"` → symbolic link

### chmod với số

```bash
chmod 700 script.sh
```

`700` → chỉ owner có toàn quyền

```text
r = 4 = 2²
w = 2 = 2¹
x = 1 = 2⁰
```

tính chất mọi tổng của các tập con đều khác nhau.

```text
0
1
2
3 = 2 + 1
4
5 = 4 + 1
6 = 4 + 2
7 = 4 + 2 + 1
```

### chmod với chữ

- `"+"` upsert: có thì update, chưa có thì create
- `"-"` delete: xoá
- `"="` replace: ghi đè toàn bộ

```bash
chmod u+x demo.txt
chmod a-rwx demo.txt
chmod u=rw,g+r,o+r demo.txt
```

- `u` → user
- `g` → group
- `o` → others
- `a` → all

## Thực hành:

```bash
cat > admin.txt  | nhập nội dung | ctrl + D
cat > user.txt  | nhập nội dung | ctrl + D
cat > index.txt  | nhập nội dung | ctrl + D
```

### Owner có toàn quyền, nhóm không có quyền, những user khác chỉ được đọc file

```bash
chmod 704 admin.txt
chmod u=rwx,g=,o=r admin.txt
```

### Owner có quyền đọc và sửa , nhóm có quyền sửa và chạy file, user khác toàn quyền

```bash
chmod 637 user.txt
chmod u=rw,g=wx,o=rwx user.txt
```

### Owner có quyền đọc, nhóm có quyền sửa, user có quyền chạy

```bash
chmod 637 user.txt
chmod u=r,g=w,o=x index.txt
```

```text
-rwx---r-- 1 root root    6 Aug  4 02:28 admin.txt
-r---w---x 1 root root    6 Aug  4 02:30 index.txt
-rw--wxrwx 1 root root    5 Aug  4 02:29 user.txt
```

---

```text
apt update
apt install
```

cài thử docker trên ubuntu trong docker
```text
apt install docker.io
```

```text
apt install vim
```
### Quản lý user

```bash
apt update
apt install adduser

# thêm user
# lệnh này sẽ tạo user và group
adduser devops-a
# New password: 12345
# Retype new password: 12345
# passwd: password updated successfully
# Changing the user information for devops-a
# Enter the new value, or press ENTER for the default
#         Full Name []: ENTER
#         Room Number []: ENTER
#         Work Phone []: ENTER
#         Home Phone []: ENTER
#         Other []: ENTER
# Is the information correct? [Y/n] y

# list các user
vim /etc/passwd

# list các group
vim /etc/group

# đăng nhập bằng user mới tạo
docker exec -it --user devops-a <container_name> bash

# xoá user - phải là root mới xoá được
# khi xoá user sẽ xoá luôn cả group, nhưng không xoá folder của user đó home/devops-a
deluser devops-a

# thêm user vào group sudo để user có quyền dùng sudo
usermod -aG sudo devops-a

git clone https://USERNAME:TOKEN@github.com/OWNER/REPOSITORY.git