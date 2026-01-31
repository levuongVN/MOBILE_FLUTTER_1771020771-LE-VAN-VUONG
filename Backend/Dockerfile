FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
WORKDIR /src

# Sửa: Vì đang đứng trong Backend rồi, chỉ cần tìm file .csproj tại chỗ
COPY *.csproj ./
RUN dotnet restore

# Sửa: Copy mọi thứ ở thư mục hiện tại (chính là Backend) vào container
COPY . .
RUN dotnet publish -c Release -o /app/publish

FROM mcr.microsoft.com/dotnet/aspnet:9.0
WORKDIR /app
COPY --from=build /app/publish .

ENV ASPNETCORE_URLS=http://+:10000
EXPOSE 10000

# Đảm bảo file này tên chính xác là PcmBackend.dll nhé
ENTRYPOINT ["dotnet", "PcmBackend.dll"]
