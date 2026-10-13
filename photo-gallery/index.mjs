export async function handler(event) {
  try {
    // BE gửi dữ liệu JSON trong body của request.
    const data = JSON.parse(event.body);
    const status = data.status;

    if (status !== 'success' && status !== 'failed') {
      return {
        statusCode: 400,
        body: 'Status phải là success hoặc failed'
      };
    }

    // Ghi kết quả và thông tin BE gửi kèm vào CloudWatch.
    console.log('PHOTO_UPLOAD', JSON.stringify(data));

    return {
      statusCode: 200,
      body: 'Đã ghi log kết quả upload'
    };
  } catch (error) {
    return {
      statusCode: 400,
      body: 'Body không phải dữ liệu JSON hợp lệ'
    };
  }
}
