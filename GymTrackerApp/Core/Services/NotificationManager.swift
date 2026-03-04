//
//  NotificationManager.swift
//  GymTrackerApp
//
//  Created by Subodh Kathayat on 4/17/25.
//

import Foundation
import UserNotifications
import SwiftUI

class NotificationManager {
    static let shared = NotificationManager()

    func requestAuthorization(userManager: UserManager) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                #if DEBUG
                print("✅ Permission granted")
                #endif
                if userManager.notificationsEnabled {
                    self.scheduleAllNotifications()
                }
            } else {
                #if DEBUG
                print("❌ Permission denied")
                #endif
            }
            if let error = error {
                #if DEBUG
                print("❌ Error: \(error.localizedDescription)")
                #endif
            }
        }
    }

    func scheduleAllNotifications() {
        scheduleWorkoutReminder()
        scheduleHydrationReminder()
        scheduleSleepReminder()
    }

    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        #if DEBUG
        print("🔕 All notifications cancelled")
        #endif
    }

    func scheduleWorkoutReminder() {
        let motivationalMessages = [
            "💪 Time to hit the gym and crush your goals!",
            "🚨 Your workout is waiting - let's make today count!",
            "🔥 Your future self will thank you — let's move!",
            "⚡ Quick win: 20 minutes today beats zero.",
            "🥊 That barbell isn't lifting itself.",
            "🔥 Rise up and lift - your future self will thank you!",
            "🧠 Tough day? Show up anyway — even a small workout counts.",
            "💪 Every workout brings you closer to your goals!",
            "🏋️ Consistency is key - let's make today count!",
            "🌟 You've got this! Time to show up for yourself."
        ]

        let chosen = motivationalMessages.randomElement() ?? "💪 Time to train! Let's go!"

        let content = UNMutableNotificationContent()
        content.title = "💪 Time to train"
        content.body = chosen
        content.sound = .default

        var date = DateComponents()
        date.hour = 17
        date.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: true)
        let request = UNNotificationRequest(identifier: "workout_reminder", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                #if DEBUG
                print("❌ Error scheduling workout reminder: \(error.localizedDescription)")
                #endif
            } else {
                #if DEBUG
                print("✅ Workout reminder scheduled for 5:00 PM with message: \(chosen)")
                #endif
            }
        }
    }

    func scheduleHydrationReminder() {
        let hydrationMessages = [
            "💧 Stay hydrated! Your muscles need water to perform.",
            "🥤 Time for a hydration break - your body will thank you!",
            "💧 Don't forget to drink water throughout the day!",
            "🚨 Remember to keep that water bottle close!",
            "🪣 Hydration is key to maintaining your gains. Drink up!",
            "💧 Your body works better when it's well-hydrated!"
        ]

        let content = UNMutableNotificationContent()
        content.title = "💧 Hydration Check"
        content.body = hydrationMessages.randomElement() ?? "Drink some water, please."
        content.sound = .default

        var date = DateComponents()
        date.hour = 20
        date.minute = 30

        let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: true)
        let request = UNNotificationRequest(identifier: "hydration_reminder", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                #if DEBUG
                print("❌ Error scheduling hydration reminder: \(error.localizedDescription)")
                #endif
            } else {
                #if DEBUG
                print("✅ Hydration reminder scheduled for 8:30 PM")
                #endif
            }
        }
    }
    
    func scheduleSleepReminder() {
        let sleepMessages = [
            "😴 Remember to get at least 7 hours of sleep tonight!",
            "🌙 Quality sleep is essential for recovery and gains!",
            "💤 Aim for 7+ hours of sleep for optimal performance!",
            "😴 Your body needs rest to build muscle - get 7 hours!",
            "🌙 Sleep is when your body repairs - aim for 7 hours minimum!",
            "💤 Recovery happens during sleep - get at least 7 hours!"
        ]

        let content = UNMutableNotificationContent()
        content.title = "😴 Sleep Reminder"
        content.body = sleepMessages.randomElement() ?? "Remember to get at least 7 hours of sleep!"
        content.sound = .default

        var date = DateComponents()
        date.hour = 22
        date.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: true)
        let request = UNNotificationRequest(identifier: "sleep_reminder", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                #if DEBUG
                print("❌ Error scheduling sleep reminder: \(error.localizedDescription)")
                #endif
            } else {
                #if DEBUG
                print("✅ Sleep reminder scheduled for 10:00 PM")
                #endif
            }
        }
    }
}
