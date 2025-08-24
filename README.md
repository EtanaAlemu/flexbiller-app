# FlexBiller Flutter App

A Flutter application built with clean architecture principles, featuring BLoC state management, dependency injection, secure storage, and a feature-based folder structure.

## 🏗️ Architecture

This app follows Clean Architecture principles with the following layers:

- **Presentation Layer**: UI components, BLoC state management
- **Domain Layer**: Business logic, entities, use cases, repositories
- **Data Layer**: Data sources, models, repository implementations

## 🚀 Features

- **Authentication**: Login/Register with secure token storage
- **Dashboard**: Main app interface with billing management
- **Secure Storage**: Encrypted local storage for sensitive data
- **Network Layer**: HTTP client with authentication interceptors
- **Database**: Secure SQLite database with encryption
- **State Management**: BLoC pattern for predictable state management

## 📁 Project Structure

```
lib/
├── core/
│   ├── constants/          # App constants and configuration
│   ├── errors/            # Error handling classes
│   ├── network/           # Network layer (Dio client)
│   ├── services/          # Core services (storage, database)
│   └── utils/             # Utility functions
├── features/
│   ├── auth/              # Authentication feature
│   │   ├── data/          # Data layer (API, local storage)
│   │   ├── domain/        # Business logic (entities, use cases)
│   │   └── presentation/  # UI components (pages, widgets, BLoC)
│   └── dashboard/         # Dashboard feature
│       └── presentation/  # Dashboard UI
├── injection_container.dart  # Dependency injection setup
└── main.dart              # App entry point
```

## 🛠️ Setup Instructions

### Prerequisites

- Flutter SDK (3.8.1 or higher)
- Dart SDK
- Android Studio / VS Code
- Android SDK (for Android development)
- Xcode (for iOS development, macOS only)

### 1. Clone the Repository

```bash
git clone <repository-url>
cd flexbiller_app
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Generate Code

After adding new injectable dependencies, run:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 4. Run the App

```bash
flutter run
```

## 📱 Dependencies

### Core Dependencies

- **flutter_bloc**: State management
- **get_it**: Dependency injection
- **injectable**: Code generation for DI
- **dio**: HTTP client for network requests
- **flutter_secure_storage**: Secure key-value storage
- **sqflite_sqlcipher**: Encrypted SQLite database
- **equatable**: Value equality for objects
- **json_annotation**: JSON serialization

### Dev Dependencies

- **build_runner**: Code generation
- **injectable_generator**: DI code generation
- **json_serializable**: JSON serialization code generation

## 🔐 Security Features

- **Secure Storage**: Encrypted local storage for sensitive data
- **Database Encryption**: SQLCipher for encrypted SQLite database
- **Token Management**: Secure JWT token storage and refresh
- **Network Security**: HTTPS-only API calls with certificate pinning

## 🎨 UI/UX Features

- **Material Design 3**: Modern Flutter UI components
- **Responsive Layout**: Adapts to different screen sizes
- **Theme Consistency**: Unified color scheme and styling
- **Form Validation**: Real-time input validation
- **Loading States**: Proper loading indicators and error handling

## 🧪 Testing

### Run Tests

```bash
# Unit tests
flutter test

# Widget tests
flutter test test/widget_test.dart

# Integration tests
flutter test integration_test/
```

### Test Structure

- **Unit Tests**: Test business logic and use cases
- **Widget Tests**: Test UI components
- **Integration Tests**: Test complete user flows

## 📊 Build & Deploy

### Android

```bash
# Build APK
flutter build apk

# Build App Bundle
flutter build appbundle
```

### iOS

```bash
# Build iOS app
flutter build ios
```

## 🔧 Configuration

### Environment Variables

The app uses environment-specific configuration:

- **Development**: Local development settings
- **Production**: Production API endpoints and settings

### API Configuration

Update `lib/core/constants/app_constants.dart` to configure:

- Base API URL
- Connection timeouts
- Database settings

## 📚 Additional Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [BLoC Pattern](https://bloclibrary.dev/)
- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Dependency Injection](https://pub.dev/packages/get_it)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🆘 Support

For support and questions:

- Create an issue in the repository
- Contact the development team
- Check the documentation

---

**Note**: This is a development version. Some features may be incomplete or in development.
