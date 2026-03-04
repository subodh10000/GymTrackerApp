import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var userManager: UserManager
    @State private var showingEditReminders = false
    @State private var showContent = false

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.backgroundColor
                    .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        // Welcome header
                        welcomeHeader
                            .opacity(showContent ? 1 : 0)
                            .offset(y: showContent ? 0 : 20)
                        
                        // Workout history section (only show if has history or has workouts)
                        if !userManager.workoutHistory.isEmpty || !userManager.workouts.isEmpty {
                            HomeHistorySection()
                                .opacity(showContent ? 1 : 0)
                                .offset(y: showContent ? 0 : 25)
                        }
                        
                        // Personal records
                        PersonalRecordsView()
                            .opacity(showContent ? 1 : 0)
                            .offset(y: showContent ? 0 : 30)
                        
                        // Reminders
                        if !userManager.reminders.isEmpty {
                        nutritionReminders
                                .opacity(showContent ? 1 : 0)
                                .offset(y: showContent ? 0 : 35)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    .padding(.bottom, 8)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) {
                showContent = true
            }
        }
    }

    private var welcomeHeader: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(AppTheme.primaryGradient)
                .frame(height: 180)
                .shadow(color: AppTheme.primaryColor.opacity(0.3), radius: 16, x: 0, y: 8)
            
            // Decorative circles
            GeometryReader { geo in
                Circle()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 150, height: 150)
                    .offset(x: geo.size.width - 60, y: -30)
                
                Circle()
                    .fill(Color.white.opacity(0.08))
                    .frame(width: 100, height: 100)
                    .offset(x: -30, y: geo.size.height - 40)
            }
            .clipped()

            HStack {
                VStack(alignment: .leading, spacing: 10) {
                    if let name = userManager.profile?.name, !name.isEmpty {
                        Text("Hi, \(name)")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                    } else {
                        Text("Hi there")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                    }
                    
                    Text(greetingMessage)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))
                    
                    // Quick stat - only show if streak > 0
                    if let stats = workoutStats, stats.currentStreak > 0 {
                        HStack(spacing: 6) {
                            Image(systemName: "flame.fill")
                                .font(.system(size: 14))
                            Text("\(stats.currentStreak) week streak")
                                .font(.system(size: 14, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(20)
                        .padding(.top, 4)
                    }
                }
                .padding(.leading, 24)

                Spacer()

                VStack(spacing: 12) {
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            userManager.notificationsEnabled.toggle()
                        }
                    } label: {
                        Image(systemName: userManager.notificationsEnabled ? "bell.fill" : "bell.slash.fill")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 34, height: 34)
                            .background(Color.white.opacity(userManager.notificationsEnabled ? 0.25 : 0.12))
                            .clipShape(Circle())
                    }

                    Image("lad")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 110)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.3), lineWidth: 3)
                        )
                        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                }
                .padding(.trailing, 20)
            }
        }
        .cornerRadius(24)
    }
    
    private var greetingMessage: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good morning! Ready to train?"
        case 12..<17: return "Good afternoon! Time to move?"
        case 17..<21: return "Good evening! Let's crush it!"
        default: return "Ready to work out?"
        }
    }
    
    private var workoutStats: WorkoutStats? {
        guard !userManager.workoutHistory.isEmpty else { return nil }
        return WorkoutStats.calculate(from: userManager.workoutHistory, weeklyGoal: userManager.profile?.daysPerWeek ?? 4)
    }

    private var nutritionReminders: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "bell.badge.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(AppTheme.primaryColor)
                Text("Reminders")
                        .font(.system(size: 18, weight: .bold))
                    .foregroundColor(AppTheme.textPrimaryColor)
                }
                
                Spacer()
                
                Button("Edit") {
                    showingEditReminders = true
                }
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(AppTheme.primaryColor)
            }
            .sheet(isPresented: $showingEditReminders) {
                EditRemindersView()
                    .environmentObject(userManager)
            }

            VStack(spacing: 10) {
                ForEach(userManager.reminders.prefix(4)) { reminder in
                    NutritionReminderCard(
                        icon: reminder.icon,
                        color: reminder.color,
                        text: reminder.text
                    )
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(AppTheme.cardBackgroundColor)
                .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 4)
        )
    }
}

// MARK: - Workout Suggestion State

enum WorkoutSuggestionState {
    case noWorkouts
    case completedToday(workout: Workout)
    case suggestNext(index: Int, workout: Workout, reason: SuggestionReason)
    case weekComplete
    
    enum SuggestionReason {
        case nextInSequence      // Following the training split
        case catchUp             // Missed workout from earlier
        case newWeek             // Fresh start
    }
}

// MARK: - Today's Workout Card

struct TodaysWorkoutCard: View {
    @EnvironmentObject private var userManager: UserManager
    
    // MARK: - Smart Workout Suggestion Logic
    
    private var suggestionState: WorkoutSuggestionState {
        guard !userManager.workouts.isEmpty else { return .noWorkouts }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // Check 1: Did user already complete a workout today?
        if let todayHistory = userManager.workoutHistory.first(where: { 
            calendar.startOfDay(for: $0.date) == today 
        }) {
            // Find the workout they completed (by ID or by matching day/focus)
            if let completedWorkout = userManager.workouts.first(where: { $0.id == todayHistory.workoutId }) {
                return .completedToday(workout: completedWorkout)
            } else if let completedWorkout = userManager.workouts.first(where: { 
                $0.day == todayHistory.workoutDay && $0.focus == todayHistory.workoutFocus 
            }) {
                return .completedToday(workout: completedWorkout)
            }
        }
        
        // Check 2: Are all workouts complete for this week?
        let allComplete = !userManager.workouts.contains { workout in
            workout.exercises.contains { !$0.isCompleted }
        }
        
        if allComplete {
            return .weekComplete
        }
        
        // Check 3: Find the next incomplete workout in sequence
        // This respects the training split (Push → Pull → Legs, etc.)
        if let nextIndex = userManager.workouts.firstIndex(where: { workout in
            workout.exercises.contains { !$0.isCompleted }
        }) {
            let workout = userManager.workouts[nextIndex]
            
            // Determine the reason for suggesting this workout
            let reason: WorkoutSuggestionState.SuggestionReason
            
            // Check if this is a catch-up (missed earlier workout)
            if nextIndex > 0 {
                // Check if there's history indicating we should be further along
                let completedCount = userManager.workouts.prefix(nextIndex).filter { w in
                    !w.exercises.contains { !$0.isCompleted }
                }.count
                
                if completedCount == nextIndex {
                    reason = .nextInSequence
                } else {
                    reason = .catchUp
                }
            } else {
                // First workout - could be new week or just starting
                let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today))!
                let hasHistoryThisWeek = userManager.workoutHistory.contains { 
                    calendar.startOfDay(for: $0.date) >= weekStart 
                }
                reason = hasHistoryThisWeek ? .nextInSequence : .newWeek
            }
            
            return .suggestNext(index: nextIndex, workout: workout, reason: reason)
        }
        
        // Fallback: suggest first workout
        return .suggestNext(index: 0, workout: userManager.workouts[0], reason: .newWeek)
    }
    
    // Legacy computed properties for backward compatibility
    private var todaysWorkout: (index: Int, workout: Workout)? {
        switch suggestionState {
        case .noWorkouts, .weekComplete:
            return nil
        case .completedToday(let workout):
            if let index = userManager.workouts.firstIndex(where: { $0.id == workout.id }) {
                return (index, workout)
            }
            return (0, workout)
        case .suggestNext(let index, let workout, _):
            return (index, workout)
        }
    }
    
    private var isWorkoutComplete: Bool {
        guard let workout = todaysWorkout?.workout else { return false }
        return !workout.exercises.isEmpty && !workout.exercises.contains { !$0.isCompleted }
    }
    
    private var completedCount: Int {
        todaysWorkout?.workout.exercises.filter { $0.isCompleted }.count ?? 0
    }
    
    private var totalCount: Int {
        todaysWorkout?.workout.exercises.count ?? 0
    }
    
    // Check if user already worked out today
    private var hasCompletedWorkoutToday: Bool {
        if case .completedToday = suggestionState {
            return true
        }
        return false
    }
    
    // Check if all workouts are complete for the week
    private var isWeekComplete: Bool {
        if case .weekComplete = suggestionState {
            return true
        }
        return false
    }
    
    // Get suggestion reason text
    private func getSuggestionText(for reason: WorkoutSuggestionState.SuggestionReason) -> String {
        switch reason {
        case .nextInSequence:
            return "Up Next"
        case .catchUp:
            return "Continue From"
        case .newWeek:
            return "Start Fresh"
        }
    }
    
    var body: some View {
        Group {
            switch suggestionState {
            case .noWorkouts:
                emptyWorkoutCard
                
            case .completedToday(let workout):
                if let index = userManager.workouts.firstIndex(where: { $0.id == workout.id }) {
                    NavigationLink(destination: WorkoutDetailView(workoutIndex: index)) {
                        completedTodayCard(workout: workout)
                    }
                    .buttonStyle(PlainButtonStyle())
                } else {
                    completedTodayCard(workout: workout)
                }
                
            case .weekComplete:
                weekCompleteCard
                
            case .suggestNext(let index, let workout, let reason):
                NavigationLink(destination: WorkoutDetailView(workoutIndex: index)) {
                    suggestWorkoutCard(workout: workout, reason: reason)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
    
    // MARK: - Card for Completed Today State
    
    private func completedTodayCard(workout: Workout) -> some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(Color(hex: "22C55E"))
                        
                        Text("Completed Today")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(Color(hex: "22C55E"))
                            .textCase(.uppercase)
                            .tracking(0.5)
                    }
                    
                    Text(workout.day)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(AppTheme.textPrimaryColor)
                    
                    Text(workout.focus)
                        .font(.system(size: 14))
                        .foregroundColor(AppTheme.textSecondaryColor)
                        .lineLimit(1)
                }
                
                Spacer()
                
                // Completed checkmark
                ZStack {
                    Circle()
                        .fill(Color(hex: "22C55E").opacity(0.15))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: "checkmark")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(Color(hex: "22C55E"))
                }
            }
            
            // Great job button
            HStack {
                Text("Great job today!")
                    .font(.system(size: 15, weight: .semibold))
                Image(systemName: "star.fill")
                    .font(.system(size: 12, weight: .semibold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                LinearGradient(colors: [Color(hex: "22C55E"), Color(hex: "16A34A")],
                             startPoint: .leading, endPoint: .trailing)
            )
            .cornerRadius(14)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(AppTheme.cardBackgroundColor)
                .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 4)
        )
    }
    
    // MARK: - Card for Week Complete State
    
    private var weekCompleteCard: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 6) {
                        Image(systemName: "trophy.fill")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(Color(hex: "F59E0B"))
                        
                        Text("Week Complete!")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(Color(hex: "F59E0B"))
                            .textCase(.uppercase)
                            .tracking(0.5)
                    }
                    
                    Text("All Workouts Done")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(AppTheme.textPrimaryColor)
                    
                    Text("You've crushed every workout this week!")
                        .font(.system(size: 14))
                        .foregroundColor(AppTheme.textSecondaryColor)
                        .lineLimit(2)
                }
                
                Spacer()
                
                // Trophy icon
                ZStack {
                    Circle()
                        .fill(Color(hex: "F59E0B").opacity(0.15))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: "trophy.fill")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(Color(hex: "F59E0B"))
                }
            }
            
            // Rest message
            HStack {
                Text("Rest & Recover")
                    .font(.system(size: 15, weight: .semibold))
                Image(systemName: "moon.zzz.fill")
                    .font(.system(size: 12, weight: .semibold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                LinearGradient(colors: [Color(hex: "F59E0B"), Color(hex: "D97706")],
                             startPoint: .leading, endPoint: .trailing)
            )
            .cornerRadius(14)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(AppTheme.cardBackgroundColor)
                .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 4)
        )
    }
    
    // MARK: - Card for Suggested Workout
    
    private func suggestWorkoutCard(workout: Workout, reason: WorkoutSuggestionState.SuggestionReason) -> some View {
        let exerciseCount = workout.exercises.count
        let completedExercises = workout.exercises.filter { $0.isCompleted }.count
        let progress = exerciseCount > 0 ? CGFloat(completedExercises) / CGFloat(exerciseCount) : 0
        
        return VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 6) {
                        Image(systemName: reasonIcon(for: reason))
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(reasonColor(for: reason))
                        
                        Text(getSuggestionText(for: reason))
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(reasonColor(for: reason))
                            .textCase(.uppercase)
                            .tracking(0.5)
                    }
                    
                    Text(workout.day)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(AppTheme.textPrimaryColor)
                    
                    Text(workout.focus)
                        .font(.system(size: 14))
                        .foregroundColor(AppTheme.textSecondaryColor)
                        .lineLimit(1)
                }
                
                Spacer()
                
                // Progress indicator
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.15), lineWidth: 6)
                        .frame(width: 60, height: 60)
                    
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(
                            LinearGradient(colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                                         startPoint: .topLeading, endPoint: .bottomTrailing),
                            style: StrokeStyle(lineWidth: 6, lineCap: .round)
                        )
                        .frame(width: 60, height: 60)
                        .rotationEffect(.degrees(-90))
                    
                    VStack(spacing: 0) {
                        Text("\(completedExercises)")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(AppTheme.textPrimaryColor)
                        Text("/\(exerciseCount)")
                            .font(.system(size: 11))
                            .foregroundColor(AppTheme.textSecondaryColor)
                    }
                }
            }
            
            // Action button
            HStack {
                Text(completedExercises > 0 ? "Continue Workout" : "Start Workout")
                    .font(.system(size: 15, weight: .semibold))
                Image(systemName: completedExercises > 0 ? "arrow.right" : "play.fill")
                    .font(.system(size: 12, weight: .semibold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                LinearGradient(colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                             startPoint: .leading, endPoint: .trailing)
            )
            .cornerRadius(14)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(AppTheme.cardBackgroundColor)
                .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 4)
        )
    }
    
    // Helper functions for suggestion reasons
    private func reasonIcon(for reason: WorkoutSuggestionState.SuggestionReason) -> String {
        switch reason {
        case .nextInSequence: return "arrow.right.circle.fill"
        case .catchUp: return "clock.arrow.circlepath"
        case .newWeek: return "sparkles"
        }
    }
    
    private func reasonColor(for reason: WorkoutSuggestionState.SuggestionReason) -> Color {
        switch reason {
        case .nextInSequence: return AppTheme.primaryColor
        case .catchUp: return Color(hex: "F59E0B")  // Amber for catch-up
        case .newWeek: return Color(hex: "8B5CF6")  // Purple for fresh start
        }
    }
    
    private var emptyWorkoutCard: some View {
        NavigationLink(destination: WorkoutListView()) {
            VStack(spacing: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 6) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(AppTheme.primaryColor)
                            
                            Text("Get Started")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(AppTheme.primaryColor)
                                .textCase(.uppercase)
                                .tracking(0.5)
                        }
                        
                        Text("No Workouts Yet")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(AppTheme.textPrimaryColor)
                        
                        Text("Create your personalized workout plan")
                            .font(.system(size: 14))
                            .foregroundColor(AppTheme.textSecondaryColor)
                            .lineLimit(1)
                    }
                    
                    Spacer()
                    
                    ZStack {
                        Circle()
                            .fill(AppTheme.primaryColor.opacity(0.1))
                            .frame(width: 60, height: 60)
                        
                        Image(systemName: "dumbbell.fill")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(AppTheme.primaryColor)
                    }
                }
                
                // Action button
                HStack {
                    Text("Create Plan")
                        .font(.system(size: 15, weight: .semibold))
                    Image(systemName: "arrow.right")
                        .font(.system(size: 12, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    LinearGradient(colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                                 startPoint: .leading, endPoint: .trailing)
                )
                .cornerRadius(14)
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(AppTheme.cardBackgroundColor)
                    .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 4)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Supporting Views

struct PersonalRecordRow: View {
    let name: String
    let value: String

    var body: some View {
        HStack {
            Text(name)
                .font(.headline)
                .foregroundColor(AppTheme.textPrimaryColor)
            Spacer()
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(AppTheme.textSecondaryColor)
        }
        .padding(.vertical, 4)
    }
}

struct NutritionReminderCard: View {
    let icon: String
    let color: Color
    let text: String

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(color.opacity(0.12))
                    .frame(width: 42, height: 42)

                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(color)
            }

            Text(text)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(AppTheme.textPrimaryColor)
                .lineLimit(2)

            Spacer()
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(AppTheme.cardBackgroundColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(AppTheme.textSecondaryColor.opacity(0.08), lineWidth: 1)
                )
        )
    }
}

struct ProgressCard: View {
    let progress: Double
    let value: String
    let total: String
    let label: String
    let color: Color
    
    private var safeProgressValue: CGFloat {
        guard progress.isFinite else { return 0 }
        return CGFloat(max(0, min(1, progress)))
    }

    var body: some View {
        VStack(spacing: 15) {
            ZStack {
                Circle()
                    .stroke(color.opacity(0.2), lineWidth: 10)
                    .frame(width: 80, height: 80)

                Circle()
                    .trim(from: 0, to: safeProgressValue)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [color, color.opacity(0.7)]),
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        style: StrokeStyle(lineWidth: 10, lineCap: .round)
                    )
                    .frame(width: 80, height: 80)
                    .rotationEffect(Angle(degrees: -90))
                    .animation(.easeInOut, value: progress)

                VStack(spacing: 0) {
                    Text(value)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(color)

                    Text("/ \(total)")
                        .font(.caption)
                        .foregroundColor(AppTheme.textSecondaryColor)
                }
            }

            Text(label)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(AppTheme.textSecondaryColor)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(AppTheme.cardBackgroundColor)
                .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 3)
        )
    }
}

// MARK: - Preview

#if DEBUG
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        let userManager = UserManager()
        userManager.profile = UserProfile(
            name: "John",
            age: 30,
            gender: .male,
            height: 72,
            weight: 180,
            fitnessLevel: .intermediate,
            goal: .strength,
            daysPerWeek: 4,
            sessionDurationHours: 1.5,
            workoutEnvironment: .gym,
            avatarName: "lad"
        )
        return HomeView()
            .environmentObject(userManager)
    }
}
#endif
