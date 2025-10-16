# Phân Công Công Việc – Dự án Quản Lý Điểm Danh bằng Nhận Diện Khuôn Mặt

Tài liệu này phân chia công việc cho 4 thành viên (2 backend, 2 frontend), kèm phạm vi thư mục, nhiệm vụ chi tiết, tiêu chí nghiệm thu, hợp đồng API, quy ước môi trường và các mốc (milestones).

## 1) Tổng Quan & Mục Tiêu

- Xây dựng hệ thống quản lý điểm danh hỗ trợ: lớp học, buổi học, điểm danh bằng QR/ảnh khuôn mặt, báo cáo tổng hợp và xuất Excel/PDF.
- Triển khai JWT Authentication cho API; FE kết nối bằng Dio + Interceptor tự refresh token.

## 2) Cấu Trúc Dự Án

- Backend (Laravel): `backend/`
- Frontend (Flutter): `frontend/`

## 3) Phân Công Theo Thành Viên

### Backend – Văn Quang (Auth, Users, Chính sách quyền)

- Phạm vi thư mục
  - `backend/app/Http/Controllers/Api/V1/AuthController.php`
  - `backend/app/Http/Controllers/Api/V1/UsersController.php`
  - `backend/app/Http/Middleware/JwtMiddleware.php`
  - `backend/app/Policies/*.php`
  - `backend/app/Http/Requests/Auth/*`
  - `backend/config/{auth.php,jwt.php,cors.php}`
  - `backend/routes/api.php`
- Nhiệm vụ
  - Hoàn thiện JWT: `login/refresh/logout/me`, đổi mật khẩu, trả lỗi JSON chuẩn.
  - Thêm FormRequest validate cho đăng nhập và CRUD user.
  - Hoàn thiện UsersController (CRUD) + `UserRepository`, Gate/Policy:
    - Chỉ Admin: index/store/update/destroy.
  - Cấu hình CORS phù hợp FE; rate-limit `throttle:login`; tắt `DEV_AUTH_BYPASS` trên staging/prod.
  - Seed người dùng mẫu (đã có) – kiểm tra tính idempotent.
- Tiêu chí nghiệm thu
  - `POST /api/v1/auth/login` trả `{access_token, token_type, expires_in}`; `refresh` hoạt động; `logout` vô hiệu token.
  - `GET /api/v1/me` trả `{id,name,email,role}` chính xác theo DB.
  - Endpoint `/users/*` kiểm soát quyền theo role.

### Backend – Duy Khánh (Classes, Sessions, Attendance, QR, Reports, Face)

- Phạm vi thư mục
  - `backend/app/Http/Controllers/Api/V1/{ClassesController.php,SessionsController.php,AttendanceController.php,QrController.php,ReportsController.php}`
  - `backend/app/Repositories/*`
  - `backend/app/Services/{QrService.php,FaceService.php}`
  - `backend/app/Helpers/Hmac.php`
  - `backend/app/Policies/{ClassPolicy.php,SessionPolicy.php}`
  - Lưu trữ ảnh: `storage/app/{faces,checkins}/` (đã có disk trong `config/filesystems.php`).
- Nhiệm vụ
  - Classes: CRUD + import danh sách sinh viên (CSV), unique `(class_id, student_id)`.
  - Sessions: CRUD + trạng thái `scheduled/open/closed`, ràng buộc chuyển trạng thái hợp lệ.
  - QR:
    - `QrService`: sinh QR payload `{sid, exp, sig}` (HMAC, Base64Url).
    - `QrController@scan`: xác thực chữ ký/hạn, trả `{session_token}`.
  - Attendance:
    - `check-in` (multipart): xác thực `session_token`, lưu ảnh vào disk `checkins`, trả dữ liệu theo `AttendanceModel`.
    - `history`: lọc theo lớp/sinh viên, phân trang.
  - Reports:
    - Summary; export Excel (maatwebsite/excel) & PDF (barryvdh/dompdf).
  - Face (hiện stub):
    - `FaceService` giao diện + stub; lưu mẫu ảnh vào disk `faces`.
- Tiêu chí nghiệm thu
  - Constraint DB: unique attendance per `(session_id, student_id)`; FK hợp lệ.
  - `POST /api/v1/sessions/{id}/qr` trả `{svg, ttl}`; `POST /api/v1/attendance/scan-qr` trả `{session_token}`.
  - Excel/PDF tải về đúng nội dung, theo bộ lọc.

### Frontend – Tạ Ngọc Hà (Auth, Shell, Routing, Core)

- Phạm vi thư mục
  - `frontend/lib/features/auth/*`
  - `frontend/lib/features/shell/*`
  - `frontend/lib/router.dart`
  - `frontend/lib/core/*` (constants, theme, widgets)
  - `.env`, `.env.production`, `frontend/lib/main.dart`
  - Dịch vụ: `frontend/lib/data/services/{auth_interceptor.dart,secure_store.dart,api_client.dart}`
- Nhiệm vụ
  - Hoàn thiện Login UI/UX: hiển thị SnackBar thành công/thất bại; redirect theo role:
    - admin → `/dashboard/admin`, lecturer → `/dashboard/lecturer`, còn lại → `/dashboard/student`.
  - Lưu token vào `SecureStore`; `AuthInterceptor` tự gắn Bearer & tự refresh 401.
  - Route guard: chưa đăng nhập → `/login`; đã đăng nhập → dashboard đúng vai trò.
  - Xây skeleton dashboard cho Lecturer/Admin; Student dùng `ShellPage` dạng tabs.
  - Quản lý cấu hình bằng `.env` (flutter_dotenv) cho `API_BASE_URL`, `DEV_AUTH_BYPASS`.
- Tiêu chí nghiệm thu
  - Đăng nhập thành công: Snackbar + chuyển trang đúng; thất bại: Snackbar lỗi rõ ràng.
  - Tự refresh token khi 401; Logout xóa token và điều hướng về `/login`.

### Frontend – Gia Khánh (Features & Data Integration)

- Phạm vi thư mục
  - `frontend/lib/features/{classes,sessions,attendance,reports,qr}/`
  - Dữ liệu: `frontend/lib/data/{models,repositories}/`
- Nhiệm vụ
  - Classes:
    - Danh sách + chi tiết (`/classes`, `/classes/{id}`); Admin: tạo/sửa/xoá + import CSV.
  - Sessions:
    - Danh sách theo lớp; tạo; đóng; chi tiết.
    - QR flow: giảng viên sinh QR (`/sessions/{id}/qr`), sinh viên quét (`/scan-qr` → `/capture`).
  - Attendance:
    - Chụp ảnh bằng `camera`, gửi multipart `session_token` + ảnh đến `/attendance/check-in`; trang kết quả; lịch sử có filter.
  - Reports:
    - Trang tổng hợp; nút export Excel/PDF, gọi endpoint tương ứng.
  - Hoàn thiện models/parse; xử lý loading/error; thống nhất UX.
- Tiêu chí nghiệm thu
  - Các trang lấy dữ liệu thực từ API; upload ảnh hoạt động; thông báo lỗi rõ ràng; luồng điều hướng mượt.

## 4) Hợp Đồng API (Tóm tắt)

- Auth
  - `POST /api/v1/auth/login` `{email,password}` → `{access_token,token_type,expires_in}`
  - `POST /api/v1/auth/refresh` → token mới
  - `GET /api/v1/me` → `{id,name,email,role}`
- Users (Admin)
  - `GET|POST|PUT|DELETE /api/v1/users`
- Classes
  - `GET /api/v1/classes` → Danh sách lớp
  - `GET /api/v1/classes/{id}` → Chi tiết lớp
  - `POST|PUT|DELETE /api/v1/classes` (phân quyền phù hợp)
  - `POST /api/v1/classes/{id}/students/import` (CSV)
- Sessions
  - `GET /api/v1/classes/{id}/sessions`
  - `POST /api/v1/classes/{id}/sessions`
  - `GET /api/v1/sessions/{id}`
  - `POST /api/v1/sessions/{id}/close`
- QR
  - `POST /api/v1/sessions/{id}/qr` → `{svg, ttl}`
  - `POST /api/v1/attendance/scan-qr` `{qr_json}` → `{session_token}`
- Attendance
  - `POST /api/v1/attendance/check-in` (multipart `session_token`, `image`) → AttendanceModel
  - `GET /api/v1/attendance/history?class_id=` → danh sách AttendanceModel
- Reports
  - `GET /api/v1/reports/attendance`
  - `GET /api/v1/reports/attendance.xlsx`
  - `GET /api/v1/reports/attendance.pdf`

## 5) Dữ Liệu & Migrations (Tối thiểu)

- users: id, name, email(unique), password(bcrypt), role(enum: student/lecturer/admin), timestamps
- classes: id, name, subject, term, lecturer_id (FK users)
- class_students: id, class_id (FK), student_id (FK), unique(class_id, student_id)
- class_sessions: id, class_id (FK), starts_at, ends_at, status(enum), qr_ttl
- face_samples: id, user_id (FK), path, embedding(json null), quality_score(float null)
- attendances: id, session_id (FK), student_id (FK), status(enum), method(enum: qr/face), checked_at, distance(float null), image_path(string null), unique(session_id, student_id)

## 6) Môi Trường & Chạy Dự Án

- Backend (`backend/`)
  - Docker Compose: `docker-compose.yml` (MySQL + PHP-Nginx)
  - Env chính: `backend/.env`
    - DB: `attendance/attendance/attendance@mysql:3306`
    - JWT: `JWT_SECRET`, `JWT_TTL=15`, `JWT_REFRESH_TTL=10080`
    - CORS: `FRONTEND_URL=http://localhost:5173` (tuỳ môi trường)
  - Lệnh:
    - `docker compose up -d`
    - (tuỳ) `docker compose logs -f app`
    - Migrate/Seed: tự chạy khi khởi động; seed chỉ khi bảng `users` trống.
- Frontend (`frontend/`)
  - Env: `.env` (dev), `.env.production` (prod)
    - `API_BASE_URL=http://localhost:8080/api/v1`
    - `DEV_AUTH_BYPASS=true|false` (đồng bộ với backend nếu muốn bypass)
  - Chạy:
    - `flutter pub get`
    - Web: `flutter run -d chrome`
    - Android emulator: dùng `http://10.0.2.2:8080/api/v1` nếu cần.

## 8) Quy Trình Làm Việc

- Branch theo tính năng: `feat/<module>`, `fix/<bug>`, PR mô tả API/UX liên quan.
- Code review chéo: Dev A ↔ Dev B; Dev C ↔ Dev D.
- Giữ log/commit gọn gàng; test nhanh trước khi mở PR.
