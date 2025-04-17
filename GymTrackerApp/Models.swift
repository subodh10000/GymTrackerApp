//
//  Models.swift
//  GymTrackerApp
//
//  Created by Subodh Kathayat on 4/16/25.
//

import Foundation
import SwiftUI

// MARK: - Models

struct Exercise: Identifiable, Codable {
    var id = UUID()
    var name: String
    var sets: Int
    var reps: String
    var isCompleted: Bool = false
    var notes: String = ""
    var restTime: Int = 60 // default rest between sets in seconds
    var description: String = "No description available." // how to perform it
}

struct Workout: Identifiable, Codable {
    var id = UUID()
    var day: String
    var focus: String
    var exercises: [Exercise]
}

struct UserProfile: Codable {
    var name: String
    var age: Int = 23
    var weight: Int = 145
    var height: String = "5'7\""
    var goal: String = "Lean, strong legs, visible abs"
}

// MARK: - ViewModel

class UserManager: ObservableObject {
    @Published var profile: UserProfile = UserProfile(name: "")
    @Published var hasCompletedOnboarding: Bool = false
    @Published var workouts: [Workout] = []

    init() {
        loadProfile()
        loadWorkouts()
    }

    func saveProfile() {
        hasCompletedOnboarding = true
        if let encoded = try? JSONEncoder().encode(profile) {
            UserDefaults.standard.set(encoded, forKey: "userProfile")
        }
    }

    func loadProfile() {
        if let saved = UserDefaults.standard.data(forKey: "userProfile"),
           let decoded = try? JSONDecoder().decode(UserProfile.self, from: saved) {
            profile = decoded
            hasCompletedOnboarding = true
        }
    }

    func resetAllWorkouts() {
        for i in workouts.indices {
            for j in workouts[i].exercises.indices {
                workouts[i].exercises[j].isCompleted = false
            }
        }
    }

    func toggleExerciseCompletion(workoutIndex: Int, exerciseIndex: Int) {
        workouts[workoutIndex].exercises[exerciseIndex].isCompleted.toggle()
    }

    func loadWorkouts() {
        workouts = [
            Workout(day: "Wednesday", focus: "Lower Body (Strength and Explosiveness)", exercises: [
                Exercise(name: "Back Squat", sets: 4, reps: "5", restTime: 90, description: "Hold barbell on shoulders, bend knees/hips to squat down, then push up."),
                Exercise(name: "Romanian Deadlift", sets: 3, reps: "8", restTime: 60, description: "Keep legs straight, hinge at hips with dumbbells or barbell to stretch hamstrings."),
                Exercise(name: "Walking Lunges", sets: 3, reps: "12 each leg", restTime: 60, description: "Step forward into a lunge, push up and alternate legs."),
                Exercise(name: "Box Jumps / Broad Jumps", sets: 3, reps: "5", restTime: 90, description: "Explosively jump onto a box or forward, land softly."),
                Exercise(name: "Standing Calf Raises", sets: 4, reps: "15", restTime: 45, description: "Stand tall, raise heels, squeeze calves, lower slowly."),
                Exercise(name: "Plank with Shoulder Taps", sets: 3, reps: "30 sec", restTime: 30, description: "Hold plank, alternate tapping each shoulder.")
            ]),
            Workout(day: "Thursday", focus: "Upper Body Push (Chest, Shoulders, Triceps)", exercises: [
                Exercise(name: "Flat Barbell Bench Press", sets: 4, reps: "6", restTime: 90, description: "Lower bar to chest and push back up with control."),
                Exercise(name: "Overhead Dumbbell Press", sets: 4, reps: "8", restTime: 60, description: "Push dumbbells from shoulders to overhead."),
                Exercise(name: "Incline Dumbbell Press", sets: 3, reps: "10", restTime: 60, description: "Press dumbbells at an incline bench for upper chest."),
                Exercise(name: "Lateral Raises", sets: 3, reps: "12", restTime: 30, description: "Raise dumbbells sideways to shoulder level."),
                Exercise(name: "Tricep Dips (weighted if possible)", sets: 3, reps: "10", restTime: 60, description: "Lower body between bars or bench and press up."),
                Exercise(name: "Pushups to failure", sets: 2, reps: "Max", restTime: 60, description: "Standard pushups until you can't do any more.")
            ]),
            Workout(day: "Friday", focus: "Lower Body (Strength and Stability)", exercises: [
                Exercise(name: "Deadlifts", sets: 4, reps: "5", restTime: 90, description: "Lift barbell from ground by hinging hips."),
                Exercise(name: "Bulgarian Split Squats", sets: 3, reps: "8 each leg", restTime: 60, description: "Rear foot elevated, lunge down with control."),
                Exercise(name: "Glute Ham Raises or Hamstring Curls", sets: 3, reps: "12", restTime: 60, description: "Curl hamstrings using machine or bodyweight."),
                Exercise(name: "Lateral Band Walks", sets: 3, reps: "20 steps", restTime: 30, description: "Walk sideways with resistance band."),
                Exercise(name: "Single-Leg Toe Touches", sets: 2, reps: "10 each leg", restTime: 30, description: "Balance on one leg, reach down to touch toe."),
                Exercise(name: "Hanging Leg Raises", sets: 3, reps: "12", restTime: 60, description: "Hang from bar and raise legs straight up.")
            ]),
            Workout(day: "Saturday", focus: "Upper Body Pull (Back, Biceps, Core)", exercises: [
                Exercise(name: "Pull-ups", sets: 4, reps: "Max", restTime: 90, description: "Pull body up to bar with control."),
                Exercise(name: "Barbell Rows", sets: 4, reps: "8", restTime: 60, description: "Row barbell to torso while bent over."),
                Exercise(name: "Face Pulls", sets: 3, reps: "15", restTime: 30, description: "Pull cable to face to activate rear delts."),
                Exercise(name: "Seated Cable Rows", sets: 3, reps: "10", restTime: 60, description: "Row cable handle to stomach while seated."),
                Exercise(name: "EZ Bar Curls / Hammer Curls", sets: 3, reps: "12 superset", restTime: 30, description: "Alternate bicep curls with different grips."),
                Exercise(name: "Cable Woodchoppers", sets: 3, reps: "12 each side", restTime: 30, description: "Rotate core while pulling cable diagonally.")
            ]),
            Workout(day: "Sunday", focus: "Athletic Conditioning and Core", exercises: [
                Exercise(name: "Sled Push or Hill Sprints", sets: 6, reps: "15-20 sec bursts", restTime: 90, description: "Sprint uphill or push sled hard and fast."),
                Exercise(name: "Agility Ladder Drills", sets: 1, reps: "10 min", restTime: 0, description: "Do fast feet drills through the ladder."),
                Exercise(name: "Jump Rope Intervals", sets: 3, reps: "2 min", restTime: 60, description: "Jump rope fast, then rest."),
                Exercise(name: "Farmer Carries", sets: 3, reps: "40 meters", restTime: 60, description: "Carry heavy weights walking steadily."),
                Exercise(name: "Weighted Decline Sit-ups", sets: 3, reps: "15", restTime: 30, description: "Sit-ups on decline bench holding weight."),
                Exercise(name: "Russian Twists", sets: 3, reps: "20", restTime: 30, description: "Twist torso side to side with weight.")
            ])
        ]
    }
}
