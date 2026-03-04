# GymTrackerApp 🏋️‍♂️

**Copyright © 2025 Subodh Kathayat. All rights reserved.**

A smart, AI-powered workout planner for iOS that creates personalized fitness routines and keeps you motivated. Available on the App Store.

<p align="center">
  <a href="https://apps.apple.com/us/app/gymtrackerapp/id6753898260">
    <img src="https://developer.apple.com/assets/elements/badges/download-on-the-app-store.svg" alt="Download on the App Store" height="50">
  </a>
</p>

---

## Copyright & License

**Copyright © 2025 Subodh Kathayat. All rights reserved.**

This source code is provided for educational and portfolio purposes only. You may not copy, modify, distribute, or use this code—in whole or in part—for any commercial or non-commercial purpose without prior written permission from the copyright holder.

GymTrackerApp is a published application on the Apple App Store. The app name, branding, and associated assets are proprietary.

---

## About

GymTrackerApp is a personal trainer in your pocket. It generates custom weekly workouts based on your profile—age, gender, goals, schedule, and environment—and helps you stay consistent with streaks, history tracking, and smart reminders.

### Key Features

- **🤖 Personalized Workout Plans** — AI-generated weekly routines with offline fallback
- **🔥 30-Day Challenges** — Abs, Pushups, Pull-Ups, and Face Exercises
- **📈 Weekly Streaks & History** — Track consistency with a Monday–Sunday calendar
- **✅ Exercise Progress** — Mark exercises complete and see per-workout progress
- **🔔 Notifications** — Optional workout, hydration, and sleep reminders (toggle on/off in-app)
- **⏱️ Interval Timer** — Built-in HIIT timer with configurable rounds and rest

---

## Tech Stack

| Layer | Technology |
|-------|------------|
| **iOS App** | SwiftUI, SwiftData |
| **Backend** | Cloud Run (workout generation) |
| **AI** | Google Gemini API |

---

## Getting Started

### Prerequisites

- **Xcode** 15+ (with Swift 5.9+)
- **macOS** (for iOS development)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/subodh10000/GymTrackerApp.git
   cd GymTrackerApp
   ```

2. **Open in Xcode**
   - Open `GymTrackerApp.xcodeproj` in Xcode
   - Build and run on a simulator or device

3. **Backend**
   - Workout generation uses a hosted Cloud Run service
   - The app includes a bundled fallback plan (`hardcode.json`) when the network is unavailable

---

## Project Structure

```
GymTrackerApp/
├── GymTrackerApp/           # Main iOS app
│   ├── App/                 # App entry, ContentView, MainTabView
│   ├── Core/                # Models, Services (Network, Notifications)
│   ├── Features/            # Home, Workouts, Challenges, Profile, Onboarding
│   ├── DesignSystem/        # Theme, styling
│   └── Resources/           # Assets, fallback data
├── firebase-backend/        # Optional Firebase functions
└── Docs/                    # Documentation
```

---

## Contact

**Subodh Kathayat**

- App Store: [GymTrackerApp](https://apps.apple.com/us/app/gymtrackerapp/id6753898260)

---

*Copyright © 2025 Subodh Kathayat. All rights reserved.*
