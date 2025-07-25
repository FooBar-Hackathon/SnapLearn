# 📸 SnapLearn

SnapLearn is an AI-powered educational mobile app that transforms real-world images into bite-sized learning experiences. Users can take or upload a photo, and SnapLearn will recognize objects and generate personalized quizzes to enhance understanding and critical thinking.

## 🚀 Tech Stack

### 🔧 Backend
- **ASP.NET Core** – Web API for object detection and quiz generation
- **Entity Framework Core** – ORM for database interactions
- **YOLO (You Only Look Once)** – Real-time object detection via YOLOv5 ONNX model
- **Tesseract OCR** – For multilingual text recognition in images

### 💡 Frontend
- **Flutter** – Cross-platform mobile app framework (Android/iOS/Web)

---

## 🧩 Dependencies & Credits

We would like to acknowledge and give credit to the amazing open-source libraries used in this project:

- [NickSwardh/YoloDotNet](https://github.com/NickSwardh/YoloDotNet)  
  Used for YOLO-based object detection via ONNX models.

- [charlesw/tesseract](https://github.com/charlesw/tesseract)  
  .NET wrapper for Tesseract OCR engine.

- [dotnet/EntityFramework.Docs](https://github.com/dotnet/EntityFramework.Docs)  
  Documentation and samples for Entity Framework Core.

- [tesseract-ocr/tessdata](https://github.com/tesseract-ocr/tessdata)  
  Trained language data files for Tesseract OCR.

---

## 📱 Features

- Snap or upload a photo to detect objects
- Generate 3 fun and educational facts about each object
- Get 3 micro-quizzes to reinforce your knowledge
- Supports multiple languages for text recognition
- Cross-platform mobile support via Flutter

---

## 🛠 Setup & Installation

### Backend (ASP.NET Core)

1. Clone the repo
2. Restore NuGet packages
3. Add YOLO ONNX model and tessdata into appropriate directories
4. Run the API using:
   ```bash
   dotnet run
   ```

### Frontend (Flutter)

1. Navigate to the `flutter` directory
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Run the app:
   ```bash
   flutter run
   ```

---

## 📄 License

This project is licensed under the MIT License.
Let me know if you'd like to add sections like screenshots, roadmap, or API docs.
