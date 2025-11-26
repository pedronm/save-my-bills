# Save My Bills - Screenshot Storage System

A complete solution for managing bill screenshots with cloud storage, consisting of a Java Spring Boot backend with GraphQL API and a Flutter mobile application.

## Architecture Overview

### Backend (Java Spring Boot)
- **REST API** for screenshot upload
- **GraphQL API** for data querying and mutations
- **PostgreSQL** for relational data (references and descriptions)
- **MongoDB** for non-relational data (full screenshot metadata)
- **Google Drive API** for cloud file storage

### Frontend (Flutter)
- **GraphQL Client** for backend communication
- **SQLite** for local data storage
- **Offline-first** architecture with sync capability
- **Image capture** from camera or gallery

## Project Structure

```
save-my-bills/
├── backend/
│   ├── src/
│   │   ├── main/
│   │   │   ├── java/com/savemybills/
│   │   │   │   ├── SaveMyBillsApplication.java
│   │   │   │   ├── model/
│   │   │   │   │   ├── ScreenshotReference.java (PostgreSQL entity)
│   │   │   │   │   └── ScreenshotData.java (MongoDB document)
│   │   │   │   ├── repository/
│   │   │   │   │   ├── ScreenshotReferenceRepository.java
│   │   │   │   │   └── ScreenshotDataRepository.java
│   │   │   │   ├── service/
│   │   │   │   │   ├── GoogleDriveService.java
│   │   │   │   │   └── ScreenshotService.java
│   │   │   │   ├── controller/
│   │   │   │   │   └── ScreenshotController.java
│   │   │   │   └── graphql/
│   │   │   │       └── ScreenshotResolver.java
│   │   │   └── resources/
│   │   │       ├── application.yml
│   │   │       └── graphql/
│   │   │           └── schema.graphqls
│   │   └── test/
│   ├── pom.xml
│   └── docker-compose.yml
└── frontend/
    ├── lib/
    │   ├── main.dart
    │   ├── models/
    │   │   └── screenshot.dart
    │   ├── services/
    │   │   ├── graphql_service.dart
    │   │   ├── database_service.dart
    │   │   └── upload_service.dart
    │   └── screens/
    │       ├── home_screen.dart
    │       ├── upload_screen.dart
    │       └── screenshot_detail_screen.dart
    └── pubspec.yaml
```

## Backend Setup

### Prerequisites
- Java 17 or higher
- Maven 3.6+
- Docker and Docker Compose (for databases)
- Google Cloud Platform account (for Drive API)

### Database Setup

1. Start PostgreSQL and MongoDB using Docker Compose:
```bash
cd backend
docker-compose up -d
```

2. Verify databases are running:
```bash
docker ps
```

### Google Drive API Setup

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select an existing one
3. Enable the Google Drive API
4. Create credentials (Service Account)
5. Download the JSON credentials file
6. Set the environment variable:
```bash
export GOOGLE_CREDENTIALS_PATH=/path/to/credentials.json
```

Alternatively, update `application.yml`:
```yaml
google:
  credentials:
    path: /path/to/credentials.json
```

### Running the Backend

1. Build the project:
```bash
cd backend
mvn clean install
```

2. Run the application:
```bash
mvn spring-boot:run
```

The backend will start on `http://localhost:8080`

### API Endpoints

#### REST API
- `POST /api/screenshots/upload` - Upload a screenshot

**Example using cURL:**
```bash
curl -X POST http://localhost:8080/api/screenshots/upload \
  -F "file=@/path/to/screenshot.jpg" \
  -F "title=Restaurant Bill" \
  -F "description=Lunch at Italian Restaurant" \
  -F "userId=user123" \
  -F "category=Food" \
  -F "amount=45.50" \
  -F "currency=USD" \
  -F "vendor=Italian Bistro"
```

#### GraphQL API
- Endpoint: `http://localhost:8080/graphql`
- GraphiQL UI: `http://localhost:8080/graphiql`

**Example Queries:**

Get all screenshots:
```graphql
query {
  screenshots {
    id
    screenshotId
    filename
    driveFileUrl
    uploadedAt
    vendor
    amount
    currency
    category
  }
}
```

Get screenshots by user:
```graphql
query {
  screenshotsByUser(userId: "user123") {
    screenshotId
    filename
    vendor
    amount
  }
}
```

Delete a screenshot:
```graphql
mutation {
  deleteScreenshot(screenshotId: "abc-123-def")
}
```

## Frontend Setup

### Prerequisites
- Flutter SDK 3.0.0 or higher
- Android Studio / Xcode (for mobile development)
- An Android or iOS device/emulator

### Installation

1. Navigate to the frontend directory:
```bash
cd frontend
```

2. Install dependencies:
```bash
flutter pub get
```

3. Update backend URL in `lib/services/graphql_service.dart` and `lib/services/upload_service.dart`:
```dart
// For Android emulator
static const String _apiUrl = 'http://10.0.2.2:8080/graphql';
static const String baseUrl = 'http://10.0.2.2:8080/api/screenshots';

// For iOS simulator
static const String _apiUrl = 'http://localhost:8080/graphql';
static const String baseUrl = 'http://localhost:8080/api/screenshots';

// For physical device (replace with your computer's IP)
static const String _apiUrl = 'http://192.168.1.X:8080/graphql';
static const String baseUrl = 'http://192.168.1.X:8080/api/screenshots';
```

4. Run the app:
```bash
flutter run
```

### Features

#### Home Screen
- View all screenshots from cloud (GraphQL)
- Toggle between cloud and local data
- Pull to refresh
- Tap to view details

#### Upload Screen
- Capture photo from camera
- Select image from gallery
- Enter bill details:
  - Title (required)
  - Description
  - User ID
  - Category
  - Vendor
  - Amount and Currency
  - Bill Date
- Upload to backend

#### Detail Screen
- View complete screenshot information
- File details
- Bill information
- Timestamps
- Google Drive link
- Delete screenshot

### Local Storage
The app uses SQLite for local storage, enabling:
- Offline access to previously synced data
- Fast loading of cached screenshots
- Data persistence across app restarts

## Data Models

### PostgreSQL Schema (Relational)
```sql
CREATE TABLE screenshot_references (
    id BIGSERIAL PRIMARY KEY,
    screenshot_id VARCHAR(255) NOT NULL UNIQUE,
    title VARCHAR(255) NOT NULL,
    description VARCHAR(1000),
    drive_file_id VARCHAR(255) NOT NULL,
    uploaded_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP
);
```

### MongoDB Schema (Non-Relational)
```json
{
  "_id": "ObjectId",
  "screenshotId": "string",
  "filename": "string",
  "contentType": "string",
  "fileSize": "number",
  "driveFileId": "string",
  "driveFileUrl": "string",
  "uploadedAt": "ISODate",
  "lastAccessedAt": "ISODate",
  "userId": "string",
  "category": "string",
  "amount": "number",
  "currency": "string",
  "billDate": "ISODate",
  "vendor": "string",
  "tags": "object",
  "metadata": "object"
}
```

### SQLite Schema (Local)
```sql
CREATE TABLE screenshots (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    screenshotId TEXT NOT NULL UNIQUE,
    filename TEXT NOT NULL,
    contentType TEXT,
    fileSize REAL,
    driveFileId TEXT NOT NULL,
    driveFileUrl TEXT,
    uploadedAt TEXT NOT NULL,
    lastAccessedAt TEXT,
    userId TEXT,
    category TEXT,
    amount REAL,
    currency TEXT,
    billDate TEXT,
    vendor TEXT,
    tags TEXT
);
```

## Configuration

### Backend Configuration (`application.yml`)

```yaml
spring:
  datasource:
    url: jdbc:postgresql://localhost:5432/savemybills
    username: postgres
    password: postgres
  
  data:
    mongodb:
      uri: mongodb://localhost:27017/savemybills
  
  servlet:
    multipart:
      max-file-size: 50MB
      max-request-size: 50MB

google:
  drive:
    folder:
      id: root  # or specific folder ID
  credentials:
    path: /path/to/credentials.json
```

### Frontend Configuration

Update URLs in:
- `lib/services/graphql_service.dart`
- `lib/services/upload_service.dart`

## Testing

### Backend Tests
```bash
cd backend
mvn test
```

### Frontend Tests
```bash
cd frontend
flutter test
```

## Deployment

### Backend Deployment

#### Using Docker
Create a `Dockerfile` in the backend directory:
```dockerfile
FROM openjdk:17-jdk-slim
COPY target/screenshot-backend-1.0.0.jar app.jar
ENTRYPOINT ["java","-jar","/app.jar"]
```

Build and run:
```bash
mvn clean package
docker build -t savemybills-backend .
docker run -p 8080:8080 savemybills-backend
```

### Frontend Deployment

#### Android
```bash
flutter build apk --release
```

#### iOS
```bash
flutter build ios --release
```

## Security Considerations

1. **Google Drive Credentials**: Never commit credentials to version control
2. **API Authentication**: Consider adding JWT or OAuth2 authentication
3. **File Upload Validation**: Validate file types and sizes
4. **SQL Injection**: Use parameterized queries (already implemented)
5. **CORS**: Configure CORS settings for production

## Troubleshooting

### Backend Issues

**Database connection failed:**
- Ensure Docker containers are running
- Check database credentials in `application.yml`

**Google Drive upload failed:**
- Verify credentials file path
- Check Google Drive API is enabled
- Ensure service account has necessary permissions

### Frontend Issues

**Cannot connect to backend:**
- Check backend URL configuration
- Ensure backend is running
- For Android emulator, use `10.0.2.2` instead of `localhost`

**SQLite errors:**
- Clear app data and reinstall
- Check database initialization in `database_service.dart`

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

See LICENSE file for details.

## Support

For issues and questions, please open an issue on GitHub.
