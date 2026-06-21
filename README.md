# TrustCircle

> **AI-Powered Relationship Health & Trust Management App**
> 
> Built by **Zombie Heart** Team

[![GitHub Repository](https://img.shields.io/badge/GitHub-TrustCircle-blue?logo=github)](https://github.com/Avi007-debug/TrustCircle)
[![Flutter](https://img.shields.io/badge/Flutter-3.29.2-blue?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.7.2-blue?logo=dart)](https://dart.dev)
[![License](https://img.shields.io/badge/License-MIT-green)](LICENSE)

---

## 🎥 Demo Video

[![TrustCircle Demo Video](https://img.shields.io/badge/YouTube-Watch_Demo-red?logo=youtube&style=for-the-badge)](https://www.youtube.com/watch?v=placeholder)

*(Replace `https://www.youtube.com/watch?v=placeholder` with the actual video link once uploaded)*

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

## 🤖 Hybrid AI Architecture (Cloud + On-Device)

TrustCircle now features a robust **Hybrid AI Architecture** allowing users to seamlessly transition between Cloud AI (Gemini) and On-Device AI (Zetic MLange + TinyLlama + Whisper).

### 1. Zetic MLange On-Device Integration
- **True Offline Inference:** Integrated `zetic_mlange` to download and run the `meta/TinyLlama-1.1B-Chat-v1.0` and `OpenAI/whisper-tiny-decoder` models natively on the user's Android hardware.
- **Privacy First:** Users can explicitly toggle **"Use On-Device AI for Privacy"** in the UI. When enabled, their voice transcriptions are processed 100% locally by TinyLlama, guaranteeing their emotional data never leaves the phone for analysis.
- **Offline Fallback:** If the user loses internet connection, the `AiRouterService` automatically intercepts the voice check-in and routes it to the local Melange models.

### 2. Smart Submission Syncing
- While the AI grading can happen completely offline for privacy or connectivity reasons, submitting the pulse to the circle still requires an internet connection (Firestore).
- **Offline Caching:** If a user submits a pulse while offline, TrustCircle saves it locally to the device and displays a notification. The pulse is then automatically synced to the cloud the moment the device regains connectivity.

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
- **On-Device AI:** Zetic MLange (TinyLlama & Whisper) + Offline Heuristic
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
- [x] **New:** Hybrid AI Architecture (Gemini Cloud + Zetic Melange On-Device)
- [x] **New:** Privacy toggle to force local inference
- [x] **New:** Offline Submission Caching (Auto-sync)
- [x] **New:** UI/UX Polish (Responsive Graph Tabs, Professional Profile Settings)

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

**Last Updated:** June 21, 2026  
**Status:** Hackathon Build Complete ✅
