# TrustCircle

> **AI-Powered Relationship Health & Trust Management App**
> 
> Built by **Zombie Heart** Team

[![GitHub Repository](https://img.shields.io/badge/GitHub-TrustCircle-blue?logo=github)](https://github.com/Avi007-debug/TrustCircle)
[![Flutter](https://img.shields.io/badge/Flutter-3.29.2-blue?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.7.2-blue?logo=dart)](https://dart.dev)
[![License](https://img.shields.io/badge/License-MIT-green)](LICENSE)

---

## 📋 Table of Contents

- [Project Overview](#project-overview)
- [Team](#team)
- [Tech Stack](#tech-stack)
- [Current Status](#current-status)
- [Project Structure](#project-structure)
- [Getting Started](#getting-started)
- [Development](#development)
- [Roadmap](#roadmap)
- [Contributing](#contributing)

---

## 🎯 Project Overview

**TrustCircle** is an AI-powered mobile application designed to help users manage and strengthen their relationships through daily check-ins, trust scoring, and AI-driven insights. The app leverages advanced AI models and voice technology to provide meaningful relationship health metrics and personalized recommendations.

### Key Features (Planned)
- 🔐 Secure authentication with Firebase
- 💬 Daily pulse check-ins and gratitude tracking
- 🤖 AI-powered insights using Gemini and Melange
- 🎤 Voice check-in support via Agora
- 📊 Trust score calculation and dashboard
- 👥 Circle management (create & join groups)
- 🔔 Smart notifications and reminders

---

## 👥 Team

### Organization
**Team Name:** Zombie Heart

**GitHub Organization:** [Avi007-debug](https://github.com/Avi007-debug)

### Team Members & Responsibilities

| Role | Name | Responsibilities |
|------|------|------------------|
| **Frontend Lead** | Avishkar | Flutter Architecture, Riverpod, GoRouter, UI/UX, Dashboard, Check-in & Gratitude Screens |
| **Backend Developer** | TBD | Firebase, Firestore, Authentication, Security Rules, Cloud Functions, Notifications |
| **AI Developer** | TBD | Gemini Integration, Melange, Agora Setup, Silence Detection, AI Insights Engine |

---

## 🛠️ Tech Stack

### Frontend
- **Framework:** Flutter 3.29.2 (Stable)
- **Language:** Dart 3.7.2
- **State Management:** Riverpod
- **Navigation:** GoRouter
- **UI Components:** Flutter Material
- **Fonts:** Google Fonts
- **Assets:** Flutter SVG

### Backend & Services (To Be Implemented)
- **Backend:** Firebase
- **Database:** Firestore
- **Authentication:** Firebase Auth
- **Cloud Functions:** Firebase Functions
- **Messaging:** Firebase Cloud Messaging

### AI & Voice (To Be Implemented)
- **AI Model:** Google Gemini API
- **On-Device AI:** Gemini Nano
- **Integration Framework:** Melange
- **Voice Platform:** Agora (Real-time Communication)
- **Audio Processing:** Silence Detection

### Development & Testing
- **IDE:** Android Studio 2024.3
- **Android SDK:** Fully configured
- **Build Tools:** Latest
- **NDK:** 30.0.14904198
- **Test Device:** OPPO CPH2381 (Android 14, API 34)

---

## 📱 Android Configuration

| Setting | Value |
|---------|-------|
| **Package Name** | com.zombieheart.trustcircle |
| **App Name** | TrustCircle |
| **Min SDK** | As per project requirements |
| **Target SDK** | Latest available |
| **Device Tested** | OPPO CPH2381 (Android 14) |

---

## ✅ Current Status

### Completed ✨
- [x] Flutter environment setup & verification
- [x] Android SDK & toolchain configuration
- [x] Physical device debugging setup
- [x] Project build & deployment pipeline
- [x] Package name configuration (`com.zombieheart.trustcircle`)
- [x] GitHub repository creation & integration
- [x] Core dependencies installation (Riverpod, GoRouter, Google Fonts, Flutter SVG)
- [x] Project folder architecture
- [x] Default Flutter counter app removed
- [x] TrustCircle branding implementation

### Version
**Foundation Setup Complete** - Ready for Phase 1 implementation

### Application Status
✅ **Successfully builds and runs on physical device**
- Displays "TrustCircle" on dark background
- Package rename verified
- Android configuration verified
- Build pipeline operational

---

## 📂 Project Structure

```
lib/
├── main.dart                    # App entry point
├── core/
│   ├── constants/              # App-wide constants
│   ├── theme/                  # Theme configuration
│   └── utils/                  # Utility functions
├── data/
│   ├── models/                 # Data models
│   └── repositories/           # Data repositories
├── features/
│   ├── splash/                 # Splash screen
│   ├── auth/                   # Authentication
│   ├── home/                   # Home dashboard
│   ├── checkin/                # Check-in features
│   ├── gratitude/              # Gratitude tracking
│   ├── insights/               # AI insights
│   └── profile/                # User profile
├── providers/                  # Riverpod providers
├── routes/                     # Navigation routing
├── services/                   # Business logic services
└── widgets/                    # Reusable widgets
```

---

## 🚀 Getting Started

### Prerequisites
- **Flutter:** 3.29.2 (Stable)
- **Dart:** 3.7.2
- **Android Studio:** 2024.3 or later
- **Android SDK:** API 30+
- **Physical/Virtual Device** with Android 10+

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/Avi007-debug/TrustCircle.git
   cd TrustCircle
   ```

2. **Verify Flutter setup**
   ```bash
   flutter doctor
   ```

3. **Install dependencies**
   ```bash
   flutter pub get
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

5. **Build APK (optional)**
   ```bash
   flutter build apk --release
   ```

---

## 🔄 Development Workflow

### Branch Strategy

```
main (Stable)
  └── develop (Active Development)
        ├── feature/auth
        ├── feature/firebase
        ├── feature/checkin
        ├── feature/gratitude
        ├── feature/voice-checkin
        ├── feature/ai-insights
        └── ... (more feature branches)
```

**Rules:**
- ⛔ No direct commits to `main`
- ✅ All development happens on `develop`
- ✅ Feature branches created from `develop`
- ✅ Pull requests required for merging

### Current Installed Packages
- `flutter_riverpod` - State management
- `go_router` - Navigation
- `google_fonts` - Typography
- `flutter_svg` - SVG asset support

---

## 📋 Roadmap

### Phase 1: App Foundation 🏗️
- [ ] Create `develop` branch
- [ ] Setup `ProviderScope` (Riverpod root)
- [ ] Implement app theme
- [ ] Create splash screen
- [ ] Setup GoRouter navigation
- [ ] Define route constants

### Phase 2: Authentication 🔐
- [ ] Firebase project setup
- [ ] FlutterFire CLI configuration
- [ ] Firebase authentication
- [ ] Login screen UI
- [ ] Signup screen UI
- [ ] Session management

### Phase 3: Core Features 🎯
- [ ] Circle creation & management
- [ ] Join circle functionality
- [ ] Daily pulse check-ins
- [ ] Trust score calculation
- [ ] Main dashboard

### Phase 4: Advanced Features 🤖
- [ ] Gratitude tracking system
- [ ] AI insights engine (Gemini)
- [ ] Voice check-in support (Agora)
- [ ] Silence detection
- [ ] Cloud functions

### Phase 5: Refinement & Launch 🚀
- [ ] User testing
- [ ] Performance optimization
- [ ] Security audit
- [ ] App store preparation
- [ ] Public release

---

## ⚠️ Not Yet Implemented

### Firebase Integration
- Firebase project setup
- Firestore database
- Firebase authentication
- Cloud functions
- Firebase messaging

### AI & Voice Features
- Gemini API integration
- Gemini Nano (on-device)
- Melange framework
- Agora voice setup
- Silence detection

### Core Business Logic
- Trust score calculation algorithm
- Pulse check-in system
- Gratitude system backend
- Insights engine
- Notification system

---

## 🔗 Important Links

- **Repository:** https://github.com/Avi007-debug/TrustCircle
- **Flutter Docs:** https://flutter.dev/docs
- **Dart Docs:** https://dart.dev/guides
- **Firebase Docs:** https://firebase.google.com/docs
- **Riverpod Docs:** https://riverpod.dev
- **GoRouter Docs:** https://pub.dev/packages/go_router

---

## 📖 Documentation

For detailed documentation on specific features or modules, refer to the relevant feature folder's README (to be created as implementation progresses).

---

## 🤝 Contributing

### Getting Started with Development
1. Create a new feature branch: `git checkout -b feature/your-feature-name`
2. Make your changes
3. Commit with clear messages: `git commit -m "Add your feature description"`
4. Push to your branch: `git push origin feature/your-feature-name`
5. Create a Pull Request to `develop` branch

### Code Style
- Follow [Dart style guide](https://dart.dev/guides/language/effective-dart/style)
- Format code: `dart format lib/`
- Analyze: `dart analyze`

---

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 👨‍💻 Authors

**Zombie Heart Team**

- Lead: Avishkar (Frontend)
- To be added: Backend Developer
- To be added: AI Developer

---

## 📞 Contact & Support

For questions or support, please:
1. Check existing GitHub issues
2. Create a new GitHub issue with detailed description
3. Contact the team lead

---

**Last Updated:** June 14, 2026  
**Status:** Foundation Setup Complete ✅
