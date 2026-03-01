# Hospital Digital Platform - MVP

This project is a locally runnable Minimum Viable Product (MVP) of a Hospital Digital Platform. It features a Flutter-based frontend for both web and mobile, and a backend built with Spring Boot microservices and MongoDB.

## 🎯 Project Goal

The primary objective of this MVP is to demonstrate core functionality in a local environment. It simulates the interactions between a frontend application and a set of backend microservices, complete with a simple login flow and data fetching.

## ⚙️ Tech Stack

- **Frontend**: Flutter & Flutter Web
- **Backend**: Spring Boot Microservices
- **API Gateway**: Spring Cloud Gateway
- **Database**: MongoDB
- **Build Tool**: Maven

## 🧱 Project Structure

```
hospital-digital-platform/
├── backend/
│   ├── pom.xml
│   ├── gateway-service/         (Port 8080)
│   ├── auth-service/            (Port 8081)
│   ├── patient-service/         (Port 8082)
│   ├── record-service/          (Port 8083)
│   ├── notification-service/
│   └── common-libs/
└── frontend/
    └── flutter_app/
```

### Backend File Structure

```
backend/
├── pom.xml                   # Parent POM for all backend modules
├── gateway-service/
│   └── src/main/resources/application.yml
├── auth-service/
│   └── src/main/java/com/hospital/auth/
│       ├── AuthApplication.java
│       └── AuthController.java
├── patient-service/
│   └── src/main/java/com/hospital/patient/
│       ├── PatientApplication.java
│       └── PatientController.java
└── record-service/
    └── src/main/java/com/hospital/record/
        ├── RecordApplication.java
        └── RecordController.java
```

### Frontend File Structure

```
frontend/flutter_app/
└── lib/
    ├── main.dart               # Main application entry point with demo switcher
    ├── models/                 # Data models (User, Patient, Record)
    │   ├── user_model.dart
    │   ├── patient_model.dart
    │   └── record_model.dart
    ├── screens/
    │   ├── admin/              # Admin Panel UI
    │   ├── doctor/             # Doctor Portal UI
    │   └── patient/            # Patient App UI
    ├── services/
    │   ├── api_service.dart      # Mock data service
    │   ├── auth_service.dart     # Handles login/registration logic
    │   └── patient_service.dart  # Handles patient data fetching
    └── widgets/                # Reusable UI components
```

## 🚀 Running the MVP Locally

To run the full application, you will need to start the backend microservices and the frontend application.

### Prerequisites

- Java 11 or newer
- Maven
- Flutter SDK
- MongoDB running locally on `localhost:27017`

### 1. Run the Backend Microservices

MongoDB must be running locally on `localhost:27017`.

The simplest way to start all backend services (each in its own background process) is:

```sh
bash scripts/run-local.sh
```

This starts:
- **Gateway Service** on port `8080`
- **Auth Service** on port `8081`
- **Patient Service** on port `8082`
- **Record Service** on port `8083`
- **Notification Service** on port `8084`

### 2. Run the Frontend Application

Navigate to the `flutter_app` directory, get the dependencies, and run the application.

```sh
cd frontend/flutter_app
flutter pub get
flutter run
```

To run the application in a Chrome browser (for the web version):

```sh
flutter run -d chrome
```

The application will launch with a demo switcher that allows you to toggle between the Patient, Doctor, and Admin views.

## Quick run (local)

Prerequisites
- Java 11+ (check with `java -version`)
- Maven
- Flutter SDK (for frontend)
- **MongoDB running locally on `localhost:27017`**

### Start backend microservices (convenience script)

1. Start MongoDB locally (must already be running before the script).
2. Run:

```sh
bash scripts/run-local.sh
```

This starts the backend services in order with a short delay between each startup:
- Gateway Service (8080)
- Auth Service (8081)
- Patient Service (8082)
- Record Service (8083)
- Notification Service (8084)

You can verify:
- `http://localhost:8080/health`
- `http://localhost:8080/record/health`

Java/Eclipse note
- Project .settings indicate Java 20 compiler compliance in some IDE metadata; for portability prefer Java 11+ for local runs unless you intentionally target Java 21. Update IDE config or the README to match your target Java version.
