# Backend Setup Guide

## Prerequisites

Before running the backend, ensure you have:

1. **Java 17 or higher** - Check with `java -version`
2. **Maven 3.6+** - Check with `mvn -version`
3. **Docker and Docker Compose** - For running PostgreSQL and MongoDB
4. **Google Cloud Platform account** - For Google Drive API access

## Step 1: Database Setup

### Using Docker Compose (Recommended)

The easiest way to run the required databases is using Docker Compose:

```bash
cd backend
docker-compose up -d
```

This will start:
- PostgreSQL on port 5432
- MongoDB on port 27017

Verify the containers are running:
```bash
docker ps
```

You should see two containers: `savemybills-postgres` and `savemybills-mongodb`

### Manual Database Setup (Alternative)

If you prefer to install databases manually:

**PostgreSQL:**
```bash
# Create database
createdb savemybills

# Or via psql
psql -U postgres
CREATE DATABASE savemybills;
```

**MongoDB:**
```bash
# Start MongoDB service
mongod --dbpath /path/to/data/directory

# The database will be created automatically
```

## Step 2: Google Drive API Setup

1. Go to [Google Cloud Console](https://console.cloud.google.com/)

2. Create a new project (or select existing)

3. Enable the Google Drive API:
   - Navigate to "APIs & Services" > "Library"
   - Search for "Google Drive API"
   - Click "Enable"

4. Create Service Account Credentials:
   - Go to "APIs & Services" > "Credentials"
   - Click "Create Credentials" > "Service Account"
   - Fill in the service account details
   - Click "Create and Continue"
   - Skip role assignment (or add roles as needed)
   - Click "Done"

5. Create and Download JSON Key:
   - Click on the created service account
   - Go to "Keys" tab
   - Click "Add Key" > "Create New Key"
   - Select "JSON" format
   - Click "Create"
   - Save the downloaded JSON file securely

6. Configure the Application:

   **Option A: Environment Variable**
   ```bash
   export GOOGLE_CREDENTIALS_PATH=/path/to/your/credentials.json
   ```

   **Option B: Update application.yml**
   ```yaml
   google:
     credentials:
       path: /path/to/your/credentials.json
   ```

   **⚠️ IMPORTANT:** Never commit credentials to version control!

7. (Optional) Share a specific folder:
   - Create a folder in Google Drive
   - Right-click > "Share"
   - Add the service account email (found in credentials JSON)
   - Grant "Editor" permission
   - Copy the folder ID from the URL and update `application.yml`:
   ```yaml
   google:
     drive:
       folder:
         id: YOUR_FOLDER_ID_HERE
   ```

## Step 3: Build the Backend

```bash
cd backend
mvn clean install
```

This will:
- Download all dependencies
- Compile the source code
- Run tests
- Package the application

## Step 4: Run the Application

```bash
mvn spring-boot:run
```

Or run the JAR directly:
```bash
java -jar target/receipt-backend-1.0.0.jar
```

The application will start on **http://localhost:8080**

## Step 5: Verify Installation

1. **Check Application Health:**
   ```bash
   curl http://localhost:8080/actuator/health
   ```
   (Note: You may need to enable actuator in pom.xml first)

2. **Access GraphiQL:**
   Open your browser and navigate to:
   ```
   http://localhost:8080/graphiql
   ```

3. **Test GraphQL Query:**
   In GraphiQL, try:
   ```graphql
   query {
     receipts {
       receiptId
       filename
     }
   }
   ```

4. **Test REST Upload:**
   ```bash
   curl -X POST http://localhost:8080/api/receipts/upload \
     -F "file=@test-image.jpg" \
     -F "title=Test Receipt" \
     -F "category=Test"
   ```

## Configuration Reference

### Database Configuration

**PostgreSQL** (`application.yml`):
```yaml
spring:
  datasource:
    url: jdbc:postgresql://localhost:5432/savemybills
    username: postgres
    password: postgres
```

**MongoDB** (`application.yml`):
```yaml
spring:
  data:
    mongodb:
      uri: mongodb://localhost:27017/savemybills
```

### File Upload Limits

```yaml
spring:
  servlet:
    multipart:
      max-file-size: 50MB      # Maximum file size
      max-request-size: 50MB   # Maximum request size
```

### Google Drive Configuration

```yaml
google:
  drive:
    folder:
      id: root  # Use "root" or specific folder ID
  credentials:
    path: ${GOOGLE_CREDENTIALS_PATH:/path/to/credentials.json}
```

## Troubleshooting

### Database Connection Issues

**Problem:** `Connection to localhost:5432 refused`

**Solutions:**
1. Ensure Docker containers are running: `docker ps`
2. Start containers if stopped: `docker-compose up -d`
3. Check database credentials in `application.yml`
4. For manual installation, ensure PostgreSQL service is running

**Problem:** `MongoDB connection failed`

**Solutions:**
1. Check if MongoDB container is running
2. Verify MongoDB is accessible: `mongo localhost:27017`
3. Check MongoDB URI in `application.yml`

### Google Drive Upload Issues

**Problem:** `Failed to upload to Google Drive`

**Solutions:**
1. Verify credentials file path is correct
2. Ensure Google Drive API is enabled in GCP
3. Check service account has necessary permissions
4. Verify credentials JSON file is valid

**Problem:** `google.auth.exceptions.RefreshError`

**Solutions:**
1. Regenerate service account key
2. Ensure the credentials file hasn't been corrupted
3. Check system time is synchronized (OAuth requires accurate time)

### Build Issues

**Problem:** `Could not resolve dependencies`

**Solutions:**
1. Clear Maven cache: `rm -rf ~/.m2/repository`
2. Retry build: `mvn clean install -U`
3. Check internet connection
4. Verify Maven settings.xml configuration

**Problem:** `javac: invalid target release: 17`

**Solutions:**
1. Ensure Java 17 is installed: `java -version`
2. Set JAVA_HOME: `export JAVA_HOME=/path/to/java17`
3. Update Maven Java version in pom.xml if needed

## Running in Production

### Using Docker

1. Build the JAR:
   ```bash
   mvn clean package -DskipTests
   ```

2. Create Dockerfile (already in project):
   ```dockerfile
   FROM openjdk:17-jdk-slim
   COPY target/receipt-backend-1.0.0.jar app.jar
   ENTRYPOINT ["java","-jar","/app.jar"]
   ```

3. Build Docker image:
   ```bash
   docker build -t savemybills-backend .
   ```

4. Run container:
   ```bash
   docker run -p 8080:8080 \
     -e GOOGLE_CREDENTIALS_PATH=/credentials/credentials.json \
     -v /path/to/credentials:/credentials \
     savemybills-backend
   ```

### Environment Variables

Set these in production:

```bash
export SPRING_DATASOURCE_URL=jdbc:postgresql://prod-db:5432/savemybills
export SPRING_DATASOURCE_USERNAME=produser
export SPRING_DATASOURCE_PASSWORD=prodpassword
export SPRING_DATA_MONGODB_URI=mongodb://prod-mongo:27017/savemybills
export GOOGLE_CREDENTIALS_PATH=/path/to/credentials.json
```

### Security Considerations

1. **Never commit credentials** to version control
2. Use environment-specific configuration files
3. Implement authentication and authorization
4. Enable HTTPS/TLS in production
5. Use secrets management (e.g., AWS Secrets Manager, HashiCorp Vault)
6. Regularly update dependencies for security patches
7. Implement rate limiting for API endpoints
8. Validate and sanitize all input data

## Development Tips

### Hot Reload

Use Spring Boot DevTools for automatic restart:
```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-devtools</artifactId>
    <optional>true</optional>
</dependency>
```

### Debugging

Run with debug enabled:
```bash
mvn spring-boot:run -Dspring-boot.run.jvmArguments="-Xdebug -Xrunjdwp:transport=dt_socket,server=y,suspend=n,address=5005"
```

Then attach your IDE debugger to port 5005.

### Logging

Adjust logging levels in `application.yml`:
```yaml
logging:
  level:
    com.savemybills: DEBUG
    org.springframework: INFO
    org.hibernate: INFO
```

## Additional Resources

- [Spring Boot Documentation](https://spring.io/projects/spring-boot)
- [Spring GraphQL](https://spring.io/projects/spring-graphql)
- [Google Drive API](https://developers.google.com/drive/api/v3/about-sdk)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [MongoDB Documentation](https://www.mongodb.com/docs/)
