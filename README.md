# 🎾 Pickleball Club Management (PCM)

**Sinh viên**: Lê Văn Vượng  
**MSSV**: 1771020771  
**Lớp**: CNTT 17-08

Hệ thống quản lý CLB Pickleball hoàn chỉnh với Backend (ASP.NET Core 8 Web API), Frontend (Flutter Mobile/Web), và Database (SQLite).

---

## 🌐 Live Demo

| Component | URL | Status |
|-----------|-----|--------|
| **Backend API** | https://pcm-backend-771.onrender.com | ✅ Running |
| **Swagger UI** | https://pcm-backend-771.onrender.com/swagger | ✅ Available |
| **Frontend Web** | https://frontend-virid-alpha-10.vercel.app | ✅ Deployed |

---

## 📁 Cấu trúc dự án

```
MOBILE_FLUTTER_1771020771-LE-VAN-VUONG/
├── Backend/              # ASP.NET Core Web API 8.0
│   ├── Controllers/      # 10 API Controllers (incl. AdminController)
│   ├── Models/           # Entity Models (prefix 771_)
│   ├── Data/             # ApplicationDbContext (SQLite) + Seeder
│   ├── DTOs/             # Data Transfer Objects
│   ├── Hubs/             # SignalR Hub cho Real-time features
│   ├── Services/         # Background Services
│   ├── Dockerfile        # Docker configuration
│   └── Program.cs        # Config CORS, JWT, Swagger, DI
├── Frontend/             # Flutter Mobile/Web App
│   ├── lib/
│   │   ├── models/       # Dart models
│   │   ├── providers/    # State management (Provider)
│   │   ├── screens/      # Màn hình chính (Admin, Booking, Wallet...)
│   │   ├── services/     # API Service (Dio) + SignalR Service
│   │   └── widgets/      # Reusable widgets & Charts
│   ├── build/web/        # Flutter web build output
│   ├── vercel.json       # Vercel deployment config
│   └── pubspec.yaml
├── docker-compose.yml    # Docker Compose for local development
├── deploy-docker.bat     # Automated Docker deployment script
└── DEPLOYMENT.md         # Deployment documentation
```

---

## 🛠️ Tech Stack

### Backend
- **Framework**: ASP.NET Core 8 Web API
- **Database**: SQLite (Entity Framework Core Code First)
- **Authentication**: JWT Bearer Tokens
- **Real-time**: SignalR (WebSockets)
- **API Documentation**: Swagger/OpenAPI
- **Deployment**: Docker + Render

### Frontend
- **Framework**: Flutter 3.x (Mobile & Web)
- **State Management**: Provider
- **Networking**: Dio (HTTP Client)
- **Real-time**: SignalR Client
- **Charts**: FL Chart (Admin Dashboard)
- **Storage**: Flutter Secure Storage
- **Deployment**: Vercel

---

## 🚀 Hướng dẫn cài đặt & Chạy

### 1️⃣ Backend API (Local)

```bash
cd Backend

# Restore packages
dotnet restore

# Chạy API
dotnet run
```

✅ API URL: `http://localhost:5050`  
✅ Swagger UI: `http://localhost:5050/swagger`

**Database**: SQLite sẽ tự động được tạo tại `Backend/Pcm771Database.db` khi chạy lần đầu.

### 2️⃣ Frontend Flutter (Local)

**Cấu hình API URL**:
File `Frontend/lib/services/api_service.dart`:
```dart
// For local development
static const String baseUrl = 'http://10.0.2.2:5050/api'; // Android Emulator
// static const String baseUrl = 'http://localhost:5050/api'; // Web/iOS

// For production
static const String baseUrl = 'https://pcm-backend-771.onrender.com/api';
```

**Chạy App**:

```bash
cd Frontend

# Lấy dependencies
flutter pub get

# Chạy trên Chrome (Web)
flutter run -d chrome

# Hoặc chạy trên Android Emulator
flutter run

# Build web
flutter build web --release
```

### 3️⃣ Docker (Local)

```bash
# Build và chạy với Docker Compose
docker-compose up --build

# Hoặc chỉ build image
docker build -t pcm-backend:latest -f Backend/Dockerfile .
```

---

## 🌍 Deployment

### Backend (Render)

1. **Build Docker Image:**
   ```bash
   .\deploy-docker.bat
   ```

2. **Deploy to Render:**
   - Tạo Web Service mới
   - Image: `docker.io/ngocmi/pcm-backend:latest`
   - Port: 10000
   - Environment Variables: JWT settings

Chi tiết: Xem [DEPLOYMENT.md](DEPLOYMENT.md)

### Frontend (Vercel)

1. **Build Flutter Web:**
   ```bash
   cd Frontend
   flutter build web --release
   ```

2. **Deploy to Vercel:**
   ```bash
   vercel --prod --cwd build/web
   ```

Chi tiết: Xem [vercel_deployment_guide.md](.gemini/antigravity/brain/569a67ca-c06d-4dc3-855c-740daee9852c/vercel_deployment_guide.md)

---

## 👤 Tài khoản Demo

Hệ thống đã có sẵn dữ liệu mẫu. Sử dụng các tài khoản sau để đăng nhập:

| Email | Password | Role | Quyền hạn nổi bật |
|-------|----------|------|-------------------|
| `admin@pcm.com` | `Admin@123` | **Admin** | Truy cập **Admin Dashboard**, quản lý toàn bộ hệ thống |
| `treasurer@pcm.com` | `Treasurer@123` | **Treasurer** | Duyệt nạp tiền, xem **Revenue Chart** |
| `referee@pcm.com` | `Referee@123` | **Referee** | Cập nhật kết quả trận đấu |
| `member1@pcm.com` | `Member@123` | **Member** | Đặt sân, tham gia giải đấu, xem ví cá nhân |

*(Có tổng cộng 17 tài khoản Member từ `member1@pcm.com` đến `member17@pcm.com`)*

---

## 📱 Tính năng Chính

### 💼 Admin Dashboard
- **Tổng quan tài chính**: Xem tổng quỹ CLB, doanh thu tháng này
- **Biểu đồ doanh thu**: Chart trực quan theo dõi thu/chi 12 tháng gần nhất
- **Xét duyệt nạp tiền**: Approve/Reject các yêu cầu nạp tiền từ thành viên
- **Thống kê**: Số lượng thành viên theo hạng (Tier), số booking, giải đấu đang mở

### 🏆 Giải đấu & Booking
- **Đặt sân**: Lịch trực quan, chọn giờ trống, thanh toán bằng ví
- **Recurring Booking**: Đặt sân cố định hàng tuần (chỉ dành cho VIP/Diamond)
- **Giải đấu**:
  - Tự động tạo lịch thi đấu (Round Robin / Knockout)
  - Cập nhật tỉ số Real-time
  - Bảng xếp hạng DUPR

### 💰 Quản lý Ví (Wallet)
- **Nạp tiền**: Upload ảnh bằng chứng chuyển khoản
- **Lịch sử**: Xem chi tiết từng giao dịch (Deposit, Payment, Reward, Refund)
- **Hạng thành viên (Tier)**: Tích điểm để lên hạng (Standard → Silver → Gold → Diamond) để nhận ưu đãi giảm giá sân

### 🔔 Real-time & Tiện ích
- **Thông báo**: Nhận thông báo ngay lập tức khi booking được confirm, nạp tiền thành công, hoặc có lịch thi đấu mới
- **Auto Cancel**: Booking chưa thanh toán sẽ tự hủy sau 15 phút
- **Auto Remind**: Gửi email/notification nhắc lịch trước 24h

---

## 🔧 API Endpoints

### Authentication
- `POST /api/auth/login` - Đăng nhập
- `POST /api/auth/register` - Đăng ký
- `GET /api/auth/me` - Lấy thông tin user hiện tại

### Members
- `GET /api/members` - Danh sách thành viên
- `GET /api/members/{id}/profile` - Thông tin chi tiết thành viên
- `PUT /api/members/{id}` - Cập nhật thông tin

### Bookings
- `GET /api/bookings/calendar` - Lịch đặt sân
- `POST /api/bookings` - Đặt sân mới
- `POST /api/bookings/recurring` - Đặt sân định kỳ
- `POST /api/bookings/cancel/{id}` - Hủy booking

### Wallet
- `GET /api/wallet/balance` - Số dư ví
- `GET /api/wallet/transactions` - Lịch sử giao dịch
- `POST /api/wallet/deposit` - Nạp tiền

### Admin
- `GET /api/admin/dashboard/stats` - Thống kê tổng quan
- `GET /api/admin/dashboard/revenue` - Biểu đồ doanh thu
- `GET /api/admin/wallet/pending` - Danh sách nạp tiền chờ duyệt
- `PUT /api/admin/wallet/approve/{id}` - Duyệt nạp tiền

**Xem đầy đủ tại Swagger UI**: https://pcm-backend-771.onrender.com/swagger

---

## 🔧 Xử lý lỗi thường gặp

### Backend

1. **Database not found**:
   - Database SQLite sẽ tự động được tạo khi chạy lần đầu
   - Nếu gặp lỗi, xóa file `Pcm771Database.db` và chạy lại

2. **Port already in use**:
   - Thay đổi port trong `appsettings.json` hoặc dừng process đang dùng port 5050

### Frontend

1. **Connection refused**:
   - Kiểm tra Backend có đang chạy không
   - Đảm bảo dùng đúng URL:
     - Android Emulator: `http://10.0.2.2:5050/api`
     - Web/iOS: `http://localhost:5050/api`
     - Production: `https://pcm-backend-771.onrender.com/api`

2. **CORS Error**:
   - Backend đã được cấu hình cho phép mọi Origin
   - Nếu vẫn lỗi, kiểm tra `Program.cs` phần CORS config

### Deployment

1. **Render backend sleep**:
   - Free tier Render sleep sau 15 phút không dùng
   - Wake-up time: ~30 giây
   - Giải pháp: Upgrade to paid tier hoặc chấp nhận delay

2. **Vercel 404**:
   - Đảm bảo đã build Flutter web: `flutter build web --release`
   - Deploy từ folder `build/web`: `vercel --prod --cwd build/web`

---

## 📚 Tài liệu tham khảo

- [Backend Deployment Guide](DEPLOYMENT.md)
- [Vercel Deployment Guide](.gemini/antigravity/brain/569a67ca-c06d-4dc3-855c-740daee9852c/vercel_deployment_guide.md)
- [Walkthrough](.gemini/antigravity/brain/569a67ca-c06d-4dc3-855c-740daee9852c/walkthrough.md)

---

## 🎓 Thông tin sinh viên

**MSSV**: 1771020771  
**Họ tên**: Lê Văn Vượng  
**Lớp**: CNTT 17-08  
**Năm**: 2026

---

## 📝 License

This project is for educational purposes only.

---

**Made with ❤️ by Lê Văn Vượng**
