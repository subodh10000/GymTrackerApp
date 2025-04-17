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
                print("✅ Permission granted")
                self.scheduleWorkoutReminder(userManager: userManager)
                self.scheduleHydrationReminder()
            } else {
                print("❌ Permission denied")
            }
            if let error = error {
                print("❌ Error: \(error.localizedDescription)")
            }
        }
    }

    func scheduleWorkoutReminder(userManager: UserManager) {
        let generalSavage = [
            "💪 Get the f*ck out and go to gym.",
            "🚨 Go to gym or you’re a SUSSY.",
            "👊 Sweat now or regret later. MOVE.",
            "🏋️ No pain, no abs. No gym, no gains.",
            "⚠️ Being lazy is not a workout routine.",
            "🥊 That barbell ain’t lifting itself.",
            "🔥 Get up and lift heavy sh*t. Now.",
            "🧠 You’re not tired, you’re undisciplined."
        ]

        let focusRoasts: [String: [String]] = [
            "chest": [
                "🧱 Chest day? Inflate those pancakes.",
                "🫁 You breathing or bench pressing? Get to the gym.",
                "🦍 Go build that gorilla chest, bro."
            ],
            "legs": [
                "🦵 It’s leg day. Don’t skip it or skip walking tomorrow.",
                "🍗 Chicken legs aren’t a flex. Go squat.",
                "🔥 Leg day = death. Proceed with honor."
            ],
            "core": [
                "🧊 Core day? Ice up, abs incoming.",
                "🎯 Every twist counts. Attack your core.",
                "👊 Build abs, not excuses."
            ],
            "back": [
                "🪵 Your spine deserves armor. Pull hard today.",
                "🏹 It’s back day. Pull like your life depends on it.",
                "🧱 Build that cobra back, warrior."
            ],
            "arms": [
                "💪 Time to build arms that intimidate sleeves.",
                "🧨 Blow up those biceps. It's armageddon.",
                "🗿 Curl. Curl. Curl. Cry. Repeat."
            ]
        ]

        let today = Calendar.current.component(.weekday, from: Date())
        let todayWorkout = userManager.workouts.first { $0.day.lowercased() == weekdayName(for: today).lowercased() }

        let focus = todayWorkout?.focus.lowercased() ?? ""
        let matchedFocus = focusRoasts.first(where: { focus.contains($0.key) })?.value ?? generalSavage
        let chosen = matchedFocus.randomElement() ?? generalSavage.randomElement()!

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
                print("❌ Error scheduling workout reminder: \(error.localizedDescription)")
            } else {
                print("✅ Workout reminder scheduled for 5:00 PM with message: \(chosen)")
            }
        }
    }

    func scheduleHydrationReminder() {
        let hydrationSavage = [
            "💧 Water your muscles, you dehydrated raisin.",
            "🥤 Your biceps are crying for water. DRINK.",
            "🫠 Muscles without water? That’s called jerky.",
            "🚨 3L minimum. Don’t make me send a nurse.",
            "🪣 Go drink or your gains will vanish."
        ]

        let content = UNMutableNotificationContent()
        content.title = "💧 Hydration Check"
        content.body = hydrationSavage.randomElement() ?? "Drink some water, please."
        content.sound = .default

        var date = DateComponents()
        date.hour = 20
        date.minute = 30

        let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: true)
        let request = UNNotificationRequest(identifier: "hydration_reminder", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Error scheduling hydration reminder: \(error.localizedDescription)")
            } else {
                print("✅ Hydration reminder scheduled for 8:30 PM")
            }
        }
    }

    private func weekdayName(for weekday: Int) -> String {
        let formatter = DateFormatter()
        return formatter.weekdaySymbols[weekday - 1]
    }
}
