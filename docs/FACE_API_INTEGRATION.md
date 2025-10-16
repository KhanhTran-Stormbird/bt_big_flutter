# Tích Hợp Dịch Vụ Nhận Diện Khuôn Mặt (AI)

Tài liệu này mô tả giao diện HTTP tối thiểu để backend (Laravel) kết nối đến dịch vụ AI nhận diện khuôn mặt.

## Cấu hình Backend
- File `backend/config/face.php`
- Biến môi trường trong `backend/.env`:
  - `FACE_PROVIDER=http|stub` (mặc định: `stub` – luôn match để demo)
  - `FACE_API_BASE=http://face_api:8000` (URL base của AI service)
  - `FACE_API_EXTRACT=/extract`
  - `FACE_API_MATCH=/match`
  - `FACE_THRESHOLD=0.6` (ngưỡng khớp – càng nhỏ càng giống, tuỳ vào metric)
  - `FACE_TIMEOUT=10` (giây)

## Các endpoint AI cần có (provider=http)
1) POST `${FACE_API_BASE}${FACE_API_EXTRACT}`
- Mục đích: Trích xuất embedding từ ảnh khuôn mặt
- Request: multipart/form-data
  - `image`: file ảnh khuôn mặt (jpg/png)
- Response (200):
```
{ "embedding": [0.0123, -0.0456, ...] }
```
- Hoặc trả về trực tiếp mảng `[0.0123, ...]`

2) POST `${FACE_API_BASE}${FACE_API_MATCH}`
- Mục đích: Tính độ tương đồng/ khoảng cách giữa 2 embedding
- Request (JSON):
```
{ "source": [..], "target": [..] }
```
- Response (200):
```
{ "distance": 0.37 }
```
- Quy ước: `distance <= FACE_THRESHOLD` → xem là khớp (match)

## Luồng Backend sử dụng
- Ghi danh (Enroll mẫu): `POST /api/v1/face-samples` (multipart `image`)
  - Lưu file vào `storage/app/faces/users/{id}/...`
  - Gọi AI `/extract` để nhận `embedding`
  - Lưu `embedding` vào DB (`face_samples.embedding`)
- Điểm danh bằng khuôn mặt: `POST /api/v1/attendance/check-in` (multipart `image`, kèm `session_token`)
  - Lưu ảnh minh chứng vào `storage/app/checkins/sessions/{sid}/users/{uid}/...`
  - Gọi AI `/extract` cho ảnh mới
  - So sánh với các embedding đã ghi danh của user qua `/match` (chọn khoảng cách nhỏ nhất)
  - Nếu `distance <= FACE_THRESHOLD` → `present`, ngược lại `suspect`

## Gợi ý triển khai dịch vụ AI
- Tuỳ chọn mô hình/engine (FaceNet, ArcFace/InsightFace, v.v.).
- Cần đảm bảo endpoint `/extract` và `/match` theo spec trên.
- Xử lý nhiều khuôn mặt trong 1 ảnh: chọn khuôn mặt lớn nhất/chính giữa, hoặc trả lỗi.
- Chuẩn hoá đầu vào (resize, align) để kết quả ổn định.

## Kiểm thử nhanh (mock)
- Đặt `FACE_PROVIDER=stub` → backend sẽ bỏ qua AI thật và luôn khớp (distance giả lập), phục vụ demo UI.
- Khi AI sẵn sàng: chuyển `FACE_PROVIDER=http` và cập nhật `FACE_API_BASE`.

