# Privacy Policy for GymTrackerApp

**Last Updated: [DATE]**

## Introduction

GymTrackerApp ("we," "our," or "us") is committed to protecting your privacy. This Privacy Policy explains how we collect, use, and safeguard your information when you use our mobile application (the "App").

## Information We Collect

### Personal Information
When you create a profile in the App, we collect the following information:
- **Name**: To personalize your experience
- **Age**: To customize workout plans
- **Gender**: To tailor exercise recommendations
- **Height**: Measured in inches, used for fitness calculations
- **Weight**: Measured in pounds, used for fitness calculations
- **Fitness Level**: Your current fitness experience (Beginner, Intermediate, Advanced)
- **Fitness Goals**: Your primary objective (Muscle Gain, Fat Loss, Strength, Endurance, Flexibility)
- **Workout Preferences**: Days per week, session duration, and preferred workout environment

### Automatically Collected Information
- **Workout History**: Dates and details of completed workouts
- **Personal Records**: Exercise achievements and records you log
- **App Usage Data**: Features you use within the App

## How We Use Your Information

We use the information we collect to:
1. **Generate Personalized Workout Plans**: Your profile information is sent to our secure backend service to create customized workout routines tailored to your goals and fitness level.
2. **Track Your Progress**: Store your workout history and personal records locally on your device.
3. **Improve Your Experience**: Provide relevant features and content based on your preferences.
4. **Send Notifications**: With your permission, send workout reminders and hydration alerts.

## Data Storage and Security

### Local Storage
- All your personal data, workout history, and records are stored **locally on your device** using iOS UserDefaults.
- Your data never leaves your device except when generating your initial workout plan.
- You can reset all data at any time through the App settings.

### Network Transmission
- When you create your profile, your information is securely transmitted to our backend service (hosted on Google Cloud Run) to generate your personalized workout plan.
- This transmission uses HTTPS encryption.
- After your workout plan is generated, your profile data is not stored on our servers.
- If the network request fails, the App will use a default workout plan stored locally.

## Third-Party Services

### Backend Service
- We use a secure backend service (Google Cloud Run) to generate personalized workout plans.
- Your profile data is sent to this service only during initial plan generation.
- The service does not store your personal information after generating your workout plan.

### Analytics
- [If you add analytics later, describe it here]
- Currently, we do not use third-party analytics services.

## Data Sharing

We do **not** sell, trade, or rent your personal information to third parties. We do not share your data except:
- When necessary to generate your workout plan (sent to our backend service)
- If required by law or legal process

## Your Rights

You have the right to:
- **Access Your Data**: All your data is stored locally on your device
- **Delete Your Data**: Use the "Reset App" feature in the App settings to delete all stored information
- **Opt-Out of Notifications**: Disable notifications in your device settings
- **Stop Using the App**: Uninstall the App at any time to remove all local data

## Children's Privacy

GymTrackerApp is not intended for children under the age of 13. We do not knowingly collect personal information from children under 13. If you are a parent or guardian and believe your child has provided us with personal information, please contact us immediately.

## Changes to This Privacy Policy

We may update this Privacy Policy from time to time. We will notify you of any changes by:
- Posting the new Privacy Policy in the App
- Updating the "Last Updated" date

You are advised to review this Privacy Policy periodically for any changes.

## Data Retention

- Your data is stored locally on your device until you:
  - Delete it using the "Reset App" feature
  - Uninstall the App
- We do not retain your data on our servers after workout plan generation.

## Security Measures

We implement appropriate technical and organizational measures to protect your information:
- HTTPS encryption for all network transmissions
- Local-only data storage (no cloud backup of personal data)
- Secure backend service with industry-standard security practices

## Contact Us

If you have any questions about this Privacy Policy or our data practices, please contact us at:

**Email**: [YOUR_EMAIL_ADDRESS]
**Website**: [YOUR_WEBSITE_URL]

## Consent

By using GymTrackerApp, you consent to this Privacy Policy and agree to its terms.

---

## Quick Summary

- ✅ Your data is stored **locally on your device**
- ✅ Data is only sent to our server to generate your workout plan
- ✅ We don't store your data on our servers
- ✅ You can delete all data anytime using "Reset App"
- ✅ We don't sell or share your data with third parties
- ✅ All network transmissions are encrypted (HTTPS)

---

**Note for App Store Submission:**
1. Replace [DATE] with current date
2. Replace [YOUR_EMAIL_ADDRESS] with your contact email
3. Replace [YOUR_WEBSITE_URL] with your website (if you have one)
4. Host this on a publicly accessible URL
5. Update the URL in Info.plist

