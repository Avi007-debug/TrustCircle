# TrustCircle 

> **AI-Powered Relationship Health & Trust Management App**
>
> *An intelligent companion for building and maintaining strong relationships*

<div align="center">

[![GitHub Repository](https://img.shields.io/badge/GitHub-TrustCircle-blue?logo=github)](https://github.com/Avi007-debug/TrustCircle)
[![Flutter](https://img.shields.io/badge/Flutter-3.29.2-blue?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.7.2-blue?logo=dart)](https://dart.dev)
[![License](https://img.shields.io/badge/License-MIT-green)](LICENSE)

**Built by [Zombie Heart Team](https://github.com/Avi007-debug) | Hackathon Ready 🚀**

</div>

---

## 🎥 Demo Video

Watch the complete feature walkthrough and see TrustCircle in action!

[![TrustCircle App Demo](https://img.youtube.com/vi/cwLbEZ66fbM/hqdefault.jpg)](https://youtu.be/cwLbEZ66fbM "TrustCircle App Demo - Click to Watch!")

---

## 📋 Quick Navigation

- [Overview](#-project-overview)
- [Features](#-core-features) 
- [AI Architecture](#-hybrid-ai-architecture)
- [Tech Stack](#-tech-stack)
- [Project Structure](#-project-structure)
- [Setup Guide](#-getting-started)
- [Contributing](#-contributing)

---

## 🎯 Project Overview

**TrustCircle** is an AI-powered mobile application designed to help users manage and strengthen their relationships through daily check-ins, trust scoring, and AI-driven insights. The app leverages advanced AI models and voice technology to provide meaningful relationship health metrics and personalized recommendations.

### ✨ Why TrustCircle?

- **Real-Time Relationship Monitoring** – Daily pulse check-ins measure relationship health
- **AI-Powered Intelligence** – Hybrid cloud & on-device AI for insights and guidance
- **Privacy First** – Local AI option keeps your emotional data on your device
- **Proactive Support** – Automatic detection of relationship struggles
- **Voice-First Design** – Speak your feelings, AI understands your emotions

---

## 🚀 Core Features

### 🎤 Voice Check-In with AI Interpretation
Speak naturally about your feelings. TrustCircle's AI automatically interprets your emotions and sets your relationship metrics (Heard, Respected, Safe, Connected).

### 🎨 Beautiful Onboarding Walkthrough
New users are guided through a stunning 5-page onboarding experience designed to explain core concepts and get them started in minutes.

### 📊 Trust Score Dashboard
Real-time visualization of relationship health across all your circles with interactive charts and historical trends.

### 👥 Circle Management
Create and join groups, invite loved ones, and monitor the collective health of your relationships.

### 🤖 AI-Powered Insights
- **Cloud AI (Gemini):** Advanced natural language understanding and recommendations
- **Local AI (Zetic MLange):** Private on-device inference with TinyLlama & Whisper

### 🨤 Silence Detector
Automatically alerts you when loved ones haven't checked in for 3+ days:
- **Family Circles:** Large, urgent banners to encourage outreach
- **Other Circles:** Subtle notifications for gentle reminders
- **Smart Detection:** Identifies if YOU're the silent one and adjusts messaging

### 🤝 Resolve Mode
When a circle's trust score drops below 50%, AI automatically generates a **Conflict Resolution Guide** with actionable advice to repair relationships.

### 🔔 Smart Notification System
- **Hourly Nudges:** Reminder to submit daily pulse (auto-cancels when submitted)
- **Immediate Alerts:** Push notifications for Silence Alerts and Resolve Mode triggers

### 💬 Gratitude Tracking
Capture moments of connection and appreciation with your circles.

### 🔐 Secure Authentication
Firebase-backed authentication with Google Sign-In support.

---

## 🤖 Hybrid AI Architecture

TrustCircle features a powerful **dual AI system** for maximum flexibility:

### Cloud AI (Gemini)
- Advanced language understanding and conflict resolution guides
- Requires internet connectivity
- Ideal for complex emotional analysis

### On-Device AI (Zetic MLange)
- **True Offline Capability:** Run models locally on your Android device
- **100% Privacy:** Your emotional data never leaves your phone
- **Models Included:**
  - `meta/TinyLlama-1.1B-Chat-v1.0` – Text analysis
  - `OpenAI/whisper-tiny-decoder` – Voice transcription
- **Privacy Toggle:** Users can explicitly enable "Use On-Device AI for Privacy"
- **Automatic Fallback:** Switches to local AI when internet is unavailable

### Smart Syncing
- Voice analysis happens offline when configured
- Pulse submissions sync to Firestore automatically when reconnected
- Offline pulse submissions are cached and synced on connectivity

---

## 👥 Team

| Role | Developer |
|------|-----------|
| **Organization** | Zombie Heart |
| **Lead Developer** | Avishkar More |
| **Contributions** | Frontend, Backend, AI Integration, UI/UX |

---

## 🛠️ Tech Stack

### 📱 Frontend
| Component | Technology |
|-----------|-----------|
| Framework | Flutter 3.29.2 |
| Language | Dart 3.7.2 |
| State Management | Riverpod |
| Navigation | GoRouter |
| UI Framework | Material Design |
| Typography | Google Fonts |
| Vector Graphics | Flutter SVG |

### ☁️ Backend & Services
| Service | Technology |
|---------|-----------|
| Backend | Firebase |
| Database | Firestore |
| Authentication | Firebase Auth + Google Sign-In |
| Push Notifications | flutter_local_notifications |

### 🤖 AI & Voice
| Component | Technology |
|-----------|-----------|
| Cloud AI | Google Gemini API |
| On-Device AI | Zetic MLange (TinyLlama, Whisper) |
| Voice Recognition | Speech-to-Text |

### 🔧 Development
| Tool | Version |
|------|---------|
| IDE | Android Studio 2024.3 |
| Test Device | OPPO CPH2381 (Android 14, API 34) |

### 📦 Android Configuration
- **Package Name:** `com.zombieheart.trustcircle`
- **App Name:** TrustCircle
- **Target SDK:** Latest available
- **Min SDK:** API 21

---

## 📂 Project Structure

```
lib/
├── main.dart                    # Application entry point
│
├── core/
│   ├── constants/              # App-wide constants and configurations
│   ├── theme/                  # Theme and styling
│   └── utils/                  # Utility functions and helpers
│
├── data/
│   ├── models/                 # Data models and entities
│   └── repositories/           # Data access layer
│
├── features/
│   ├── splash/                 # Splash screen
│   ├── auth/                   # Authentication flows
│   ├── onboarding/             # First-time user walkthrough (5 pages)
│   ├── home/                   # Dashboard and home screen
│   ├── circles/                # Circle management
│   ├── checkin/                # Daily pulse check-ins
│   ├── voice/                  # Voice check-in support
│   ├── gratitude/              # Gratitude tracking
│   ├── insights/               # AI-powered insights
│   ├── resolve/                # Resolve Mode (conflict resolution)
│   └── profile/                # User profile and settings
│
├── providers/                  # Riverpod state providers
├── routes/                     # GoRouter navigation configuration
│
├── services/                   # Business logic & integrations
│   ├── ai_router_service.dart         # Cloud/Local AI routing
│   ├── gemini_service.dart            # Gemini API integration
│   ├── local_ai_service.dart          # On-device ML inference
│   ├── voice_service.dart             # Voice transcription
│   ├── silence_detector_service.dart  # Inactivity detection
│   ├── notification_service.dart      # Push notifications
│   ├── auth_service.dart              # Firebase authentication
│   └── firestore_service.dart         # Firestore data operations
│
└── widgets/                    # Reusable UI components
```

---

## ✅ Status

**Current Status:** Hackathon Ready 🚀

### Completed Features ✨
- [x] Flutter environment and package configuration
- [x] Firebase authentication with Google Sign-In
- [x] Circle creation, joining, and management
- [x] Daily trust pulse check-ins with interactive sliders
- [x] Voice-to-text check-in with auto-slider interpretation
- [x] Silence detection with adaptive UI notifications
- [x] Resolve Mode with AI-powered conflict resolution guides
- [x] Hybrid AI architecture (Cloud + On-Device)
- [x] Privacy-focused on-device AI option
- [x] Offline pulse submission caching with auto-sync
- [x] Beautiful 5-page onboarding walkthrough
- [x] Responsive dashboard with charts and analytics
- [x] Professional UI/UX polish

---

## 🚀 Getting Started

### Prerequisites
Before you begin, ensure you have the following installed:

```
✓ Flutter 3.29.2 (Stable Channel)
✓ Dart 3.7.2
✓ Android Studio 2024.3 or later
✓ Git
```

### Quick Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/Avi007-debug/TrustCircle.git
   cd TrustCircle
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase** (if needed)
   - Update `lib/firebase_options.dart` with your Firebase credentials
   - Ensure `.env` file is properly configured

4. **Run the application**
   ```bash
   flutter run
   ```

### Optional: Configure Environment Variables
Create a `.env` file in the project root with your API keys:
```env
GEMINI_API_KEY=your_gemini_api_key_here
```

---

## 👨‍💻 Development

### Code Style & Standards
- Follow Dart formatting with `dart format`
- Use meaningful variable and function names
- Write concise comments for complex logic
- Keep UI components modular and reusable

### Branch Naming Convention
- Feature branches: `feature/your-feature-name`
- Bug fixes: `bugfix/issue-description`
- Hotfixes: `hotfix/critical-issue`

### Making Changes
1. Create a feature branch from `develop`
2. Make your changes with clear, atomic commits
3. Ensure the app builds without errors: `flutter build apk`
4. Push to your branch and create a Pull Request
5. Request reviews before merging

---

## 🤝 Contributing

We welcome contributions! Here's how to get involved:

1. **Fork** the repository
2. **Create** a feature branch: `git checkout -b feature/your-feature`
3. **Commit** with clear messages: `git commit -m "Add feature description"`
4. **Push** to your branch: `git push origin feature/your-feature`
5. **Create** a Pull Request to the `develop` branch

Please ensure your code:
- Follows the project's code style
- Includes relevant comments
- Doesn't break existing functionality
- Is tested on a physical or emulated device

---

## 📄 License

This project is licensed under the **MIT License** - see the [LICENSE](LICENSE) file for full details.

---

## 📞 Contact & Support

For questions or support:
- **Organization:** [Zombie Heart on GitHub](https://github.com/Avi007-debug)
- **Lead Developer:** Avishkar More
- **Repository:** [TrustCircle GitHub](https://github.com/Avi007-debug/TrustCircle)

---

<div align="center">

### Made with ❤️ by Zombie Heart Team

**Last Updated:** June 21, 2026  
**Status:** Hackathon Build Complete ✅

[⬆ Back to top](#trustcircle-💙)

</div>
