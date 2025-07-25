# SnapLearn API Documentation

## Overview

SnapLearn API is a comprehensive learning platform that combines computer vision, AI-powered quiz generation, and gamified learning experiences. The API supports user authentication, image analysis, quiz generation, and real-time learning interactions.

## Base URL

```
https://your-domain.com/api
```

## Authentication

Most endpoints require JWT authentication. Include the token in the Authorization header:

```
Authorization: Bearer <your-jwt-token>
```

---

## 🔐 Authentication Endpoints

### Register User

**POST** `/api/Auth/Register`

Creates a new user account.

**Request Body:**

```json
{
  "email": "user@example.com",
  "userName": "username",
  "password": "password123",
  "language": "en"
}
```

**Response:**

```json
{
  "userName": "username"
}
```

### Login

**POST** `/api/Auth/Login`

Authenticates user and returns access token.

**Request Body:**

```json
{
  "email": "user@example.com",
  "password": "password123",
  "deviceId": "optional-device-id"
}
```

**Response:**

```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refreshToken": "refresh-token-string",
  "deviceId": "device-id"
}
```

### Refresh Token

**POST** `/api/Auth/RefreshToken`

Refreshes the access token using a valid refresh token.

**Request Body:**

```json
{
  "token": "expired-jwt-token",
  "refreshToken": "valid-refresh-token",
  "deviceId": "device-id"
}
```

**Response:**

```json
{
  "token": "new-jwt-token",
  "refreshToken": "new-refresh-token",
  "deviceId": "device-id"
}
```

### Logout

**POST** `/api/Auth/Logout`

Logs out user from all devices (requires authentication).

**Response:**

```json
{
  "message": "Logged out successfully."
}
```

### Logout Device

**POST** `/api/Auth/LogoutDevice`

Logs out user from a specific device.

**Request Body:**

```json
{
  "refreshToken": "refresh-token-to-revoke",
  "deviceId": "device-id-to-logout"
}
```

**Response:**

```json
{
  "message": "Device logged out successfully."
}
```

---

## 📸 Vision & AI Endpoints

### Detect Objects

**POST** `/api/Vision/detect-objects`

Analyzes an image to detect objects using computer vision.

**Request:** Multipart form data with image file

**Response:**

```json
[
  {
    "label": "apple",
    "confidence": 0.95,
    "boundingBox": {
      "x": 100,
      "y": 150,
      "width": 50,
      "height": 60
    }
  }
]
```

### Extract Text

**POST** `/api/Vision/extract-text`

Extracts text from an image using OCR.

**Request:** Multipart form data with image file and optional language parameter

**Response:**

```json
{
  "text": "Extracted text from image"
}
```

### Analyze Image

**POST** `/api/Vision/analyze`

Performs comprehensive image analysis including object detection and text extraction.

**Request:** Multipart form data with image file and optional language parameter

**Response:**

```json
{
  "objects": [
    {
      "label": "apple",
      "confidence": 0.95
    }
  ],
  "text": "Extracted text",
  "prompt": "AI-generated learning prompt"
}
```

---

## 🧠 Quiz Generation Endpoints

### Generate Quiz

**POST** `/api/Quiz/generate`

Generates a comprehensive quiz with questions, multiple choice options, correct answers, and explanations.

**Request Body:**

```json
{
  "topic": "Mathematics",
  "difficulty": "medium",
  "questionCount": 5,
  "context": "Algebra basics",
  "language": "en"
}
```

**Response:**

```json
{
  "quizId": "123e4567-e89b-12d3-a456-426614174000",
  "topic": "Mathematics",
  "difficulty": "medium",
  "questions": [
    {
      "id": "456e7890-e89b-12d3-a456-426614174001",
      "question": "What is the value of x in the equation 2x + 5 = 13?",
      "options": ["x = 3", "x = 4", "x = 5", "x = 6"],
      "correctAnswer": "B",
      "explanation": "To solve 2x + 5 = 13, subtract 5 from both sides: 2x = 8, then divide by 2: x = 4",
      "difficulty": "medium",
      "topic": "Mathematics",
      "points": 10
    }
  ],
  "totalPoints": 50,
  "timeLimit": 300,
  "createdAt": "2024-01-15T10:30:00Z"
}
```

### Submit Quiz Answers

**POST** `/api/Quiz/submit`

Evaluates user answers and returns score with XP and bonus points.

**Request Body:**

```json
{
  "userId": "user-id",
  "difficulty": "medium",
  "answers": [
    {
      "question": "What is the value of x in the equation 2x + 5 = 13?",
      "selected": "B",
      "correct": "B"
    }
  ]
}
```

**Response:**

```json
{
  "correct": 4,
  "total": 5,
  "xp": 40,
  "bonus": 10,
  "percentage": 80.0,
  "grade": "B"
}
```

### Get Fun Facts

**GET** `/api/Quiz/facts/{topic}`

Retrieves interesting facts about a specific topic.

**Response:**

```json
{
  "topic": "Mathematics",
  "facts": [
    "The word 'mathematics' comes from the Greek word 'mathema' meaning 'knowledge'",
    "Zero was invented in India around 500 AD",
    "The equals sign (=) was invented in 1557 by Robert Recorde"
  ]
}
```

---

## 👤 User Management Endpoints

### Get User Profile

**GET** `/api/User/user-profile`

Retrieves the current user's profile information (requires authentication).

**Response:**

```json
{
  "id": "user-id",
  "userName": "username",
  "email": "user@example.com",
  "profilPath": "/path/to/profile.jpg",
  "exp": 150.5,
  "level": 3
}
```

---

## 🎮 Battle/Game Endpoints

### Start Battle

**POST** `/api/Battle/start`

Initiates a battle session between players.

**Request Body:**

```json
{
  "userId": "user-id",
  "topic": "Mathematics",
  "difficulty": "medium"
}
```

**Response:**

```json
{
  "battleId": "battle-id",
  "status": "waiting",
  "topic": "Mathematics",
  "difficulty": "medium"
}
```

### Submit Battle Answers

**POST** `/api/Battle/submit`

Submits answers for a battle session.

**Request Body:**

```json
{
  "battleId": "battle-id",
  "userId": "user-id",
  "difficulty": "medium",
  "answers": [
    {
      "question": "Question text",
      "selected": "A",
      "correct": "A"
    }
  ]
}
```

**Response:**

```json
{
  "correct": 3,
  "total": 5,
  "xp": 30,
  "bonus": 0
}
```

### Get Battle Result

**GET** `/api/Battle/result?battleId={battleId}`

Retrieves the result of a completed battle.

**Response:**

```json
{
  "winner": "UserA",
  "xp": 30
}
```

---

## 📊 Data Models

### User

```json
{
  "id": "uuid",
  "userName": "string",
  "email": "string",
  "level": "integer",
  "exp": "float"
}
```

### QuizQuestion

```json
{
  "id": "uuid",
  "question": "string",
  "options": ["string"],
  "correctAnswer": "string",
  "explanation": "string",
  "difficulty": "string",
  "topic": "string",
  "points": "integer"
}
```

### DetectedObject

```json
{
  "label": "string",
  "confidence": "float",
  "boundingBox": {
    "x": "float",
    "y": "float",
    "width": "float",
    "height": "float"
  }
}
```

---

## 🔧 Error Responses

### Standard Error Format

```json
{
  "error": "Error message",
  "details": "Additional error details (optional)"
}
```

### Common HTTP Status Codes

- **200** - Success
- **400** - Bad Request (invalid input)
- **401** - Unauthorized (missing or invalid token)
- **404** - Not Found
- **500** - Internal Server Error

---

## 🚀 Getting Started

### 1. Register a User

```bash
curl -X POST https://your-domain.com/api/Auth/Register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "userName": "username",
    "password": "password123",
    "language": "en"
  }'
```

### 2. Login to Get Token

```bash
curl -X POST https://your-domain.com/api/Auth/Login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "password": "password123"
  }'
```

### 3. Use Token for Authenticated Requests

```bash
curl -X GET https://your-domain.com/api/User/user-profile \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

### 4. Generate a Quiz

```bash
curl -X POST https://your-domain.com/api/Quiz/generate \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "topic": "Mathematics",
    "difficulty": "medium",
    "questionCount": 5
  }'
```

---

## 📱 Frontend Integration Examples

### Flutter/Dart

```dart
// Login
final response = await http.post(
  Uri.parse('https://your-domain.com/api/Auth/Login'),
  headers: {'Content-Type': 'application/json'},
  body: jsonEncode({
    'email': 'user@example.com',
    'password': 'password123',
  }),
);

final token = jsonDecode(response.body)['token'];

// Generate Quiz
final quizResponse = await http.post(
  Uri.parse('https://your-domain.com/api/Quiz/generate'),
  headers: {
    'Authorization': 'Bearer $token',
    'Content-Type': 'application/json',
  },
  body: jsonEncode({
    'topic': 'Mathematics',
    'difficulty': 'medium',
    'questionCount': 5,
  }),
);
```

### JavaScript/React

```javascript
// Login
const loginResponse = await fetch("/api/Auth/Login", {
  method: "POST",
  headers: { "Content-Type": "application/json" },
  body: JSON.stringify({
    email: "user@example.com",
    password: "password123",
  }),
});

const { token } = await loginResponse.json();

// Generate Quiz
const quizResponse = await fetch("/api/Quiz/generate", {
  method: "POST",
  headers: {
    Authorization: `Bearer ${token}`,
    "Content-Type": "application/json",
  },
  body: JSON.stringify({
    topic: "Mathematics",
    difficulty: "medium",
    questionCount: 5,
  }),
});
```

---

## 🔒 Security Considerations

1. **JWT Tokens**: Store tokens securely and refresh before expiration
2. **HTTPS**: Always use HTTPS in production
3. **Input Validation**: Validate all user inputs
4. **Rate Limiting**: Implement rate limiting for API endpoints
5. **CORS**: Configure CORS properly for web applications

---

## 📈 Rate Limits

- **Authentication endpoints**: 10 requests per minute
- **Quiz generation**: 5 requests per minute
- **Vision analysis**: 20 requests per minute
- **General endpoints**: 100 requests per minute

---

## 🆘 Support

For API support and questions:

- Email: support@snaplearn.com
- Documentation: https://docs.snaplearn.com
- GitHub Issues: https://github.com/snaplearn/api/issues
