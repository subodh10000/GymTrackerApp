# GymTrackerApp 🏋️‍♂️

A smart, AI-powered workout planner designed to create personalized fitness routines and keep you motivated. This app combines a sleek SwiftUI frontend with a powerful Python and Firebase backend to deliver a seamless user experience.

<p align="center">
  <img src="https://raw.githubusercontent.com/subodh10000/GymTrackerApp/main/GymTrackerApp/Assets.xcassets/AppIcon.appiconset/ChatGPT%20Image%20Apr%2017,%202025,%2005_38_58%20PM.png" alt="App Icon" width="200">
</p>

---

## 💡 About The Project

GymTrackerApp is more than just a workout log; it's a personal trainer in your pocket. It addresses the common challenge of creating an effective workout plan by leveraging the power of AI to generate routines tailored to your specific profile and goals. The app also includes social and motivational features to encourage consistency and make fitness a rewarding journey.

[Watch my YouTube Video](https://www.youtube.com/watch?v=rbmAisJO4kg)




### Key Features
* **🤖 AI-Powered Plans:** Creates custom 7-day workout plans based on your age, gender, schedule, and fitness goals.
* **🔥 Motivational Challenges:** Join time-based challenges like the "90 Day Summer Challenge" or the "21 Day Hard Challenge" to compete with friends.
* **🏆 Progress & Ranking:** A GitHub-style commitment tracker visualizes your weekly consistency and ranks you from Bronze to Gold.
* **✅ Track Your Workouts:** Easily check off completed exercises and save your progress.
* **💖 Unique Motivation:** Includes fun, interactive views like "Crush Mode" to give you that extra push.
* **⏱️ Interval Timer:** A built-in timer for high-intensity interval training (HIIT) sessions.

---

## 🛠️ Built With

This project is a full-stack application utilizing modern technologies for both the mobile client and the server-side logic.

* **Frontend:**
    * [SwiftUI](https://developer.apple.com/xcode/swiftui/) - The declarative UI framework for building modern iOS apps.
* **Backend:**
    * [Python](https://www.python.org/) - For all server-side logic.
    * [Firebase Cloud Functions](https://firebase.google.com/docs/functions) - For creating serverless backend endpoints.
* **Database:**
    * [Cloud Firestore](https://firebase.google.com/docs/firestore) - A NoSQL database for storing user data, workout plans, and social features in real-time.
* **AI:**
    * [Google Gemini API](https://ai.google.dev/) - For generating the intelligent workout plans.

---

## 🚀 Getting Started

To get a local copy up and running, follow these steps.

### Prerequisites

* **Xcode** (Latest Version)
* **Python 3.11+**
* **Firebase Account** & **Firebase CLI**
* **Google Cloud Account** (for Gemini API Key)

### Installation

1.  **Clone the Repository**
    ```sh
    git clone [https://github.com/subodh10000/GymTrackerApp.git](https://github.com/subodh10000/GymTrackerApp.git)
    cd GymTrackerApp
    ```

2.  **Frontend Setup (iOS App)**
    * Navigate to the `ios-app` folder (or your main project folder).
    * Open the `.xcodeproj` or `.xcworkspace` file in Xcode.
    * Add the required Swift Packages in Xcode (e.g., `FirebaseFirestore`, `FirebaseAuth`).
    * Build and run the project on a simulator or a physical device.

3.  **Backend Setup (Firebase)**
    * Navigate to the `firebase-backend` directory.
    * Create and activate a Python virtual environment:
        ```sh
        python3 -m venv venv
        source venv/bin/activate
        ```
    * Install the required dependencies:
        ```sh
        pip install -r requirements.txt
        ```
    * **Configure Firebase:**
        * Place your `serviceAccountKey.json` file inside the `firebase-backend/functions` directory. **IMPORTANT:** 
    * **Configure API Keys:**
        * You'll need to set up your Gemini API key as an environment variable or a secret in your Firebase project.
    * **Deploy the functions:**
        ```sh
        firebase deploy --only functions
        ```

---

## 📂 Project Structure

The repository is organized into two main parts: the iOS frontend and the Python backend.
