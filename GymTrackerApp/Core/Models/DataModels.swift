import Foundation
import SwiftData

// MARK: - SwiftData Models

@Model
final class StoredUserProfile {
    var name: String
    var age: Int
    var gender: String // Store as rawValue
    var height: Double
    var weight: Double
    var fitnessLevel: String
    var goal: String
    var daysPerWeek: Int
    var sessionDurationHours: Double
    var workoutEnvironment: String
    var avatarName: String
    
    init(from profile: UserProfile) {
        self.name = profile.name
        self.age = profile.age
        self.gender = profile.gender.rawValue
        self.height = profile.height
        self.weight = profile.weight
        self.fitnessLevel = profile.fitnessLevel.rawValue
        self.goal = profile.goal.rawValue
        self.daysPerWeek = profile.daysPerWeek
        self.sessionDurationHours = profile.sessionDurationHours
        self.workoutEnvironment = profile.workoutEnvironment.rawValue
        self.avatarName = profile.avatarName
    }
    
    func toUserProfile() -> UserProfile {
        UserProfile(
            name: name,
            age: age,
            gender: Gender(rawValue: gender) ?? .male,
            height: height,
            weight: weight,
            fitnessLevel: FitnessLevel(rawValue: fitnessLevel) ?? .beginner,
            goal: Goal(rawValue: goal) ?? .strength,
            daysPerWeek: daysPerWeek,
            sessionDurationHours: sessionDurationHours,
            workoutEnvironment: WorkoutEnvironment(rawValue: workoutEnvironment) ?? .gym,
            avatarName: avatarName
        )
    }
}

@Model
final class StoredExercise {
    var id: UUID
    var name: String
    var sets: String
    var reps: String
    var restTime: String
    var exerciseDescription: String  // Renamed from 'description' to avoid conflict
    var category: String
    var equipment: String?
    var difficulty: String
    var isCompleted: Bool
    
    // Relationship to workout
    var workout: StoredWorkout?
    
    init(from exercise: Exercise) {
        self.id = exercise.id
        self.name = exercise.name
        self.sets = exercise.sets
        self.reps = exercise.reps
        self.restTime = exercise.restTime
        self.exerciseDescription = exercise.description
        self.category = exercise.category.rawValue
        self.equipment = exercise.equipment
        self.difficulty = exercise.difficulty.rawValue
        self.isCompleted = exercise.isCompleted
    }
    
    func toExercise() -> Exercise {
        Exercise(
            id: id,
            name: name,
            sets: sets,
            reps: reps,
            restTime: restTime,
            description: exerciseDescription,
            category: ExerciseCategory(rawValue: category) ?? .general,
            equipment: equipment,
            difficulty: ExerciseDifficulty(rawValue: difficulty) ?? .beginner,
            isCompleted: isCompleted
        )
    }
}

@Model
final class StoredWorkout {
    var id: UUID
    var day: String
    var focus: String
    
    @Relationship(deleteRule: .cascade) var exercises: [StoredExercise]?
    
    init(from workout: Workout) {
        self.id = workout.id
        self.day = workout.day
        self.focus = workout.focus
        // Create exercises - relationship will be set after insertion
        self.exercises = workout.exercises.map { StoredExercise(from: $0) }
    }
    
    func toWorkout() -> Workout {
        let exercises = exercises?.map { $0.toExercise() } ?? []
        return Workout(id: id, day: day, focus: focus, exercises: exercises)
    }
}

@Model
final class StoredPersonalRecord {
    var id: UUID
    var exerciseName: String
    var recordDetail: String
    var date: Date
    var iconName: String
    
    init(from record: PersonalRecord) {
        self.id = record.id
        self.exerciseName = record.exerciseName
        self.recordDetail = record.recordDetail
        self.date = record.date
        self.iconName = record.iconName
    }
    
    func toPersonalRecord() -> PersonalRecord {
        PersonalRecord(
            id: id,
            exerciseName: exerciseName,
            recordDetail: recordDetail,
            date: date,
            iconName: iconName
        )
    }
}

@Model
final class StoredWorkoutHistory {
    var id: UUID
    var date: Date
    var workoutDay: String
    var workoutFocus: String
    var workoutId: UUID?
    
    init(from history: WorkoutHistory) {
        self.id = history.id
        self.date = history.date
        self.workoutDay = history.workoutDay
        self.workoutFocus = history.workoutFocus
        self.workoutId = history.workoutId
    }
    
    func toWorkoutHistory() -> WorkoutHistory {
        WorkoutHistory(
            id: id,
            date: date,
            workoutDay: workoutDay,
            workoutFocus: workoutFocus,
            workoutId: workoutId
        )
    }
}

// MARK: - Helper Extensions for Codable Models

extension Workout {
    init(id: UUID, day: String, focus: String, exercises: [Exercise]) {
        self.id = id
        self.day = day
        self.focus = focus
        self.exercises = exercises
    }
}

extension Exercise {
    init(id: UUID, name: String, sets: String, reps: String, restTime: String, description: String, category: ExerciseCategory, equipment: String?, difficulty: ExerciseDifficulty, isCompleted: Bool) {
        self.id = id
        self.name = name
        self.sets = sets
        self.reps = reps
        self.restTime = restTime
        self.description = description
        self.category = category
        self.equipment = equipment
        self.difficulty = difficulty
        self.isCompleted = isCompleted
    }
}

// Note: PersonalRecord and WorkoutHistory already have memberwise initializers
// from Swift, so we don't need to add extension initializers here.
// The structs can be initialized directly with their properties.

