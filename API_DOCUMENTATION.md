# API Documentation

## REST API Endpoints

### Upload Receipt

**Endpoint:** `POST /api/receipts/upload`

**Description:** Upload a bill receipt to the system. The file will be stored in Google Drive, with metadata saved in both PostgreSQL and MongoDB.

**Request:**
- Method: POST
- Content-Type: multipart/form-data

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| file | File | Yes | The receipt image file |
| title | String | Yes | Title or name of the bill |
| description | String | No | Additional description |
| userId | String | No | User identifier |
| category | String | No | Category (e.g., Food, Transport, Utilities) |
| amount | Number | No | Bill amount |
| currency | String | No | Currency code (default: USD) |
| billDate | DateTime | No | Date of the bill (ISO 8601 format) |
| vendor | String | No | Vendor or merchant name |
| tags | Map | No | Additional tags as key-value pairs |

**Response (Success - 201):**
```json
{
  "success": true,
  "receiptId": "550e8400-e29b-41d4-a716-446655440000",
  "driveFileUrl": "https://drive.google.com/file/d/...",
  "uploadedAt": "2024-01-15T10:30:00"
}
```

**Response (Error - 500):**
```json
{
  "success": false,
  "error": "Error message describing what went wrong"
}
```

**Example using cURL:**
```bash
curl -X POST http://localhost:8080/api/receipts/upload \
  -F "file=@bill.jpg" \
  -F "title=Grocery Shopping" \
  -F "description=Weekly groceries" \
  -F "userId=user123" \
  -F "category=Food" \
  -F "amount=125.50" \
  -F "currency=USD" \
  -F "billDate=2024-01-15T14:30:00" \
  -F "vendor=SuperMart"
```

## GraphQL API

**Endpoint:** `http://localhost:8080/graphql`

**GraphiQL UI:** `http://localhost:8080/graphiql`

### Schema

```graphql
type Query {
    receipt(receiptId: String!): Receipt
    receipts: [Receipt!]!
    receiptsByUser(userId: String!): [Receipt!]!
    receiptsByCategory(category: String!): [Receipt!]!
    receiptsByUserAndCategory(userId: String!, category: String!): [Receipt!]!
}

type Mutation {
    deleteReceipt(receiptId: String!): Boolean!
}

type Receipt {
    id: ID!
    receiptId: String!
    filename: String!
    contentType: String
    fileSize: Float
    driveFileId: String!
    driveFileUrl: String
    uploadedAt: String!
    lastAccessedAt: String
    userId: String
    category: String
    amount: Float
    currency: String
    billDate: String
    vendor: String
}
```

### Queries

#### Get All Receipts

```graphql
query {
  receipts {
    id
    receiptId
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

**Response:**
```json
{
  "data": {
    "receipts": [
      {
        "id": "1",
        "receiptId": "550e8400-e29b-41d4-a716-446655440000",
        "filename": "bill.jpg",
        "driveFileUrl": "https://drive.google.com/file/d/...",
        "uploadedAt": "2024-01-15T10:30:00",
        "vendor": "SuperMart",
        "amount": 125.50,
        "currency": "USD",
        "category": "Food"
      }
    ]
  }
}
```

#### Get Single Receipt

```graphql
query {
  receipt(receiptId: "550e8400-e29b-41d4-a716-446655440000") {
    receiptId
    filename
    vendor
    amount
    currency
    uploadedAt
    driveFileUrl
  }
}
```

#### Get Receipts by User

```graphql
query {
  receiptsByUser(userId: "user123") {
    receiptId
    filename
    vendor
    amount
    category
    uploadedAt
  }
}
```

#### Get Receipts by Category

```graphql
query {
  receiptsByCategory(category: "Food") {
    receiptId
    filename
    vendor
    amount
    uploadedAt
  }
}
```

#### Get Receipts by User and Category

```graphql
query {
  receiptsByUserAndCategory(userId: "user123", category: "Food") {
    receiptId
    filename
    vendor
    amount
    uploadedAt
  }
}
```

### Mutations

#### Delete Receipt

```graphql
mutation {
  deleteReceipt(receiptId: "550e8400-e29b-41d4-a716-446655440000")
}
```

**Response:**
```json
{
  "data": {
    "deleteReceipt": true
  }
}
```

## Data Flow

### Upload Flow

1. Client sends multipart/form-data POST request to `/api/receipts/upload`
2. Backend receives the file and metadata
3. File is uploaded to Google Drive
4. Reference data (title, description, driveFileId) saved to PostgreSQL
5. Full metadata saved to MongoDB
6. Response returned with receipt ID and Drive URL

### Query Flow

1. Client sends GraphQL query to `/graphql`
2. GraphQL resolver queries MongoDB for receipt data
3. Data returned in requested format
4. Flutter app can cache data locally in SQLite

### Delete Flow

1. Client sends GraphQL mutation to delete receipt
2. Backend deletes file from Google Drive
3. Record deleted from MongoDB
4. Reference deleted from PostgreSQL
5. Success response returned

## Error Codes

| Status Code | Description |
|-------------|-------------|
| 200 | Success |
| 201 | Created (successful upload) |
| 400 | Bad Request (invalid parameters) |
| 404 | Not Found (receipt doesn't exist) |
| 500 | Internal Server Error |

## Rate Limiting

Currently, no rate limiting is implemented. For production deployment, consider implementing rate limiting to prevent abuse.

## Authentication

The current implementation does not include authentication. For production use, implement one of the following:

- JWT (JSON Web Tokens)
- OAuth2
- API Keys
- Session-based authentication

## CORS Configuration

For production, configure CORS to only allow requests from trusted origins. Add to your Spring Boot configuration:

```java
@Configuration
public class CorsConfig implements WebMvcConfigurer {
    @Override
    public void addCorsMappings(CorsRegistry registry) {
        registry.addMapping("/**")
            .allowedOrigins("https://yourdomain.com")
            .allowedMethods("GET", "POST", "PUT", "DELETE")
            .allowedHeaders("*")
            .allowCredentials(true);
    }
}
```
