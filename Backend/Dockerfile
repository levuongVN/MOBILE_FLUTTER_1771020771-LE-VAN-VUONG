# Build stage
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Copy csproj and restore dependencies (better layer caching)
COPY Backend/PcmBackend.csproj Backend/
RUN dotnet restore Backend/PcmBackend.csproj

# Copy everything else and build
COPY Backend/ Backend/
RUN dotnet publish Backend/PcmBackend.csproj -c Release -o /app/publish

# Runtime stage
FROM mcr.microsoft.com/dotnet/aspnet:8.0
WORKDIR /app

# Copy published app from build stage
COPY --from=build /app/publish .

# Set environment variables
ENV ASPNETCORE_ENVIRONMENT=Production
ENV ASPNETCORE_URLS=http://+:10000

# Expose port
EXPOSE 10000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl --fail http://localhost:10000/swagger/index.html || exit 1

# Run the application
ENTRYPOINT ["dotnet", "PcmBackend.dll"]

