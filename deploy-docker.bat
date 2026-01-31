@echo off
REM ============================================
REM Script Deploy Backend lên Docker Hub
REM ============================================

echo ========================================
echo PCM Backend - Docker Deployment Script
echo ========================================
echo.

REM Yêu cầu nhập Docker Hub username
set /p DOCKER_USERNAME="Nhap Docker Hub username cua ban: "
if "%DOCKER_USERNAME%"=="" (
    echo ERROR: Docker Hub username khong duoc de trong!
    pause
    exit /b 1
)

REM Thiết lập tên image
set IMAGE_NAME=pcm-backend
set IMAGE_TAG=latest
set FULL_IMAGE_NAME=%DOCKER_USERNAME%/%IMAGE_NAME%:%IMAGE_TAG%

echo.
echo Thong tin build:
echo - Docker Hub Username: %DOCKER_USERNAME%
echo - Image Name: %IMAGE_NAME%
echo - Tag: %IMAGE_TAG%
echo - Full Image: %FULL_IMAGE_NAME%
echo.

REM Xác nhận trước khi tiếp tục
set /p CONFIRM="Ban co muon tiep tuc? (Y/N): "
if /i not "%CONFIRM%"=="Y" (
    echo Huy bo!
    pause
    exit /b 0
)

echo.
echo [1/4] Dang login vao Docker Hub...
docker login
if errorlevel 1 (
    echo ERROR: Docker login that bai!
    pause
    exit /b 1
)

echo.
echo [2/4] Dang build Docker image...
docker build -t %FULL_IMAGE_NAME% -f Backend/Dockerfile .
if errorlevel 1 (
    echo ERROR: Docker build that bai!
    pause
    exit /b 1
)

echo.
echo [3/4] Dang push image len Docker Hub...
docker push %FULL_IMAGE_NAME%
if errorlevel 1 (
    echo ERROR: Docker push that bai!
    pause
    exit /b 1
)

echo.
echo [4/4] Tao tag 'latest' va push...
docker tag %FULL_IMAGE_NAME% %DOCKER_USERNAME%/%IMAGE_NAME%:latest
docker push %DOCKER_USERNAME%/%IMAGE_NAME%:latest

echo.
echo ========================================
echo THANH CONG!
echo ========================================
echo.
echo Image da duoc push len Docker Hub:
echo - %FULL_IMAGE_NAME%
echo.
echo Buoc tiep theo:
echo 1. Truy cap https://render.com
echo 2. Tao Web Service moi
echo 3. Chon "Deploy an existing image from a registry"
echo 4. Nhap image URL: %FULL_IMAGE_NAME%
echo 5. Cau hinh port: 10000
echo 6. Them environment variables (xem DEPLOYMENT.md)
echo.
pause
