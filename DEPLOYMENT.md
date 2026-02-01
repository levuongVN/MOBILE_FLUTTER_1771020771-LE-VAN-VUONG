# 🚀 Hướng Dẫn Deploy Backend lên Docker Hub và Render

Tài liệu này hướng dẫn chi tiết cách deploy backend PCM (Pickleball Club Management) sử dụng Docker, Docker Hub và Render.

## 📋 Yêu Cầu

- ✅ Docker Desktop đã cài đặt và đang chạy
- ✅ Tài khoản Docker Hub (đăng ký miễn phí tại https://hub.docker.com)
- ✅ Tài khoản Render (đăng ký miễn phí tại https://render.com)
- ✅ Git đã cài đặt (nếu muốn deploy từ GitHub)

---

## 🐳 Phần 1: Build và Test Docker Image Locally

### Bước 1: Kiểm tra Docker

```bash
# Kiểm tra Docker đã cài đặt chưa
docker --version

# Kiểm tra Docker đang chạy
docker ps
```

### Bước 2: Build Docker Image

```bash
# Từ thư mục root của project
cd d:\MOBILE_FLUTTER_1771020771-LE-VAN-VUONG

# Build image (thay YOUR_USERNAME bằng Docker Hub username của bạn)
docker build -t YOUR_USERNAME/pcm-backend:latest -f Backend/Dockerfile .
```

**Lưu ý**: Build có thể mất 2-5 phút lần đầu tiên.

### Bước 3: Test Image Locally

```bash
# Chạy container từ image vừa build
docker run -d -p 10000:10000 --name pcm-backend-test YOUR_USERNAME/pcm-backend:latest

# Kiểm tra container đang chạy
docker ps

# Xem logs
docker logs pcm-backend-test

# Xem logs realtime
docker logs -f pcm-backend-test
```

### Bước 4: Test API

Mở trình duyệt và truy cập:
- **Swagger UI**: http://localhost:10000/swagger
- **Health Check**: http://localhost:10000/swagger/index.html

Test các endpoints:
1. POST `/api/auth/login` - Login với admin account
2. GET `/api/members` - Lấy danh sách members (cần JWT token)

### Bước 5: Dừng và Xóa Container Test

```bash
# Dừng container
docker stop pcm-backend-test

# Xóa container
docker rm pcm-backend-test
```

---

## 🌐 Phần 2: Push Image lên Docker Hub

### Cách 1: Sử dụng Script Tự Động (Khuyến nghị)

```bash
# Chạy script deploy
.\deploy-docker.bat
```

Script sẽ tự động:
1. Yêu cầu nhập Docker Hub username
2. Login vào Docker Hub
3. Build image
4. Push lên Docker Hub

### Cách 2: Manual (Thủ công)

```bash
# 1. Login vào Docker Hub
docker login

# 2. Build image với tag đầy đủ
docker build -t YOUR_USERNAME/pcm-backend:latest -f Backend/Dockerfile .

# 3. Push lên Docker Hub
docker push YOUR_USERNAME/pcm-backend:latest

# 4. (Optional) Tạo thêm tag version
docker tag YOUR_USERNAME/pcm-backend:latest YOUR_USERNAME/pcm-backend:v1.0.0
docker push YOUR_USERNAME/pcm-backend:v1.0.0
```

### Xác Nhận Push Thành Công

1. Truy cập https://hub.docker.com
2. Login vào tài khoản
3. Vào **Repositories** → Tìm `pcm-backend`
4. Kiểm tra tag `latest` đã xuất hiện

---

## ☁️ Phần 3: Deploy lên Render

### Bước 1: Tạo Web Service

1. Truy cập https://render.com và login
2. Click **New +** → **Web Service**
3. Chọn **Deploy an existing image from a registry**

### Bước 2: Cấu Hình Image

- **Image URL**: `docker.io/YOUR_USERNAME/pcm-backend:latest`
  - Ví dụ: `docker.io/johndoe/pcm-backend:latest`
- **Name**: `pcm-backend` (hoặc tên bạn muốn)
- **Region**: Chọn region gần nhất (Singapore cho Việt Nam)
- **Instance Type**: **Free** (cho testing)

### Bước 3: Cấu Hình Environment Variables

Trong phần **Environment**, thêm các biến sau:

| Key | Value |
|-----|-------|
| `ASPNETCORE_ENVIRONMENT` | `Production` |
| `ASPNETCORE_URLS` | `http://+:10000` |
| `Jwt__Key` | `YourSuperSecretKeyThatIsAtLeast32CharactersLong!@#$%` |
| `Jwt__Issuer` | `PcmBackend` |
| `Jwt__Audience` | `PcmMobileApp` |
| `Jwt__ExpireMinutes` | `1440` |

> [!IMPORTANT]
> **Bảo mật JWT Key**: Trong production thực tế, hãy tạo một JWT Key phức tạp và KHÔNG share công khai!

### Bước 4: Cấu Hình Port

- **Port**: `10000`

### Bước 5: Deploy

1. Click **Create Web Service**
2. Render sẽ tự động pull image từ Docker Hub và deploy
3. Quá trình deploy mất khoảng 2-5 phút

### Bước 6: Kiểm Tra Deployment

Sau khi deploy thành công:

1. Render sẽ cung cấp URL dạng: `https://pcm-backend-xxxx.onrender.com`
2. Test các endpoints:
   - **Swagger**: `https://pcm-backend-xxxx.onrender.com/swagger`
   - **Health Check**: `https://pcm-backend-xxxx.onrender.com/swagger/index.html`

---

## 🔄 Cập Nhật Deployment

Khi có thay đổi code:

### Bước 1: Rebuild và Push Image Mới

```bash
# Chạy lại script deploy
.\deploy-docker.bat
```

Hoặc manual:

```bash
docker build -t YOUR_USERNAME/pcm-backend:latest -f Backend/Dockerfile .
docker push YOUR_USERNAME/pcm-backend:latest
```

### Bước 2: Trigger Deploy trên Render

**Cách 1: Manual Deploy**
1. Vào Render Dashboard
2. Chọn service `pcm-backend`
3. Click **Manual Deploy** → **Deploy latest commit**

**Cách 2: Auto Deploy (Khuyến nghị)**
1. Vào service settings trên Render
2. Bật **Auto-Deploy**: `Yes`
3. Render sẽ tự động pull image mới khi có tag mới trên Docker Hub

---

## 🔧 Troubleshooting

### Lỗi: "Docker daemon is not running"

**Giải pháp**: Mở Docker Desktop và đợi nó khởi động hoàn toàn.

### Lỗi: "Cannot connect to Docker daemon"

**Giải pháp**:
```bash
# Windows: Khởi động lại Docker Desktop
# Hoặc chạy PowerShell/CMD với quyền Administrator
```

### Lỗi: "unauthorized: authentication required"

**Giải pháp**:
```bash
# Login lại Docker Hub
docker login
```

### Lỗi: Build failed - "COPY failed"

**Giải pháp**: Đảm bảo bạn đang chạy lệnh build từ thư mục ROOT của project, không phải từ thư mục `Backend`.

```bash
# Đúng
cd d:\MOBILE_FLUTTER_1771020771-LE-VAN-VUONG
docker build -f Backend/Dockerfile .

# Sai
cd d:\MOBILE_FLUTTER_1771020771-LE-VAN-VUONG\Backend
docker build -f Dockerfile .
```

### Lỗi: Container exits immediately

**Giải pháp**:
```bash
# Xem logs để biết lỗi
docker logs pcm-backend-test

# Thường là lỗi database hoặc configuration
# Kiểm tra environment variables
```

### Render: Service không start

**Giải pháp**:
1. Kiểm tra logs trên Render Dashboard
2. Verify environment variables đã đúng
3. Kiểm tra port configuration (phải là 10000)
4. Đảm bảo image URL đúng format: `docker.io/USERNAME/IMAGE:TAG`

### Database bị reset sau mỗi lần deploy

**Lý do**: SQLite database lưu trong container, mỗi lần deploy là container mới.

**Giải pháp**:
- **Tạm thời**: Chấp nhận việc này cho development/testing
- **Lâu dài**: Migrate sang PostgreSQL trên Render (có free tier)

---

## 📱 Tích Hợp với Flutter App

Sau khi deploy thành công, cập nhật API URL trong Flutter app:

```dart
// lib/config/api_config.dart hoặc tương tự
class ApiConfig {
  // Development
  // static const String baseUrl = 'http://localhost:5050';
  
  // Production - Render
  static const String baseUrl = 'https://pcm-backend-xxxx.onrender.com';
}
```

> [!WARNING]
> **CORS Configuration**: Backend đã được cấu hình `AllowAll` CORS policy. Trong production thực tế, nên giới hạn origins cụ thể.

---

## 📊 Monitoring và Logs

### Xem Logs trên Render

1. Vào Render Dashboard
2. Chọn service `pcm-backend`
3. Tab **Logs** - xem realtime logs
4. Tab **Metrics** - xem CPU, Memory usage

### Health Checks

Render tự động health check endpoint: `/swagger/index.html` mỗi 30 giây.

Nếu service không phản hồi, Render sẽ tự động restart container.

---

## 💰 Chi Phí

### Docker Hub
- **Free tier**: Unlimited public repositories
- **Private repos**: 1 private repo miễn phí

### Render
- **Free tier**:
  - 750 hours/month (đủ cho 1 service chạy 24/7)
  - Service sleep sau 15 phút không hoạt động
  - Wake up khi có request (mất ~30 giây)
- **Paid tier** ($7/month):
  - Không sleep
  - Tốc độ nhanh hơn
  - Nhiều resources hơn

---

## 🎯 Best Practices

1. **Versioning**: Luôn tag images với version cụ thể
   ```bash
   docker tag pcm-backend:latest pcm-backend:v1.0.0
   ```

2. **Security**: Không commit JWT keys vào Git
   - Sử dụng environment variables
   - Rotate keys định kỳ

3. **Database**: Backup database thường xuyên
   - Export SQLite database từ container
   - Hoặc migrate sang PostgreSQL

4. **Monitoring**: Setup alerts trên Render
   - Email notification khi service down
   - Monitor resource usage

5. **CI/CD**: Setup GitHub Actions để tự động build và push
   ```yaml
   # .github/workflows/deploy.yml
   # (Có thể tạo sau nếu cần)
   ```

---

## 📞 Support

Nếu gặp vấn đề:
1. Kiểm tra phần **Troubleshooting** ở trên
2. Xem logs trên Render Dashboard
3. Kiểm tra Docker Hub repository
4. Review environment variables configuration

---

## ✅ Checklist Deploy

- [ ] Docker Desktop đã cài và đang chạy
- [ ] Đã có tài khoản Docker Hub
- [ ] Đã có tài khoản Render
- [ ] Build image thành công locally
- [ ] Test container locally thành công
- [ ] Push image lên Docker Hub thành công
- [ ] Tạo Web Service trên Render
- [ ] Cấu hình environment variables
- [ ] Deploy thành công trên Render
- [ ] Test API endpoints trên Render URL
- [ ] Cập nhật API URL trong Flutter app
- [ ] Test integration Flutter app với backend deployed

---

**Chúc bạn deploy thành công! 🎉**
