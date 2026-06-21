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
- [Implemented Features](#implemented-features)
- [Project Structure](#project-structure)
- [Getting Started](#getting-started)
- [Development](#development)
- [Contributing](#contributing)

---

## 🎯 Project Overview

**TrustCircle** is an AI-powered mobile application designed to help users manage and strengthen their relationships through daily check-ins, trust scoring, and AI-driven insights. The app leverages advanced AI models and voice technology to provide meaningful relationship health metrics and personalized recommendations.

### Key Features (Implemented)
- 🔐 Secure authentication with Firebase
- 💬 Daily pulse check-ins and gratitude tracking
- 🤖 AI-powered insights using Gemini and local Melange models
- 🎤 Voice check-in support using Speech-to-Text
- 📊 Trust score calculation and dashboard
- 👥 Circle management (create & join groups)
- 🔔 Smart local push notifications (WhatsApp-style)
- 🤫 Silence detection for inactive users
- 🤝 Resolve Mode with AI conflict resolution guides
- 🚀 **New:** Beautiful 5-page first-time user onboarding walkthrough

---

## ✨ Feature Deep-Dive

### 1. 🚨 Silence Detector (Proactive Support)
- Automatically monitors user activity within circles.
- Triggers a **Silence Alert** if a user hasn't checked in for 3+ days.
- **Circle-Aware UI:** 
  - **Family Circles:** Displays a large, urgent banner urging members to reach out.
  - **Other Circles:** Displays a subtle, compact bubble notification.
- **Smart Copy:** Identifies if the current user is the silent one and dynamically changes the copy to encourage them to check in (e.g., "You — 4 days silent. Your family is waiting to hear from you.").

### 2. 🎤 AI Voice Check-In
- Users can tap the microphone to simply speak their feelings.
- The app uses Natural Language Processing to automatically interpret their emotions and set the "Heard/Respected/Safe/Connected" sliders for them.

### 3. 🤝 Resolve Mode
- Automatically triggers when a circle's overall Trust Score drops below **50%**.
- Generates an **AI Conflict Resolution Guide** using the Gemini API, specifically tailored to the circle's current trust data.
- Guides are formatted beautifully in Markdown, providing actionable advice to repair the relationship.

### 4. 🔔 Smart Notification System
- **Hourly Nudges:** Reminds users to submit their daily pulse starting at a configured time, repeating hourly. Auto-cancels the moment a pulse is submitted.
- **Push Alerts:** Sends immediate system notifications for Silence Alerts and Resolve Mode triggers.

---

## 🤖 Melange AI Integration Plan

As part of the hackathon's requirement for on-device AI functionality, TrustCircle is architected to seamlessly integrate with **Melange AI**. Currently, it uses a simulated on-device heuristic that runs entirely locally, but the app is fully prepped to swap in a real Melange model:

1. **Native Kotlin Compatibility:** The Android app is built using `MainActivity.kt` (Kotlin), ensuring seamless compatibility with Melange's native Android SDKs.
2. **Model Export:** A sentiment analysis model (like DistilBERT) fine-tuned on the Melange platform can be exported as a `.tflite` file.
3. **Integration:** The exported model is placed in `assets/models/melange_sentiment.tflite` and inferred using the `tflite_flutter` package inside the existing `LocalAiService`.
4. **Privacy First:** Because the Melange model runs 100% on-device, users can submit voice/text check-ins even in Airplane Mode. Emotional journal data never leaves the phone.

---

## 👥 Team

### Organization
**Team Name:** Zombie Heart

**GitHub Organization:** [Avi007-debug](https://github.com/Avi007-debug)

### Contributor
**Name:** Avishkar More
**Role:** Sole Developer (Frontend, Backend, AI Integration, UI/UX Architecture)

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

### Backend & Services
- **Backend:** Firebase
- **Database:** Firestore
- **Authentication:** Firebase Auth
- **Messaging:** Local Push Notifications (`flutter_local_notifications`)

### AI & Voice
- **AI Model:** Google Gemini API
- **On-Device AI:** Melange fallback simulated heuristic (Ready for `.tflite` export)
- **Audio Processing:** Speech-to-Text

### Development & Testing
- **IDE:** Android Studio 2024.3
- **Test Device:** OPPO CPH2381 (Android 14, API 34)

---

## 📱 Android Configuration

| Setting | Value |
|---------|-------|
| **Package Name** | com.zombieheart.trustcircle |
| **App Name** | TrustCircle |
| **Target SDK** | Latest available |

---

## ✅ Current Status

**Status:** Hackathon Ready 🚀

### Completed ✨
- [x] Flutter environment setup & verification
- [x] Package name configuration (`com.zombieheart.trustcircle`)
- [x] Authentication and Firebase setup
- [x] Circle creation and management logic
- [x] Daily trust pulse check-ins with sliders
- [x] **New:** Voice Check-In (transcribes speech to auto-set sliders)
- [x] **New:** Silence Detector (banners when members are inactive)
- [x] **New:** Resolve Mode (auto-triggers below 50% trust with Gemini advice)
- [x] **New:** WhatsApp-style notifications (real-time high priority alerts)
- [x] **New:** Melange On-Device architecture ready

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
│   ├── checkin/                # Check-in and Voice features
│   ├── gratitude/              # Gratitude tracking
│   ├── insights/               # AI insights
│   ├── resolve/                # Resolve Mode screens
│   └── profile/                # User profile
├── providers/                  # Riverpod providers
├── routes/                     # Navigation routing
├── services/                   # Business logic (Gemini, Silence, Local AI)
└── widgets/                    # Reusable widgets
```

---

## 🚀 Getting Started

### Prerequisites
- **Flutter:** 3.29.2 (Stable)
- **Dart:** 3.7.2
- **Android Studio:** 2024.3 or later

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/Avi007-debug/TrustCircle.git
   cd TrustCircle
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

---

## 🤝 Contributing

### Getting Started with Development
1. Create a new feature branch: `git checkout -b feature/your-feature-name`
2. Make your changes
3. Commit with clear messages: `git commit -m "Add your feature description"`
4. Push to your branch: `git push origin feature/your-feature-name`
5. Create a Pull Request to `develop` branch

---

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 👨‍💻 Contributor

**Zombie Heart**

- Avishkar More (Sole Developer)

---

**Last Updated:** June 20, 2026  
**Status:** Hackathon Build Complete ✅
