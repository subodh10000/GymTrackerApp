import Foundation
import SwiftUI
import SwiftData
import UserNotifications

// MARK: - Enums for User Profile & Exercises

enum Gender: String, Codable, CaseIterable {
    case male = "Male"
    case female = "Female"
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

enum WorkoutEnvironment: String, Codable, CaseIterable {
    case gym = "Gym"
    case home = "No Equipment"
    case pilates = "Pilates"
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
    var workoutEnvironment: WorkoutEnvironment
    var avatarName: String = "lad" // Default avatar
    
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
        self.id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        self.day = try container.decode(String.self, forKey: .day)
        self.focus = try container.decode(String.self, forKey: .focus)
        self.exercises = try container.decode([Exercise].self, forKey: .exercises)
    }
    
    // Decode id when present (persisted app state), fallback for API payloads.
    private enum CodingKeys: String, CodingKey {
        case id, day, focus, exercises
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
        self.id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        self.name = try container.decode(String.self, forKey: .name)
        self.sets = try container.decode(String.self, forKey: .sets)
        self.reps = try container.decode(String.self, forKey: .reps)
        self.restTime = try container.decode(String.self, forKey: .restTime)
        self.description = try container.decode(String.self, forKey: .description)
        self.category = try container.decode(ExerciseCategory.self, forKey: .category)
        self.equipment = try container.decodeIfPresent(String.self, forKey: .equipment)
        self.difficulty = try container.decode(ExerciseDifficulty.self, forKey: .difficulty)
        self.isCompleted = try container.decodeIfPresent(Bool.self, forKey: .isCompleted) ?? false
    }
    
    // Decode id/isCompleted when present (persisted app state), fallback for API payloads.
    private enum CodingKeys: String, CodingKey {
        case id, name, sets, reps, restTime, description, category, equipment, difficulty, isCompleted
    }
}


// --- NEW STRUCT (from PersonalRecordsView.swift) ---
struct PersonalRecord: Identifiable, Codable, Equatable {
    var id = UUID()
    var exerciseName: String
    var recordDetail: String
    var date: Date
    var iconName: String
    
    // Make it mutable
    struct Mutable {
        var exerciseName: String
        var recordDetail: String
        var date: Date
        var iconName: String
    }
}

// MARK: - Workout History Model
struct WorkoutHistory: Identifiable, Codable, Equatable {
    var id: UUID
    var date: Date
    var workoutDay: String  // e.g., "Monday", "Push Day"
    var workoutFocus: String  // e.g., "Chest & Triceps"
    var workoutId: UUID?  // Reference to the workout if it still exists
    
    // Default initializer - generates new ID
    init(id: UUID = UUID(), date: Date, workoutDay: String, workoutFocus: String, workoutId: UUID? = nil) {
        self.id = id
        self.date = date
        self.workoutDay = workoutDay
        self.workoutFocus = workoutFocus
        self.workoutId = workoutId
    }
    
    // Helper to check if date matches
    func isOnSameDay(as otherDate: Date) -> Bool {
        Calendar.current.isDate(self.date, inSameDayAs: otherDate)
    }
}

// MARK: - Reminder Model
struct Reminder: Identifiable, Codable, Equatable {
    var id = UUID()
    var text: String
    var icon: String
    var colorHex: String
    
    var color: Color {
        Color(hex: colorHex)
    }
}

// MARK: - ViewModel (Prepared for Networking)

@MainActor
class UserManager: ObservableObject {
    var modelContext: ModelContext?
    
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
    @Published var pendingAIWorkouts: [Workout] = []
    @Published var showPendingPlanPrompt: Bool = false
    @Published var isAutoRetryingPlan: Bool = false
    
    // --- NEW PROPERTIES (for your views) ---
    @Published var personalRecords: [PersonalRecord] = [] {
        didSet {
            savePersonalRecords()
        }
    }
    
    // Flag to prevent infinite loops when ensuring sample records
    private var isEnsuringSampleRecords = false
    
    // Flag to prevent infinite loops when ensuring sample reminders
    private var isEnsuringSampleReminders = false
    
    @Published var reminders: [Reminder] = [] {
        didSet {
            saveReminders()
        }
    }
    
    @Published var completionDates: [Date] = [] {
         didSet {
             saveCompletionDates()
         }
     }
    
    // Workout history with details - stored in SwiftData
    @Published var workoutHistory: [WorkoutHistory] = [] {
        didSet {
            saveWorkoutHistory()
            // Update completionDates for backward compatibility
            let updatedCompletionDates = workoutHistory.map { $0.date }
            if completionDates != updatedCompletionDates {
                completionDates = updatedCompletionDates
            }
        }
    }
    
    // This property will now control whether the main app or onboarding is shown.
    @Published var hasCompletedOnboarding: Bool = false

    @Published var notificationsEnabled: Bool {
        didSet {
            UserDefaults.standard.set(notificationsEnabled, forKey: "notificationsEnabled")
            if notificationsEnabled {
                NotificationManager.shared.scheduleAllNotifications()
            } else {
                NotificationManager.shared.cancelAllNotifications()
            }
        }
    }

    init() {
        self.notificationsEnabled = UserDefaults.standard.object(forKey: "notificationsEnabled") as? Bool ?? true

        // Load UserDefaults data immediately
        loadProfile()
        loadWorkouts()
        loadPersonalRecords()
        loadReminders()
        loadCompletionDates()
        
        // WorkoutHistory will be loaded when modelContext is set
        if profile != nil {
            hasCompletedOnboarding = true
        }
        
        // Check if we need to reset for a new week
        checkAndResetForNewWeek()
    }
    
    // MARK: - Weekly Reset Logic
    
    /// Checks if a new week has started and resets workout completion statuses
    /// This ensures users can restart their weekly training plan
    private func checkAndResetForNewWeek() {
        let calendar = Calendar.current
        let now = Date()
        
        // Get the start of the current week (Monday)
        guard let currentWeekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)) else {
            return
        }
        
        // Get the last reset date from UserDefaults
        let lastResetKey = "lastWeeklyResetDate"
        let lastResetDate = UserDefaults.standard.object(forKey: lastResetKey) as? Date
        
        // Check if we need to reset
        var shouldReset = false
        
        if let lastReset = lastResetDate {
            // Get the week start of the last reset
            if let lastResetWeekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: lastReset)) {
                // If current week start is after last reset week start, we need to reset
                shouldReset = currentWeekStart > lastResetWeekStart
            }
        } else {
            // First time running - set the date but don't reset (user might be mid-week)
            UserDefaults.standard.set(now, forKey: lastResetKey)
            return
        }
        
        if shouldReset {
            resetWorkoutsForNewWeek()
            UserDefaults.standard.set(now, forKey: lastResetKey)
            
            #if DEBUG
            print("✅ Weekly reset performed - workout completion statuses cleared")
            #endif
        }
    }
    
    /// Resets only the completion status of exercises, keeping workout history intact
    func resetWorkoutsForNewWeek() {
        var updatedWorkouts = workouts
        for i in 0..<updatedWorkouts.count {
            for j in 0..<updatedWorkouts[i].exercises.count {
                updatedWorkouts[i].exercises[j].isCompleted = false
            }
        }
        
        // Update workouts without triggering unnecessary saves until we're done
        self.workouts = updatedWorkouts
        
        // Note: We keep workout history - it's a permanent record of past completions
    }
    
    /// Force reset for current week (useful for testing or manual reset)
    func forceWeeklyReset() {
        resetWorkoutsForNewWeek()
        let now = Date()
        UserDefaults.standard.set(now, forKey: "lastWeeklyResetDate")
        
        #if DEBUG
        print("✅ Force weekly reset performed")
        #endif
    }
    
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
        loadWorkoutHistory(from: context)
        migrateWorkoutHistoryFromUserDefaults()
        
        // If there's any workout history in memory that wasn't saved yet, save it now
        // This ensures data isn't lost if context wasn't ready when workout was completed
        if !workoutHistory.isEmpty {
            saveWorkoutHistory()
        }
    }
    
    private func migrateWorkoutHistoryFromUserDefaults() {
        guard let context = modelContext else { return }
        
        // Check if migration already completed
        if UserDefaults.standard.bool(forKey: "workoutHistoryMigratedToSwiftData") {
            return
        }
        
        let calendar = Calendar.current
        var seenDays = Set(workoutHistory.map { normalizedWorkoutDay(for: $0.date, calendar: calendar) })
        
        // Migrate from UserDefaults completionDates to SwiftData workoutHistory
        if let savedData = UserDefaults.standard.data(forKey: "completionDates"),
           let decodedData = try? JSONDecoder().decode([Date].self, from: savedData) {
            for date in decodedData {
                let normalizedDate = normalizedWorkoutDay(for: date, calendar: calendar)
                guard !seenDays.contains(normalizedDate) else { continue }
                
                let history = WorkoutHistory(date: normalizedDate, workoutDay: "Workout", workoutFocus: "Completed", workoutId: nil)
                let stored = StoredWorkoutHistory(from: history)
                context.insert(stored)
                workoutHistory.append(history)
                seenDays.insert(normalizedDate)
            }
        }
        
        // Also migrate from workoutHistory UserDefaults if it exists
        if let savedData = UserDefaults.standard.data(forKey: "workoutHistory") {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            if let decodedData = try? decoder.decode([WorkoutHistory].self, from: savedData) {
                for history in decodedData {
                    let normalizedDate = normalizedWorkoutDay(for: history.date, calendar: calendar)
                    guard !seenDays.contains(normalizedDate) else { continue }
                    
                    var normalizedHistory = history
                    normalizedHistory.date = normalizedDate
                    let stored = StoredWorkoutHistory(from: normalizedHistory)
                    context.insert(stored)
                    workoutHistory.append(normalizedHistory)
                    seenDays.insert(normalizedDate)
                }
            }
        }
        
        // Save and mark migration complete
        try? context.save()
        UserDefaults.standard.set(true, forKey: "workoutHistoryMigratedToSwiftData")
        
        #if DEBUG
        print("✅ WorkoutHistory migrated to SwiftData")
        #endif
    }

    @Published var networkError: Error?
    @Published var showNetworkError = false
    
    private var lastSavedWorkoutHistorySignature: Int?
    
    private var autoRetryWorkItem: DispatchWorkItem?
    private var autoRetryAttempt: Int = 0
    private let maxAutoRetryAttempts: Int = 3
    
    private enum PlanGenerationError: LocalizedError {
        case emptyResponse
        
        var errorDescription: String? {
            switch self {
            case .emptyResponse:
                return "The server returned an empty workout plan."
            }
        }
    }
    
    func saveProfileAndGenerateWorkouts(profile: UserProfile) {
        self.profile = profile
        generateWorkouts(
            profile: profile,
            applyImmediately: true,
            showErrorToUser: true,
            allowAutoRetry: true
        )
    }
    
    private func generateWorkouts(
        profile: UserProfile,
        applyImmediately: Bool,
        showErrorToUser: Bool,
        allowAutoRetry: Bool
    ) {
        NetworkService.shared.generateInitialPlan(for: profile) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let workouts):
                self.handleSuccessfulGeneration(
                    workouts: workouts,
                    applyImmediately: applyImmediately
                )
            case .failure(let error):
                #if DEBUG
                print("❌ Error generating workout plan: \(error.localizedDescription)")
                #endif
                self.handleGenerationFailure(
                    error: error,
                    applyImmediately: applyImmediately,
                    showErrorToUser: showErrorToUser,
                    allowAutoRetry: allowAutoRetry
                )
            }
        }
    }
    
    private func handleSuccessfulGeneration(
        workouts: [Workout],
        applyImmediately: Bool
    ) {
        cancelAutomaticRetry()
        
        guard !workouts.isEmpty else {
            handleGenerationFailure(
                error: PlanGenerationError.emptyResponse,
                applyImmediately: applyImmediately,
                showErrorToUser: true,
                allowAutoRetry: true
            )
            return
        }
        
        if applyImmediately {
            self.workouts = workouts
            self.hasCompletedOnboarding = true
            self.networkError = nil
            self.showNetworkError = false
            self.pendingAIWorkouts = []
            self.showPendingPlanPrompt = false
            
            // Ensure at least 4 sample records and reminders when plan is created
            ensureSampleRecords()
            ensureSampleReminders()
            
            #if DEBUG
            print("✅ Successfully fetched and updated workouts.")
            #endif
        } else {
            self.pendingAIWorkouts = workouts
            self.showPendingPlanPrompt = true
            #if DEBUG
            print("✅ Background retry produced a new workout plan.")
            #endif
        }
    }
    
    private func handleGenerationFailure(
        error: Error,
        applyImmediately: Bool,
        showErrorToUser: Bool,
        allowAutoRetry: Bool
    ) {
        if showErrorToUser {
            self.networkError = error
            self.showNetworkError = true
        }
        
        if applyImmediately {
            self.loadFallbackWorkouts()
        }
        
        if allowAutoRetry {
            self.scheduleAutomaticRetry()
        }
    }
    
    private func scheduleAutomaticRetry() {
        guard let profile = profile else { return }
        guard autoRetryAttempt < maxAutoRetryAttempts else {
            isAutoRetryingPlan = false
            return
        }
        
        autoRetryAttempt += 1
        isAutoRetryingPlan = true
        
        let delay = pow(2.0, Double(autoRetryAttempt - 1)) * 5.0 // 5s, 10s, 20s
        
        autoRetryWorkItem?.cancel()
        let workItem = DispatchWorkItem { [weak self] in
            guard let self else { return }
            self.generateWorkouts(
                profile: profile,
                applyImmediately: false,
                showErrorToUser: false,
                allowAutoRetry: true
            )
        }
        autoRetryWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: workItem)
    }
    
    private func cancelAutomaticRetry() {
        autoRetryWorkItem?.cancel()
        autoRetryWorkItem = nil
        autoRetryAttempt = 0
        isAutoRetryingPlan = false
    }
    
    func confirmPendingPlanReplacement() {
        guard !pendingAIWorkouts.isEmpty else {
            showPendingPlanPrompt = false
            return
        }
        
        workouts = pendingAIWorkouts
        pendingAIWorkouts = []
        showPendingPlanPrompt = false
        hasCompletedOnboarding = true
        
        // Ensure at least 4 sample records and reminders when plan is confirmed
        ensureSampleRecords()
        ensureSampleReminders()
    }
    
    func dismissPendingPlanReplacement() {
        pendingAIWorkouts = []
        showPendingPlanPrompt = false
    }
    
    func loadFallbackWorkouts() {
        if let url = Bundle.main.url(forResource: "hardcode", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                let workouts = try decoder.decode([Workout].self, from: data)
                if !workouts.isEmpty {
                    self.workouts = workouts
                    self.hasCompletedOnboarding = true
                    
                    // Ensure at least 4 sample records and reminders when fallback plan is loaded
                    ensureSampleRecords()
                    ensureSampleReminders()
                    
                    #if DEBUG
                    print("✅ Loaded fallback workouts from hardcode.json")
                    #endif
                }
            } catch {
                #if DEBUG
                print("Error loading fallback workouts: \(error)")
                #endif
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

 
    
    func toggleExerciseCompletion(workoutIndex: Int, exerciseIndex: Int) {
        var updatedWorkouts = workouts
        updatedWorkouts[workoutIndex].exercises[exerciseIndex].isCompleted.toggle()
        self.workouts = updatedWorkouts  // This will trigger saveWorkouts() via didSet
        
        // --- Track Workout Completion with Details (saved in SwiftData) ---
        let workout = updatedWorkouts[workoutIndex]
        let allCompleted = !workout.exercises.contains(where: { !$0.isCompleted })
        let today = Date()
        let calendar = Calendar.current
        
        if allCompleted {
            // Normalize today's date to start of day for accurate comparison
            let normalizedToday = normalizedWorkoutDay(for: today, calendar: calendar)
            
            // Check if we already have a workout history for today using normalized dates
            if let existingIndex = workoutHistory.firstIndex(where: {
                calendar.isDate($0.date, inSameDayAs: normalizedToday)
            }) {
                // Update existing entry - preserve the original ID
                let existingHistory = workoutHistory[existingIndex]
                workoutHistory[existingIndex] = WorkoutHistory(
                    id: existingHistory.id, // Preserve original ID
                    date: normalizedToday, // Use normalized date
                    workoutDay: workout.day,
                    workoutFocus: workout.focus,
                    workoutId: workout.id
                )
            } else {
                // Add new workout history entry with normalized date
                let history = WorkoutHistory(
                    date: normalizedToday, // Use normalized date
                    workoutDay: workout.day,
                    workoutFocus: workout.focus,
                    workoutId: workout.id
                )
                workoutHistory.append(history)
            }
        } else {
            // Strict one-workout-per-day:
            // only remove today's entry if it belongs to this workout.
            // This prevents accidental deletion when user toggles a different workout.
            let normalizedToday = normalizedWorkoutDay(for: today, calendar: calendar)
            workoutHistory.removeAll(where: {
                guard calendar.isDate($0.date, inSameDayAs: normalizedToday) else { return false }
                
                if let historyWorkoutId = $0.workoutId {
                    return historyWorkoutId == workout.id
                }
                
                // Fallback for older entries without workoutId
                return $0.workoutDay == workout.day && $0.workoutFocus == workout.focus
            })
        }
    }
    
    // Get workout history for a specific date (with normalized date comparison)
    func getWorkoutHistory(for date: Date) -> WorkoutHistory? {
        let calendar = Calendar.current
        let normalizedDate = normalizedWorkoutDay(for: date, calendar: calendar)
        
        return workoutHistory.first { history in
            calendar.isDate(history.date, inSameDayAs: normalizedDate)
        }
    }
    // Store workout completions at local noon to avoid day/month drift across
    // timezone or DST transitions while still preserving same-day semantics.
    private func normalizedWorkoutDay(for date: Date, calendar: Calendar = Calendar.current) -> Date {
        let startOfDay = calendar.startOfDay(for: date)
        return calendar.date(byAdding: .hour, value: 12, to: startOfDay) ?? startOfDay
    }

    
    func resetAllWorkouts() {
        for i in 0..<workouts.count {
            for j in 0..<workouts[i].exercises.count {
                workouts[i].exercises[j].isCompleted = false
            }
        }
        // Also clear completion dates and workout history
        completionDates.removeAll()
        workoutHistory.removeAll()
    }
    
    func updateWorkout(at index: Int, with newWorkout: Workout) {
        guard workouts.indices.contains(index) else { return }
        workouts[index] = newWorkout
    }
    
    // --- NEW FUNCTIONS (for PersonalRecordsView) ---
    
    func addRecord(_ record: PersonalRecord) {
        personalRecords.append(record)
    }
    
    func updateRecord(_ record: PersonalRecord) {
        if let index = personalRecords.firstIndex(where: { $0.id == record.id }) {
            personalRecords[index] = record
        }
    }
    
    func deleteRecord(at offsets: IndexSet) {
        personalRecords.remove(atOffsets: offsets)
    }
    
    func deleteRecord(_ record: PersonalRecord) {
        if let index = personalRecords.firstIndex(of: record) {
            personalRecords.remove(at: index)
        }
    }
    
    // Helper function to ensure we always have at least 4 sample records
    private func ensureSampleRecords() {
        // Prevent infinite loops
        guard !isEnsuringSampleRecords else { return }
        isEnsuringSampleRecords = true
        defer { isEnsuringSampleRecords = false }
        
        // If empty, add all sample records
        if personalRecords.isEmpty {
            personalRecords = getSampleRecords()
        } else if personalRecords.count < 4 {
            // If we have some but less than 4, add enough to reach 4
            let sampleRecords = getSampleRecords()
            let additionalRecords = getAdditionalSampleRecords()
            let allSamples = sampleRecords + additionalRecords
            
            // Add only the ones we need, avoiding duplicates
            var existingNames = Set(personalRecords.map { $0.exerciseName })
            for record in allSamples {
                if !existingNames.contains(record.exerciseName) && personalRecords.count < 4 {
                    personalRecords.append(record)
                    existingNames.insert(record.exerciseName)
                }
            }
        }
    }
    
    // Get the default sample records
    private func getSampleRecords() -> [PersonalRecord] {
        let calendar = Calendar.current
        let now = Date()
        
        return [
            PersonalRecord(
                exerciseName: "Bench Press",
                recordDetail: "225 lbs",
                date: calendar.date(byAdding: .day, value: -7, to: now) ?? now,
                iconName: "flame.fill"
            ),
            PersonalRecord(
                exerciseName: "Squat",
                recordDetail: "315 lbs",
                date: calendar.date(byAdding: .day, value: -5, to: now) ?? now,
                iconName: "figure.strengthtraining.traditional"
            ),
            PersonalRecord(
                exerciseName: "Deadlift",
                recordDetail: "405 lbs",
                date: calendar.date(byAdding: .day, value: -3, to: now) ?? now,
                iconName: "bolt.fill"
            ),
            PersonalRecord(
                exerciseName: "1 Mile Run",
                recordDetail: "6:30",
                date: calendar.date(byAdding: .day, value: -10, to: now) ?? now,
                iconName: "stopwatch.fill"
            )
        ]
    }
    
    // Get additional sample records if needed
    private func getAdditionalSampleRecords() -> [PersonalRecord] {
        let calendar = Calendar.current
        let now = Date()
        
        return [
            PersonalRecord(
                exerciseName: "Pull-ups",
                recordDetail: "15 reps",
                date: calendar.date(byAdding: .day, value: -4, to: now) ?? now,
                iconName: "figure.walk"
            ),
            PersonalRecord(
                exerciseName: "Overhead Press",
                recordDetail: "135 lbs",
                date: calendar.date(byAdding: .day, value: -6, to: now) ?? now,
                iconName: "dumbbell.fill"
            ),
            PersonalRecord(
                exerciseName: "5K Run",
                recordDetail: "22:15",
                date: calendar.date(byAdding: .day, value: -8, to: now) ?? now,
                iconName: "figure.run"
            )
        ]
    }
    
    // --- REMINDER FUNCTIONS ---
    
    func addReminder(_ reminder: Reminder) {
        reminders.append(reminder)
    }
    
    func updateReminder(_ reminder: Reminder) {
        if let index = reminders.firstIndex(where: { $0.id == reminder.id }) {
            reminders[index] = reminder
        }
    }
    
    func deleteReminder(at offsets: IndexSet) {
        reminders.remove(atOffsets: offsets)
    }
    
    func deleteReminder(_ reminder: Reminder) {
        reminders.removeAll(where: { $0.id == reminder.id })
    }
    
    // Helper function to ensure we always have at least 4 sample reminders
    private func ensureSampleReminders() {
        // Prevent infinite loops
        guard !isEnsuringSampleReminders else { return }
        isEnsuringSampleReminders = true
        defer { isEnsuringSampleReminders = false }
        
        // If empty, add all sample reminders
        if reminders.isEmpty {
            reminders = getSampleReminders()
        } else if reminders.count < 4 {
            // If we have some but less than 4, add enough to reach 4
            let sampleReminders = getSampleReminders()
            let additionalReminders = getAdditionalSampleReminders()
            let allSamples = sampleReminders + additionalReminders
            
            // Add only the ones we need, avoiding duplicates
            var existingTexts = Set(reminders.map { $0.text })
            for reminder in allSamples {
                if !existingTexts.contains(reminder.text) && reminders.count < 4 {
                    reminders.append(reminder)
                    existingTexts.insert(reminder.text)
                }
            }
        }
    }
    
    // Get the default sample reminders
    private func getSampleReminders() -> [Reminder] {
        return [
            Reminder(text: "Avoid junk food when possible", icon: "tortoise.fill", colorHex: "FF5A5F"),
            Reminder(text: "Keep hydrated all day long", icon: "drop.fill", colorHex: "64DFDF"),
            Reminder(text: "Skip alcohol this week", icon: "wineglass", colorHex: "FF8C42"),
            Reminder(text: "Limit sugary snacks and drinks", icon: "cube.transparent.fill", colorHex: "B5179E"),
            Reminder(text: "Sleep at least 6 hours nightly", icon: "moon.zzz.fill", colorHex: "4EA8DE")
        ]
    }
    
    // Get additional sample reminders if needed
    private func getAdditionalSampleReminders() -> [Reminder] {
        return [
            Reminder(text: "Eat protein with every meal", icon: "leaf.fill", colorHex: "4ECDC4"),
            Reminder(text: "Track your macros daily", icon: "chart.bar.fill", colorHex: "95E1D3"),
            Reminder(text: "Take a 10-minute walk daily", icon: "figure.walk", colorHex: "5E60CE"),
            Reminder(text: "Stretch for 5 minutes", icon: "figure.flexibility", colorHex: "8E54E9")
        ]
    }
    
    
    // MARK: - UserDefaults Persistence
    
    func resetApp() {
        // Cancel all scheduled notifications
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        
        // Clear UserDefaults
        UserDefaults.standard.removeObject(forKey: "userProfile")
        UserDefaults.standard.removeObject(forKey: "userWorkouts")
        UserDefaults.standard.removeObject(forKey: "personalRecords")
        UserDefaults.standard.removeObject(forKey: "reminders")
        UserDefaults.standard.removeObject(forKey: "completionDates")
        UserDefaults.standard.removeObject(forKey: "workoutHistoryMigratedToSwiftData")
        UserDefaults.standard.removeObject(forKey: "lastWeeklyResetDate")
        UserDefaults.standard.removeObject(forKey: "notificationsEnabled")
        
        cancelAutomaticRetry()
        pendingAIWorkouts = []
        showPendingPlanPrompt = false
        
        // Clear SwiftData WorkoutHistory
        if let context = modelContext {
            let historyDescriptor = FetchDescriptor<StoredWorkoutHistory>()
            if let histories = try? context.fetch(historyDescriptor) {
                for history in histories {
                    context.delete(history)
                }
                try? context.save()
            }
        }
        
        // Clear local properties
        profile = nil
        workouts = []
        personalRecords = []
        reminders = []
        completionDates = []
        workoutHistory = []
        hasCompletedOnboarding = false
        notificationsEnabled = true
        
        #if DEBUG
        print("✅ App has been reset.")
        #endif
    }
    
    func deleteAccount() {
        // Cancel all scheduled notifications
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        
        // Clear UserDefaults
        UserDefaults.standard.removeObject(forKey: "userProfile")
        UserDefaults.standard.removeObject(forKey: "userWorkouts")
        UserDefaults.standard.removeObject(forKey: "personalRecords")
        UserDefaults.standard.removeObject(forKey: "reminders")
        UserDefaults.standard.removeObject(forKey: "completionDates")
        UserDefaults.standard.removeObject(forKey: "workoutHistoryMigratedToSwiftData")
        UserDefaults.standard.removeObject(forKey: "lastWeeklyResetDate")
        UserDefaults.standard.removeObject(forKey: "notificationsEnabled")
        
        cancelAutomaticRetry()
        pendingAIWorkouts = []
        showPendingPlanPrompt = false
        
        // Clear SwiftData WorkoutHistory
        if let context = modelContext {
            let historyDescriptor = FetchDescriptor<StoredWorkoutHistory>()
            if let histories = try? context.fetch(historyDescriptor) {
                for history in histories {
                    context.delete(history)
                }
                try? context.save()
            }
        }
        
        // Clear local properties
        profile = nil
        workouts = []
        personalRecords = []
        reminders = []
        completionDates = []
        workoutHistory = []
        hasCompletedOnboarding = false
        notificationsEnabled = true
        
        #if DEBUG
        print("✅ Account has been permanently deleted.")
        #endif
    }
    
    // MARK: - UserDefaults Persistence (for Profile, Workouts, PersonalRecords)
    
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
    
    private func savePersonalRecords() {
        if let encodedData = try? JSONEncoder().encode(personalRecords) {
            UserDefaults.standard.set(encodedData, forKey: "personalRecords")
        }
    }
    
    private func loadPersonalRecords() {
        if let savedData = UserDefaults.standard.data(forKey: "personalRecords"),
           let decodedData = try? JSONDecoder().decode([PersonalRecord].self, from: savedData) {
            self.personalRecords = decodedData
        } else {
            // Seed once on fresh install only
            self.personalRecords = getSampleRecords()
        }
    }
    
    private func saveReminders() {
        if let encodedData = try? JSONEncoder().encode(reminders) {
            UserDefaults.standard.set(encodedData, forKey: "reminders")
        }
    }
    
    private func loadReminders() {
        if let savedData = UserDefaults.standard.data(forKey: "reminders"),
           let decodedData = try? JSONDecoder().decode([Reminder].self, from: savedData) {
            self.reminders = decodedData
        } else {
            // Seed once on fresh install only
            self.reminders = getSampleReminders()
        }
    }
    
    private func saveCompletionDates() {
        if let encodedData = try? JSONEncoder().encode(completionDates) {
            UserDefaults.standard.set(encodedData, forKey: "completionDates")
        }
    }
    
    private func loadCompletionDates() {
        if let savedData = UserDefaults.standard.data(forKey: "completionDates") {
            if let decodedData = try? JSONDecoder().decode([Date].self, from: savedData) {
                self.completionDates = decodedData
            }
        }
    }
    
    // MARK: - SwiftData Persistence (only for WorkoutHistory)
    
    private func saveWorkoutHistory() {
        guard let context = modelContext else { return }
        
        let signature = workoutHistory
            .sorted { $0.id.uuidString < $1.id.uuidString }
            .map { "\($0.id.uuidString)|\($0.date.timeIntervalSince1970)|\($0.workoutDay)|\($0.workoutFocus)|\($0.workoutId?.uuidString ?? "nil")" }
            .joined(separator: "||")
            .hashValue
        
        guard signature != lastSavedWorkoutHistorySignature else { return }
        
        // Fetch existing records from SwiftData
        let descriptor = FetchDescriptor<StoredWorkoutHistory>()
        guard let existingStored = try? context.fetch(descriptor) else {
            #if DEBUG
            print("⚠️ Warning: Could not fetch existing workout history for save")
            #endif
            return
        }
        
        // Create a dictionary of existing records by ID for quick lookup
        let existingById = Dictionary(uniqueKeysWithValues: existingStored.map { ($0.id, $0) })
        
        // Track which IDs are in the current workoutHistory
        let currentIds = Set(workoutHistory.map { $0.id })
        
        // Update or insert records
        for history in workoutHistory {
            if let existing = existingById[history.id] {
                // Update existing record
                existing.date = history.date
                existing.workoutDay = history.workoutDay
                existing.workoutFocus = history.workoutFocus
                existing.workoutId = history.workoutId
            } else {
                // Insert new record
                let stored = StoredWorkoutHistory(from: history)
                context.insert(stored)
            }
        }
        
        // Delete records that are no longer in workoutHistory
        for stored in existingStored {
            if !currentIds.contains(stored.id) {
                context.delete(stored)
            }
        }
        
        // Save changes
        do {
            try context.save()
            lastSavedWorkoutHistorySignature = signature
        } catch {
            #if DEBUG
            print("❌ Error saving workout history: \(error.localizedDescription)")
            #endif
        }
    }
    
    private func loadWorkoutHistory(from context: ModelContext) {
        let descriptor = FetchDescriptor<StoredWorkoutHistory>()
        if let stored = try? context.fetch(descriptor) {
            let calendar = Calendar.current
            // Normalize all dates and enforce strict one-entry-per-day
            let normalizedHistory = stored.map { storedHistory in
                var history = storedHistory.toWorkoutHistory()
                history.date = normalizedWorkoutDay(for: history.date, calendar: calendar)
                return history
            }
            
            var dedupedByDay: [Date: WorkoutHistory] = [:]
            for history in normalizedHistory {
                let day = normalizedWorkoutDay(for: history.date, calendar: calendar)
                
                if let existing = dedupedByDay[day] {
                    // Prefer entry with workoutId because it carries stronger linkage.
                    if existing.workoutId == nil, history.workoutId != nil {
                        dedupedByDay[day] = history
                    }
                } else {
                    dedupedByDay[day] = history
                }
            }
            
            self.workoutHistory = dedupedByDay.values.sorted { $0.date > $1.date }
            self.completionDates = workoutHistory.map { $0.date }
            lastSavedWorkoutHistorySignature = nil
        }
    }
    
}

