import Foundation
import SwiftUI

// MARK: - Enums for User Profile & Exercises
// These enums now match the backend and will be used in the onboarding view.

enum Gender: String, Codable, CaseIterable {
    case male = "Male"
    case female = "Female"
    case preferNotToSay = "Prefer Not to Say"
}

enum FitnessLevel: String, Codable, CaseIterable {
    case beginner = "Beginner"
    case intermediate = "Intermediate"
    case advanced = "Advanced"
}

enum Goal: String, Codable, CaseIterable {
    case fatLoss = "Fat Loss"
    case muscleGain = "Muscle Gain"
    case endurance = "Endurance"
    case strength = "Strength"
    case flexibility = "Flexibility"
}

enum ExerciseCategory: String, Codable, CaseIterable {
    case strength = "Strength"
    case plyometric = "Plyometric"
    case mobility = "Mobility"
    case core = "Core"
    case cardio = "Cardio"
    case agility = "Agility"
    case general = "General"
    case onCourt = "On-Court Drills"
}

enum ExerciseDifficulty: String, Codable, CaseIterable {
    case beginner = "Beginner"
    case intermediate = "Intermediate"
    case advanced = "Advanced"
}
enum Rank {
    case bronze, silver, gold, none
    
    var title: String {
        switch self {
        case .bronze: return "Bronze"
        case .silver: return "Silver"
        case .gold: return "Gold"
        case .none: return "No Rank"
        }
    }
    
    var icon: String {
        switch self {
        case .bronze: return "🥉"
        case .silver: return "🥈"
        case .gold: return "🏆"
        case .none: return "💪"
        }
    }
}

// MARK: - Core Data Models

struct UserProfile: Codable {
    var name: String
    var age: Int
    var gender: Gender
    var height: Double // Stored in inches
    var weight: Double // Stored in lbs
    var fitnessLevel: FitnessLevel
    var goal: Goal
    var daysPerWeek: Int
    var sessionDurationHours: Double

    // Computed properties for metric conversion
    var heightInMeters: Double {
        return height * 0.0254
    }

    var weightInKilograms: Double {
        return weight * 0.453592
    }
}

// UPDATED Workout Struct
struct Workout: Identifiable, Codable {
    var id: UUID
    var day: String
    var focus: String
    var exercises: [Exercise]

    // Custom decoder to generate ID on the frontend
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.day = try container.decode(String.self, forKey: .day)
        self.focus = try container.decode(String.self, forKey: .focus)
        self.exercises = try container.decode([Exercise].self, forKey: .exercises)
        // Generate the ID locally instead of decoding it from the JSON
        self.id = UUID()
    }
    
    // We need to define the keys to decode from the JSON, excluding 'id'
    private enum CodingKeys: String, CodingKey {
        case day, focus, exercises
    }
}

// UPDATED Exercise Struct
struct Exercise: Identifiable, Codable {
    var id: UUID
    var name: String
    var sets: String
    var reps: String
    var restTime: String
    var description: String
    var category: ExerciseCategory
    var equipment: String?
    var difficulty: ExerciseDifficulty
    var isCompleted: Bool = false

    // Custom decoder to generate ID on the frontend
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.sets = try container.decode(String.self, forKey: .sets)
        self.reps = try container.decode(String.self, forKey: .reps)
        self.restTime = try container.decode(String.self, forKey: .restTime)
        self.description = try container.decode(String.self, forKey: .description)
        self.category = try container.decode(ExerciseCategory.self, forKey: .category)
        self.equipment = try container.decodeIfPresent(String.self, forKey: .equipment)
        self.difficulty = try container.decode(ExerciseDifficulty.self, forKey: .difficulty)
        // Generate the ID locally instead of decoding it from the JSON
        self.id = UUID()
        // isCompleted is not in the JSON, so we initialize it here
        self.isCompleted = false
    }
    
    // We need to define the keys to decode from the JSON, excluding 'id' and 'isCompleted'
    private enum CodingKeys: String, CodingKey {
        case name, sets, reps, restTime, description, category, equipment, difficulty
    }
}


// MARK: - ViewModel (Prepared for Networking)

class UserManager: ObservableObject {
    @Published var profile: UserProfile? {
        didSet {
            saveProfile()
        }
    }
    @Published var workouts: [Workout] = [] {
        didSet {
            saveWorkouts()
        }
    }
    
    // This property will now control whether the main app or onboarding is shown.
    @Published var hasCompletedOnboarding: Bool = false

    init() {
        loadProfile()
        loadWorkouts()
        
        if profile != nil {
            hasCompletedOnboarding = true
        }
    }

    func saveProfileAndGenerateWorkouts(profile: UserProfile) {
        self.profile = profile
        
        // Call the network service to get the AI-generated plan
        NetworkService.shared.generateInitialPlan(for: profile) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let workouts):
                    // On success, update the workouts and mark onboarding as complete
                    self?.workouts = workouts
                    self?.hasCompletedOnboarding = true
                    print("✅ Successfully fetched and updated workouts.")
                case .failure(let error):
                    // On failure, you could show an alert to the user
                    print("❌ Error generating workout plan: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func workoutsCompletedThisWeek() -> Int {
        var count = 0
        for workout in workouts {
            // A workout is complete if it has exercises and none are incomplete
            guard !workout.exercises.isEmpty else { continue }
            if !workout.exercises.contains(where: { !$0.isCompleted }) {
                count += 1
            }
        }
        return count
    }

    func getCurrentRank() -> Rank {
        let completedCount = workoutsCompletedThisWeek()
        if completedCount >= 5 {
            return .gold
        } else if completedCount >= 4 {
            return .silver
        } else if completedCount >= 3 {
            return .bronze
        } else {
            return .none
        }
    }
    func toggleExerciseCompletion(workoutIndex: Int, exerciseIndex: Int) {
        // Create a mutable copy of the workouts array.
        var updatedWorkouts = workouts
        
        // Modify the property in the copy.
        updatedWorkouts[workoutIndex].exercises[exerciseIndex].isCompleted.toggle()
        
        self.workouts = updatedWorkouts
    }
    
    func resetAllWorkouts() {
        for i in 0..<workouts.count {
            for j in 0..<workouts[i].exercises.count {
                workouts[i].exercises[j].isCompleted = false
            }
        }
    }
    
    func updateWorkout(at index: Int, with newWorkout: Workout) {
        guard workouts.indices.contains(index) else { return }
        workouts[index] = newWorkout
    }
    
    // MARK: - UserDefaults Persistence
    
    func resetApp() {
        // Clear local properties
        profile = nil
        workouts = []
        hasCompletedOnboarding = false
        
        // Clear UserDefaults
        UserDefaults.standard.removeObject(forKey: "userProfile")
        UserDefaults.standard.removeObject(forKey: "userWorkouts")
        
        print("✅ App has been reset.")
    }
    
    private func saveProfile() {
        if let encodedProfile = try? JSONEncoder().encode(profile) {
            UserDefaults.standard.set(encodedProfile, forKey: "userProfile")
        }
    }
    
    private func loadProfile() {
        if let savedProfileData = UserDefaults.standard.data(forKey: "userProfile") {
            if let decodedProfile = try? JSONDecoder().decode(UserProfile.self, from: savedProfileData) {
                self.profile = decodedProfile
            }
        }
    }
    
    private func saveWorkouts() {
        if let encodedWorkouts = try? JSONEncoder().encode(workouts) {
            UserDefaults.standard.set(encodedWorkouts, forKey: "userWorkouts")
        }
    }
    
    private func loadWorkouts() {
        if let savedWorkoutsData = UserDefaults.standard.data(forKey: "userWorkouts") {
            if let decodedWorkouts = try? JSONDecoder().decode([Workout].self, from: savedWorkoutsData) {
                self.workouts = decodedWorkouts
            }
        }
    }
}
