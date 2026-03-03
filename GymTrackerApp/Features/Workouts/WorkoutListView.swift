import SwiftUI

@MainActor
final class WorkoutListViewModel: ObservableObject {
    @Published var showingResetAlert = false

    func triggerResetConfirmation() {
        showingResetAlert = true
    }

    func confirmReset(using userManager: UserManager) {
        userManager.resetApp()
        showingResetAlert = false
    }
}

struct WorkoutListView: View {
    @EnvironmentObject private var userManager: UserManager
    @StateObject private var viewModel = WorkoutListViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.backgroundColor
                    .ignoresSafeArea()
                
                ScrollView {
                    if userManager.workouts.isEmpty {
                        emptyStateView
                    } else {
                        VStack(spacing: 15) {
                            ForEach(Array(userManager.workouts.enumerated()), id: \.element.id) { index, workout in
                                NavigationLink(destination: WorkoutDetailView(workoutIndex: index)) {
                                    WorkoutCard(workout: workout)
                                }
                                .buttonStyle(PlainButtonStyle())
                                .transition(.asymmetric(
                                    insertion: .move(edge: .trailing).combined(with: .opacity),
                                    removal: .move(edge: .leading).combined(with: .opacity)
                                ))
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Weekly Workouts")
            .toolbar {
                if !userManager.workouts.isEmpty {
                    Button(action: {
                        viewModel.triggerResetConfirmation()
                    }) {
                        Text("New Plan")
                            .foregroundColor(AppTheme.accentColor)
                    }
                }
            }
            .alert(isPresented: $viewModel.showingResetAlert) {
                Alert(
                    title: Text("Generate New Plan?"),
                    message: Text("This will clear your current workouts and let you create a new plan. Are you sure?"),
                    primaryButton: .destructive(Text("Yes, Create New Plan")) {
                        viewModel.confirmReset(using: userManager)
                    },
                    secondaryButton: .cancel()
                )
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "dumbbell.fill")
                .font(.system(size: 60))
                .foregroundColor(AppTheme.primaryColor.opacity(0.5))
            
            VStack(spacing: 8) {
                Text("No Workouts Yet")
                    .font(.title2.weight(.bold))
                    .foregroundColor(AppTheme.textPrimaryColor)
                
                Text("Generate a personalized workout plan to get started on your fitness journey.")
                    .font(.subheadline)
                    .foregroundColor(AppTheme.textSecondaryColor)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            Button(action: {
                viewModel.confirmReset(using: userManager)
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "plus.circle.fill")
                    Text("Create Workout Plan")
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 14)
                .background(
                    LinearGradient(
                        colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(16)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

struct WorkoutCard: View {
    let workout: Workout
    @State private var isPressed = false

    var body: some View {
        let completedExercises = workout.exercises.filter { $0.isCompleted }.count
        let totalExercises = workout.exercises.count
        let progress = totalExercises > 0 ? Double(completedExercises) / Double(totalExercises) : 0.0
        let isComplete = completedExercises == totalExercises && totalExercises > 0
        
        VStack(spacing: 0) {
            HStack(alignment: .top, spacing: 15) {
                // Day indicator with gradient
                ZStack {
                    Circle()
                        .fill(WorkoutGradientProvider.gradient(for: workout.day))
                        .frame(width: 56, height: 56)
                        .shadow(color: Color.black.opacity(0.15), radius: 5, x: 0, y: 3)

                    VStack(spacing: 2) {
                        Text(String(workout.day.prefix(3)))
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.white.opacity(0.9))
                        Text(String(workout.day.prefix(1)))
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    // Status badge
                    if isComplete {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 10))
                            Text("COMPLETE")
                                .font(.system(size: 10, weight: .bold))
                        }
                        .foregroundColor(Color(hex: "22C55E"))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color(hex: "22C55E").opacity(0.12))
                        .cornerRadius(6)
                    }
                    
                    Text(workout.day)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(AppTheme.textPrimaryColor)

                    Text(workout.focus)
                        .font(.system(size: 14))
                        .foregroundColor(AppTheme.textSecondaryColor)
                        .lineLimit(2)
                    
                    // Exercise count
                    HStack(spacing: 4) {
                        Image(systemName: "dumbbell.fill")
                            .font(.system(size: 11))
                        Text("\(totalExercises) exercises")
                            .font(.system(size: 12, weight: .medium))
                    }
                    .foregroundColor(AppTheme.textSecondaryColor)
                    .padding(.top, 2)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppTheme.textSecondaryColor.opacity(0.5))
                    .padding(.top, 8)
            }
            .padding(16)
            
            // Progress bar at bottom
            if totalExercises > 0 && !isComplete {
                VStack(spacing: 8) {
                    Divider()
                        .padding(.horizontal, 16)
                    
                    HStack {
                        Text("Progress")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(AppTheme.textSecondaryColor)
                        
                        Spacer()
                        
                        Text("\(completedExercises)/\(totalExercises)")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(completedExercises > 0 ? AppTheme.primaryColor : AppTheme.textSecondaryColor)
                    }
                    .padding(.horizontal, 16)
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color.gray.opacity(0.15))
                                .frame(height: 6)
                            
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geometry.size.width * CGFloat(progress), height: 6)
                                .animation(.spring(response: 0.3), value: progress)
                        }
                    }
                    .frame(height: 6)
                    .padding(.horizontal, 16)
                }
                .padding(.bottom, 14)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(AppTheme.cardBackgroundColor)
                .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 6)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(isComplete ? Color(hex: "22C55E").opacity(0.3) : Color.clear, lineWidth: 2)
        )
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.spring(response: 0.3), value: isPressed)
    }
}

@MainActor
final class WorkoutDetailViewModel: ObservableObject {
    func toggleExercise(
        in userManager: UserManager,
        workoutIndex: Int,
        exerciseIndex: Int
    ) {
        userManager.toggleExerciseCompletion(workoutIndex: workoutIndex, exerciseIndex: exerciseIndex)
    }
}

struct WorkoutDetailView: View {
    @EnvironmentObject private var userManager: UserManager
    let workoutIndex: Int
    @State private var showingEditView = false
    @State private var showCompletionCelebration = false
    @StateObject private var viewModel = WorkoutDetailViewModel()
    
    // Get workout dynamically from userManager to ensure reactivity
    private var workout: Workout? {
        guard workoutIndex < userManager.workouts.count else { return nil }
        return userManager.workouts[workoutIndex]
    }
    
    private var isWorkoutComplete: Bool {
        guard let workout = workout else { return false }
        return !workout.exercises.isEmpty && !workout.exercises.contains { !$0.isCompleted }
    }

    var body: some View {
        ZStack {
            AppTheme.backgroundColor
                .ignoresSafeArea()
            
            ScrollView {
                if let workout = workout {
                    VStack(alignment: .leading, spacing: 20) {
                        exerciseList(for: workout)
                    }
                    .padding(.top, 10)
                } else {
                    Text("Workout not found")
                        .foregroundColor(AppTheme.textSecondaryColor)
                        .padding()
                }
            }
            
            // Completion celebration overlay
            if showCompletionCelebration {
                WorkoutCompletionCelebration {
                    withAnimation(.spring(response: 0.4)) {
                        showCompletionCelebration = false
                    }
                }
                .transition(.opacity.combined(with: .scale(scale: 0.8)))
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(workout?.day ?? "Workout")
        .sheet(isPresented: $showingEditView) {
            EditWorkoutView(workoutIndex: workoutIndex)
        }
        .onChange(of: isWorkoutComplete) { oldValue, newValue in
            guard !oldValue, newValue else { return }
            
            withAnimation(.spring(response: 0.5)) {
                showCompletionCelebration = true
            }
            
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        }
    }

    private func exerciseList(for workout: Workout) -> some View {
        let completedCount = workout.exercises.filter { $0.isCompleted }.count
        let totalCount = workout.exercises.count
        let progress = totalCount > 0 ? Double(completedCount) / Double(totalCount) : 0.0
        
        return VStack(alignment: .leading, spacing: 0) {
            // Header with progress
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Exercises")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(AppTheme.textPrimaryColor)
                        
                        if totalCount > 0 {
                            Text("\(completedCount) of \(totalCount) completed")
                                .font(.subheadline)
                                .foregroundColor(AppTheme.textSecondaryColor)
                        }
                    }
                    
                    Spacer()
                    
                    Button(action: { showingEditView = true }) {
                        HStack(spacing: 6) {
                            Image(systemName: "slider.horizontal.3")
                            Text("Customize")
                        }
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(
                            LinearGradient(
                                colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                        .shadow(color: AppTheme.primaryColor.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                }
                
                // Progress bar
                if totalCount > 0 {
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color.gray.opacity(0.15))
                                .frame(height: 8)
                            
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: completedCount == totalCount
                                            ? [Color.green, Color.green.opacity(0.8)]
                                            : [AppTheme.primaryColor, AppTheme.secondaryColor],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geometry.size.width * CGFloat(progress), height: 8)
                                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: progress)
                        }
                    }
                    .frame(height: 8)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 20)
            
            // Exercise list with better spacing
            VStack(spacing: 12) {
                ForEach(Array(workout.exercises.enumerated()), id: \.element.id) { index, exercise in
                    ExerciseRow(
                        exercise: exercise,
                        isCompleted: exercise.isCompleted,
                        toggleCompletion: {
                            // Haptic feedback
                            let generator = UIImpactFeedbackGenerator(style: .medium)
                            generator.impactOccurred()
                            
                            viewModel.toggleExercise(in: userManager, workoutIndex: workoutIndex, exerciseIndex: index)
                        }
                    )
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
    }
}


// MARK: - Workout Completion Celebration

struct WorkoutCompletionCelebration: View {
    let onDismiss: () -> Void
    @State private var showContent = false
    @State private var confettiAnimation = false
    
    var body: some View {
        ZStack {
            // Background blur
            Color.black.opacity(0.7)
                .ignoresSafeArea()
                .onTapGesture { onDismiss() }
            
            // Celebration content
            VStack(spacing: 24) {
                // Success icon with animation
                ZStack {
                    // Outer rings
                    ForEach(0..<3) { i in
                        Circle()
                            .stroke(Color(hex: "22C55E").opacity(0.2 - Double(i) * 0.05), lineWidth: 3)
                            .frame(width: CGFloat(120 + i * 30), height: CGFloat(120 + i * 30))
                            .scaleEffect(confettiAnimation ? 1.2 : 0.8)
                            .opacity(confettiAnimation ? 0 : 1)
                    }
                    
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "22C55E"), Color(hex: "16A34A")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 100, height: 100)
                        .shadow(color: Color(hex: "22C55E").opacity(0.5), radius: 20, x: 0, y: 10)
                    
                    Image(systemName: "checkmark")
                        .font(.system(size: 44, weight: .bold))
                        .foregroundColor(.white)
                }
                .scaleEffect(showContent ? 1 : 0.5)
                .opacity(showContent ? 1 : 0)
                
                VStack(spacing: 12) {
                    Text("Workout Complete!")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Great job! Your progress has been saved.")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                }
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 20)
                
                // Stats row
                HStack(spacing: 30) {
                    CelebrationStat(icon: "flame.fill", value: "Great", label: "effort", color: Color(hex: "F97316"))
                    CelebrationStat(icon: "trophy.fill", value: "+1", label: "workout", color: Color(hex: "F59E0B"))
                }
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 20)
                
                // Dismiss button
                Button(action: onDismiss) {
                    Text("Continue")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: [Color(hex: "22C55E"), Color(hex: "16A34A")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(16)
                }
                .padding(.horizontal, 40)
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 20)
            }
            .padding(30)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                showContent = true
            }
            withAnimation(.easeOut(duration: 1.5).repeatForever(autoreverses: false)) {
                confettiAnimation = true
            }
        }
    }
}

struct CelebrationStat: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
            
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.7))
        }
    }
}

#if DEBUG
struct WorkoutListView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutListView()
            .environmentObject(UserManager())
    }
}
#endif

