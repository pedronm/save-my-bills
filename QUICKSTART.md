# Quick Start Guide

Get the Save My Bills screenshot storage system up and running in minutes!

## Prerequisites

- Java 17+
- Maven 3.6+
- Docker & Docker Compose
- Flutter 3.0+ (for mobile app)

## 5-Minute Backend Setup

### 1. Start Databases

```bash
cd backend
docker-compose up -d
```

Wait ~30 seconds for databases to initialize.

### 2. Configure Google Drive (Optional for testing)

For testing without Google Drive, you can skip this step. The app will show an error when uploading, but you can test other features.

To enable Google Drive:
```bash
export GOOGLE_CREDENTIALS_PATH=/path/to/your/credentials.json
```

See [BACKEND_SETUP.md](BACKEND_SETUP.md) for detailed Google Drive setup.

### 3. Start Backend

```bash
mvn spring-boot:run
```

The backend will be available at `http://localhost:8080`

### 4. Verify Backend

Open browser to: `http://localhost:8080/graphiql`

Try this query:
```graphql
query {
  screenshots {
    screenshotId
    filename
  }
}
```

## 5-Minute Frontend Setup

### 1. Install Dependencies

```bash
cd frontend
flutter pub get
```

### 2. Configure Backend URL

For Android Emulator, edit `lib/services/graphql_service.dart`:
```dart
static const String _apiUrl = 'http://10.0.2.2:8080/graphql';
```

For iOS Simulator or physical device, see [FRONTEND_SETUP.md](FRONTEND_SETUP.md).

### 3. Run App

```bash
flutter run
```

Select your device when prompted.

## Quick Test

### Test Backend Upload (cURL)

```bash
curl -X POST http://localhost:8080/api/screenshots/upload \
  -F "file=@/path/to/image.jpg" \
  -F "title=Test Receipt" \
  -F "category=Food"
```

### Test Frontend

1. Launch the app
2. Tap the camera button (bottom-right)
3. Take a photo or select from gallery
4. Fill in "Title" field
5. Tap "Upload Screenshot"
6. Go back to see your screenshot

## Common Issues

### Backend won't start
- **Database connection failed**: Run `docker ps` to check containers
- **Port 8080 in use**: Kill process or change port in `application.yml`

### Frontend can't connect
- **Android Emulator**: Use `10.0.2.2` instead of `localhost`
- **Physical Device**: Use your computer's IP address
- **Backend not running**: Ensure backend is at `localhost:8080`

## What's Next?

### For Backend Development
- Read [BACKEND_SETUP.md](BACKEND_SETUP.md) for detailed configuration
- Check [API_DOCUMENTATION.md](API_DOCUMENTATION.md) for API reference
- Set up Google Drive for cloud storage

### For Frontend Development
- Read [FRONTEND_SETUP.md](FRONTEND_SETUP.md) for detailed setup
- Test on different devices/emulators
- Customize UI and features

### For Production
- Set up authentication
- Configure HTTPS/SSL
- Set up monitoring
- Review security checklist

## Architecture Overview

```
┌─────────────────┐
│  Flutter App    │
│  (Frontend)     │
└────────┬────────┘
         │ GraphQL/REST
         │
┌────────▼────────┐     ┌──────────────┐
│  Spring Boot    │────▶│ Google Drive │
│  (Backend)      │     └──────────────┘
└────────┬────────┘
         │
    ┌────┴────┐
    │         │
┌───▼──┐  ┌──▼────┐
│ Postgres MongoDB │
└──────┘  └───────┘
```

## Documentation

- [README.md](README.md) - Complete project overview
- [API_DOCUMENTATION.md](API_DOCUMENTATION.md) - API reference
- [BACKEND_SETUP.md](BACKEND_SETUP.md) - Backend setup guide
- [FRONTEND_SETUP.md](FRONTEND_SETUP.md) - Frontend setup guide
- [PROJECT_SUMMARY.md](PROJECT_SUMMARY.md) - Project summary

## Need Help?

1. Check the troubleshooting sections in setup guides
2. Review the [PROJECT_SUMMARY.md](PROJECT_SUMMARY.md)
3. Open an issue on GitHub

## Success Criteria

✅ Backend running on port 8080  
✅ GraphiQL accessible at http://localhost:8080/graphiql  
✅ Flutter app running on device/emulator  
✅ Can upload screenshot from app  
✅ Can view screenshots in app  

Happy coding! 🚀
