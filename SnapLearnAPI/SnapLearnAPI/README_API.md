# SnapLearn API Documentation

## Overview

SnapLearn API provides AI-powered learning with computer vision, quiz generation, and gamified experiences.

## Base URL

```
https://your-domain.com/api
```

## Authentication

Include JWT token in Authorization header:

```
Authorization: Bearer <your-jwt-token>
```

---

## 🔐 Authentication Endpoints

### Register User

**POST** `/api/Auth/Register`

```json
{
  "email": "user@example.com",
  "userName": "username",
  "password": "password123",
  "language": "en"
}
```

### Login

**POST** `/api/Auth/Login`

```json
{
  "email": "user@example.com",
  "password": "password123",
  "deviceId": "optional-device-id"
}
```

### Refresh Token

**POST** `/api/Auth/RefreshToken`

```json
{
  "token": "expired-jwt-token",
  "refreshToken": "valid-refresh-token",
  "deviceId": "device-id"
}
```

### Logout Device

**POST** `/api/Auth/LogoutDevice`

```json
{
  "refreshToken": "refresh-token-to-revoke",
  "deviceId": "device-id-to-logout"
}
```

---

## 🧠 Quiz Generation

### Generate Quiz with Answers

**POST** `/api/Quiz/generate`

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
      "question": "What is the value of x in 2x + 5 = 13?",
      "options": ["x = 3", "x = 4", "x = 5", "x = 6"],
      "correctAnswer": "B",
      "explanation": "Subtract 5: 2x = 8, divide by 2: x = 4",
      "points": 10
    }
  ],
  "totalPoints": 50,
  "timeLimit": 300
}
```

### Submit Quiz Answers

**POST** `/api/Quiz/submit`

```json
{
  "userId": "user-id",
  "difficulty": "medium",
  "answers": [
    {
      "question": "What is the value of x in 2x + 5 = 13?",
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

```json
{
  "topic": "Mathematics",
  "facts": [
    "The word 'mathematics' comes from Greek 'mathema'",
    "Zero was invented in India around 500 AD",
    "The equals sign (=) was invented in 1557"
  ]
}
```

---

## 📸 Vision & AI

### Analyze Image

**POST** `/api/Vision/analyze`
Multipart form with image file + language parameter (requires authentication)

**Response:**

```json
{
  "objects": [
    { "label": "apple", "confidence": 0.95, ... }
  ],
  "text": "Extracted text from image",
  "facts": [
    "Fact 1 about the object",
    "Fact 2 about the object",
    "Fact 3 about the object"
  ],
  "quizzes": [
    {
      "question": "What color is the apple?",
      "choices": ["Red", "Blue", "Green"],
      "answer": "Red"
    },
    {
      "question": "Where do apples grow?",
      "choices": ["On trees", "Underground", "In water"],
      "answer": "On trees"
    }
  ],
  "image": "base64string"
}
```

---

## 👤 User Management

### Get User Profile

**GET** `/api/User/user-profile` (requires auth)

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

## 🎮 Battle/Game

### Start Battle

**POST** `/api/Battle/start`

```json
{
  "userId": "user-id",
  "topic": "Mathematics",
  "difficulty": "medium"
}
```

### Submit Battle Answers

**POST** `/api/Battle/submit`

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

---

## 🔧 Error Responses

```json
{
  "error": "Error message",
  "details": "Additional details (optional)"
}
```

**Status Codes:**

- 200 - Success
- 400 - Bad Request
- 401 - Unauthorized
- 404 - Not Found
- 500 - Internal Server Error

---

## 🚀 Quick Start

1. **Register:**

```bash
curl -X POST /api/Auth/Register \
  -H "Content-Type: application/json" \
  -d '{"email":"user@example.com","userName":"username","password":"password123"}'
```

2. **Login:**

```bash
curl -X POST /api/Auth/Login \
  -H "Content-Type: application/json" \
  -d '{"email":"user@example.com","password":"password123"}'
```

3. **Generate Quiz:**

```bash
curl -X POST /api/Quiz/generate \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"topic":"Mathematics","difficulty":"medium","questionCount":5}'
```

---

## 📱 Frontend Examples

### Flutter/Dart

```dart
// Login
final response = await http.post(
  Uri.parse('/api/Auth/Login'),
  headers: {'Content-Type': 'application/json'},
  body: jsonEncode({
    'email': 'user@example.com',
    'password': 'password123',
  }),
);
final token = jsonDecode(response.body)['token'];

// Generate Quiz
final quizResponse = await http.post(
  Uri.parse('/api/Quiz/generate'),
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

## 🔒 Security

- Use HTTPS in production
- Store JWT tokens securely
- Validate all inputs
- Implement rate limiting
- Configure CORS properly

---

## 📈 Rate Limits

- Auth endpoints: 10/min
- Quiz generation: 5/min
- Vision analysis: 20/min
- General: 100/min
