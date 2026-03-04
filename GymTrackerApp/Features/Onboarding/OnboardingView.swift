import SwiftUI
import UIKit

// MARK: - Main Onboarding View

struct OnboardingView: View {
    @EnvironmentObject var userManager: UserManager

    // User input state
    @State private var name: String = ""
    @State private var gender: Gender = .male
    @State private var age: Int = 25
    @State private var heightFeet: Int = 5
    @State private var heightInches: Int = 8
    @State private var weight: Int = 150
    @State private var fitnessLevel: FitnessLevel = .intermediate
    @State private var goal: Goal = .muscleGain
    @State private var daysPerWeek: Int = 4
    @State private var sessionDuration: Double = 1.5
    @State private var workoutEnvironment: WorkoutEnvironment = .gym

    // UI state
    @State private var currentStep: Int = 0
    @State private var isGeneratingPlan = false
    @State private var showMotivationalScreen = false
    @State private var timeoutTimer: Timer?
    @State private var observationTimer: Timer?
    @State private var elapsedTime: TimeInterval = 0
    private let maxWaitTime: TimeInterval = 35.0

    private let totalSteps = 8

    var body: some View {
        ZStack {
            // Animated gradient background
            AnimatedGradientBackground()
            
            if showMotivationalScreen {
                MotivationalLoadingView()
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
            } else {
                onboardingContent
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.4), value: showMotivationalScreen)
        .preferredColorScheme(.dark)
        .alert("Connection Issue", isPresented: $userManager.showNetworkError) {
            Button("Continue Anyway") {
                if !userManager.workouts.isEmpty {
                    showMotivationalScreen = false
                    isGeneratingPlan = false
                }
            }
            Button("Retry", role: .cancel) {
                retryWorkoutGeneration()
            }
        } message: {
            Text("We couldn't connect to generate your personalized plan. You can continue with a default workout plan or try again.")
        }
        .onChange(of: userManager.hasCompletedOnboarding) {
            if userManager.hasCompletedOnboarding {
                stopTimers()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        showMotivationalScreen = false
                        isGeneratingPlan = false
                    }
                }
            }
        }
        .onDisappear {
            stopTimers()
        }
    }
    
    private var onboardingContent: some View {
        VStack(spacing: 0) {
            // Top bar with progress
            OnboardingTopBar(
                currentStep: currentStep,
                totalSteps: totalSteps,
                onBack: goBack
            )
            .padding(.top, 8)
            
            // Main content area
            TabView(selection: $currentStep) {
                WelcomeStep(onContinue: goNext)
                    .tag(0)
                
                NameStep(name: $name, onContinue: goNext)
                    .tag(1)
                
                GenderStep(gender: $gender, onContinue: goNext)
                    .tag(2)
                
                BodyMetricsStep(
            age: $age,
            heightFeet: $heightFeet,
            heightInches: $heightInches,
            weight: $weight,
                    onContinue: goNext
                )
                .tag(3)
                
                FitnessLevelStep(fitnessLevel: $fitnessLevel, onContinue: goNext)
                    .tag(4)
                
                GoalStep(goal: $goal, onContinue: goNext)
                    .tag(5)
                
                ScheduleStep(
            daysPerWeek: $daysPerWeek,
            sessionDuration: $sessionDuration,
                    onContinue: goNext
                )
                .tag(6)
                
                EnvironmentStep(
                    workoutEnvironment: $workoutEnvironment,
            onCreatePlan: createProfileAndFetchPlan,
                    isGenerating: isGeneratingPlan
                )
                .tag(7)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.spring(response: 0.5, dampingFraction: 0.85), value: currentStep)
        }
    }
    
    private func goNext() {
        dismissKeyboard()
        if currentStep < totalSteps - 1 {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) {
                currentStep += 1
            }
        }
    }
    
    private func goBack() {
        dismissKeyboard()
        if currentStep > 0 {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) {
                currentStep -= 1
            }
        }
    }

    private func createProfileAndFetchPlan() {
        isGeneratingPlan = true
        showMotivationalScreen = true
        elapsedTime = 0
        
        let totalHeightInches = Double(heightFeet * 12 + heightInches)

        let userProfile = UserProfile(
            name: name,
            age: age,
            gender: gender,
            height: totalHeightInches,
            weight: Double(weight),
            fitnessLevel: fitnessLevel,
            goal: goal,
            daysPerWeek: daysPerWeek,
            sessionDurationHours: sessionDuration,
            workoutEnvironment: workoutEnvironment
        )

        userManager.saveProfileAndGenerateWorkouts(profile: userProfile)
        NotificationManager.shared.requestAuthorization(userManager: userManager)

        startTimers()
    }
    
    private func startTimers() {
        stopTimers()
        
        timeoutTimer = Timer.scheduledTimer(withTimeInterval: maxWaitTime, repeats: false) { _ in
            if userManager.workouts.isEmpty {
                userManager.loadFallbackWorkouts()
            }
        }
        
        observationTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            guard isGeneratingPlan else {
                timer.invalidate()
                return
            }
            
            elapsedTime += 1.0
            
            if !userManager.workouts.isEmpty {
                stopTimers()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        showMotivationalScreen = false
                        isGeneratingPlan = false
                    }
                }
            } else if elapsedTime >= maxWaitTime {
                stopTimers()
            }
        }
    }
    
    private func stopTimers() {
        timeoutTimer?.invalidate()
        timeoutTimer = nil
        observationTimer?.invalidate()
        observationTimer = nil
    }
    
    private func retryWorkoutGeneration() {
        stopTimers()
        showMotivationalScreen = true
        isGeneratingPlan = true
        elapsedTime = 0
        
        if let profile = userManager.profile {
            userManager.saveProfileAndGenerateWorkouts(profile: profile)
            startTimers()
        }
    }
    
    private func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// MARK: - Animated Gradient Background

struct AnimatedGradientBackground: View {
    @State private var animateGradient = false

    var body: some View {
        ZStack {
            // Base dark gradient
            LinearGradient(
                colors: [
                    Color(hex: "0B0F1E"),
                    Color(hex: "111827"),
                    Color(hex: "0F172A")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Animated accent orbs
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            AppTheme.primaryColor.opacity(0.4),
                            AppTheme.primaryColor.opacity(0.1),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 20,
                        endRadius: 200
                    )
                )
                .frame(width: 400, height: 400)
                .offset(x: animateGradient ? 100 : -100, y: animateGradient ? -200 : -150)
                .blur(radius: 60)
            
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            AppTheme.secondaryColor.opacity(0.3),
                            AppTheme.secondaryColor.opacity(0.05),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 20,
                        endRadius: 180
                    )
                )
                .frame(width: 350, height: 350)
                .offset(x: animateGradient ? -80 : 80, y: animateGradient ? 300 : 250)
                .blur(radius: 50)
        }
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.easeInOut(duration: 8).repeatForever(autoreverses: true)) {
                animateGradient = true
            }
        }
    }
}

// MARK: - Top Bar with Progress

struct OnboardingTopBar: View {
    let currentStep: Int
    let totalSteps: Int
    let onBack: () -> Void

    var body: some View {
        HStack(spacing: 16) {
            // Back button
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white.opacity(0.8))
                    .frame(width: 44, height: 44)
                    .background(Color.white.opacity(0.08))
                    .clipShape(Circle())
            }
            .opacity(currentStep > 0 ? 1 : 0)
            .disabled(currentStep == 0)
            
            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    // Background track
                    Capsule()
                        .fill(Color.white.opacity(0.1))
                        .frame(height: 6)
                    
                    // Progress fill
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: progressWidth(for: geo.size.width), height: 6)
                        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: currentStep)
                }
            }
            .frame(height: 6)
            
            // Step indicator
            Text("\(currentStep + 1)/\(totalSteps)")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.6))
                .frame(width: 44)
        }
        .padding(.horizontal, 24)
            .padding(.vertical, 16)
    }
    
    private func progressWidth(for totalWidth: CGFloat) -> CGFloat {
        let progress = CGFloat(currentStep + 1) / CGFloat(totalSteps)
        return totalWidth * progress
    }
}

// MARK: - Step Container

struct StepContainer<Content: View, Bottom: View>: View {
    let content: Content
    let bottomView: Bottom
    
    init(@ViewBuilder content: () -> Content, @ViewBuilder bottom: () -> Bottom) {
        self.content = content()
        self.bottomView = bottom()
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    content
                }
                .padding(.horizontal, 28)
                .padding(.top, 20)
                .padding(.bottom, 20)
            }
            
            bottomView
                .padding(.horizontal, 28)
                .padding(.bottom, 16)
        }
    }
}

// MARK: - Welcome Step

struct WelcomeStep: View {
    let onContinue: () -> Void
    @State private var showContent = false
    
    var body: some View {
        StepContainer {
            VStack(spacing: 24) {
                Spacer()
                    .frame(height: 20)
                
                // App icon with glow
                ZStack {
                    Circle()
                        .fill(AppTheme.primaryGradient)
                        .frame(width: 110, height: 110)
                        .shadow(color: AppTheme.primaryColor.opacity(0.5), radius: 30, x: 0, y: 10)
                    
                    Image(systemName: "dumbbell.fill")
                        .font(.system(size: 46, weight: .bold))
                        .foregroundColor(.white)
                }
                .scaleEffect(showContent ? 1 : 0.5)
                .opacity(showContent ? 1 : 0)
                
                VStack(spacing: 12) {
                    Text("Welcome to")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                    
                    Text("GymTracker")
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .foregroundStyle(
        LinearGradient(
                                colors: [.white, .white.opacity(0.85)],
            startPoint: .leading,
            endPoint: .trailing
        )
                        )
                    
                    Text("Your personalized fitness journey\nstarts here")
                        .font(.system(size: 17, weight: .regular))
                        .foregroundColor(.white.opacity(0.6))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 20)
                
                Spacer()
                    .frame(height: 24)
                
                // Feature highlights
                VStack(spacing: 14) {
                    FeatureRow(icon: "sparkles", text: "AI-powered workout plans", color: AppTheme.primaryColor)
                    FeatureRow(icon: "chart.line.uptrend.xyaxis", text: "Track your progress", color: AppTheme.secondaryColor)
                    FeatureRow(icon: "figure.strengthtraining.traditional", text: "Customized for your goals", color: Color(hex: "F97316"))
                }
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 30)
            }
        } bottom: {
            PrimaryButton(title: "Let's Get Started", action: onContinue)
                .opacity(showContent ? 1 : 0)
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.1)) {
                showContent = true
            }
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
        ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 48, height: 48)
                
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(color)
            }
            
            Text(text)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white.opacity(0.9))
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
    }
}

// MARK: - Name Step

struct NameStep: View {
    @Binding var name: String
    let onContinue: () -> Void
    @State private var showContent = false
    @FocusState private var isNameFocused: Bool
    
    private var canContinue: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        StepContainer {
            VStack(spacing: 28) {
                Spacer()
                    .frame(height: 30)
                
                // Icon
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [AppTheme.primaryColor.opacity(0.2), AppTheme.primaryColor.opacity(0.05)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 100, height: 100)
                    
                    Image(systemName: "person.fill")
                        .font(.system(size: 44, weight: .medium))
                        .foregroundStyle(AppTheme.primaryGradient)
                }
                .scaleEffect(showContent ? 1 : 0.8)
                .opacity(showContent ? 1 : 0)

                VStack(spacing: 12) {
                    Text("What should we call you?")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    Text("This is how we'll greet you in the app")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.white.opacity(0.6))
                }
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 15)

                Spacer()
                    .frame(height: 16)
                
                // Name input
                    VStack(alignment: .leading, spacing: 8) {
                    TextField("", text: $name, prompt: Text("Enter your name").foregroundColor(.white.opacity(0.3)))
                        .font(.system(size: 20, weight: .medium))
                                .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 18)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white.opacity(0.08))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(
                                            isNameFocused ? AppTheme.primaryColor : Color.white.opacity(0.1),
                                            lineWidth: isNameFocused ? 2 : 1
                                        )
                                )
                        )
                        .focused($isNameFocused)
                                .submitLabel(.done)
                                .onSubmit {
                            if canContinue {
                                onContinue()
                            }
                        }
                }
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 20)
            }
        } bottom: {
            PrimaryButton(title: "Continue", action: onContinue, isEnabled: canContinue)
                .opacity(showContent ? 1 : 0)
        }
        .onAppear {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.8).delay(0.1)) {
                showContent = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isNameFocused = true
            }
        }
    }
}

// MARK: - Gender Step

struct GenderStep: View {
    @Binding var gender: Gender
    let onContinue: () -> Void
    @State private var showContent = false

    var body: some View {
        StepContainer {
            VStack(spacing: 28) {
                Spacer()
                    .frame(height: 30)
                
                // Icon
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [AppTheme.secondaryColor.opacity(0.2), AppTheme.secondaryColor.opacity(0.05)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 100, height: 100)
                    
                    Image(systemName: "person.2.fill")
                        .font(.system(size: 40, weight: .medium))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [AppTheme.secondaryColor, AppTheme.primaryColor],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                .scaleEffect(showContent ? 1 : 0.8)
                .opacity(showContent ? 1 : 0)

                VStack(spacing: 12) {
                    Text("How do you identify?")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    Text("This helps us customize your workouts")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.white.opacity(0.6))
                }
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 15)
                
                Spacer()
                    .frame(height: 16)
                
                // Gender selection
                HStack(spacing: 16) {
                    GenderCard(
                        title: "Male",
                        icon: "figure.stand",
                        isSelected: gender == .male,
                        color: Color(hex: "4F8EF7")
                    ) {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                            gender = .male
                        }
                    }
                    
                    GenderCard(
                        title: "Female",
                        icon: "figure.stand.dress",
                        isSelected: gender == .female,
                        color: Color(hex: "E879F9")
                    ) {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                            gender = .female
                        }
                    }
                }
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 20)
            }
        } bottom: {
            PrimaryButton(title: "Continue", action: onContinue)
                .opacity(showContent ? 1 : 0)
        }
        .onAppear {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.8).delay(0.1)) {
                showContent = true
            }
        }
    }
}

struct GenderCard: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(color.opacity(isSelected ? 0.25 : 0.1))
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: icon)
                        .font(.system(size: 36, weight: .medium))
                        .foregroundColor(isSelected ? color : .white.opacity(0.5))
                }
                
                Text(title)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(isSelected ? .white : .white.opacity(0.6))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 28)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white.opacity(isSelected ? 0.12 : 0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(isSelected ? color : Color.clear, lineWidth: 2)
                    )
            )
            .scaleEffect(isSelected ? 1.02 : 1)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Body Metrics Step

struct BodyMetricsStep: View {
    @Binding var age: Int
    @Binding var heightFeet: Int
    @Binding var heightInches: Int
    @Binding var weight: Int
    let onContinue: () -> Void
    @State private var showContent = false

    var body: some View {
        StepContainer {
            VStack(spacing: 20) {
                Spacer()
                    .frame(height: 10)
                
                VStack(spacing: 12) {
                    Text("Your Body Metrics")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    Text("We use this to calculate your ideal workouts")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.white.opacity(0.6))
                }
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 15)
                
                // Age selector
                MetricCard(
                    title: "Age",
                    icon: "calendar",
                    value: "\(age)",
                    unit: "years"
                ) {
                    CustomStepper(value: $age, range: 16...80, step: 1)
                }
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 20)
                
                // Height selector
                MetricCard(
                    title: "Height",
                    icon: "ruler",
                    value: "\(heightFeet)'\(heightInches)\"",
                    unit: ""
                ) {
                    HStack(spacing: 24) {
                        VStack(spacing: 4) {
                            Text("ft")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.white.opacity(0.5))
                            CustomStepper(value: $heightFeet, range: 4...7, step: 1, compact: true)
                        }
                        
                        VStack(spacing: 4) {
                            Text("in")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.white.opacity(0.5))
                            CustomStepper(value: $heightInches, range: 0...11, step: 1, compact: true)
                        }
                    }
                }
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 25)
                
                // Weight selector
                MetricCard(
                    title: "Weight",
                    icon: "scalemass",
                    value: "\(weight)",
                    unit: "lbs"
                ) {
                    CustomStepper(value: $weight, range: 80...400, step: 5)
                }
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 30)
            }
        } bottom: {
            PrimaryButton(title: "Continue", action: onContinue)
                .opacity(showContent ? 1 : 0)
        }
        .onAppear {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.8).delay(0.1)) {
                showContent = true
            }
        }
    }
}

struct MetricCard<Content: View>: View {
    let title: String
    let icon: String
    let value: String
    let unit: String
    let content: Content
    
    init(title: String, icon: String, value: String, unit: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.value = value
        self.unit = unit
        self.content = content()
    }

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                HStack(spacing: 10) {
                Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppTheme.primaryColor)
                    
                Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
                
                HStack(spacing: 4) {
                    Text(value)
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                    
                    if !unit.isEmpty {
                        Text(unit)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.5))
                    }
                }
            }
            
            content
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.06))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
        )
    }
}

struct CustomStepper: View {
    @Binding var value: Int
    let range: ClosedRange<Int>
    let step: Int
    var compact: Bool = false
    
    var body: some View {
        HStack(spacing: compact ? 12 : 20) {
            Button {
                if value - step >= range.lowerBound {
                    withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                        value -= step
                    }
                }
            } label: {
                Image(systemName: "minus")
                    .font(.system(size: compact ? 14 : 16, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: compact ? 36 : 44, height: compact ? 36 : 44)
                    .background(
                        Circle()
                            .fill(Color.white.opacity(0.1))
                    )
            }
            .disabled(value <= range.lowerBound)
            .opacity(value <= range.lowerBound ? 0.4 : 1)
            
            if !compact {
                        Spacer()
            }
            
            Button {
                if value + step <= range.upperBound {
                    withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                        value += step
                    }
                }
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: compact ? 14 : 16, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: compact ? 36 : 44, height: compact ? 36 : 44)
                    .background(
                        Circle()
                            .fill(AppTheme.primaryColor.opacity(0.3))
                    )
            }
            .disabled(value >= range.upperBound)
            .opacity(value >= range.upperBound ? 0.4 : 1)
        }
    }
}

// MARK: - Fitness Level Step

struct FitnessLevelStep: View {
    @Binding var fitnessLevel: FitnessLevel
    let onContinue: () -> Void
    @State private var showContent = false
    
    private let levels: [(FitnessLevel, String, String, String)] = [
        (.beginner, "Beginner", "New to fitness or returning after a break", "figure.walk"),
        (.intermediate, "Intermediate", "Work out regularly with some experience", "figure.run"),
        (.advanced, "Advanced", "Experienced athlete with consistent training", "figure.highintensity.intervaltraining")
    ]
    
    var body: some View {
        StepContainer {
            VStack(spacing: 24) {
                        Spacer()
                    .frame(height: 16)
                
                VStack(spacing: 12) {
                    Text("What's your fitness level?")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    Text("Be honest — we'll match your workouts accordingly")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.white.opacity(0.6))
                        .multilineTextAlignment(.center)
                }
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 15)
                
                VStack(spacing: 14) {
                    ForEach(Array(levels.enumerated()), id: \.offset) { index, level in
                        FitnessLevelCard(
                            level: level.0,
                            title: level.1,
                            description: level.2,
                            icon: level.3,
                            isSelected: fitnessLevel == level.0
                        ) {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                                fitnessLevel = level.0
                            }
                        }
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : CGFloat(20 + index * 10))
                    }
                }
            }
        } bottom: {
            PrimaryButton(title: "Continue", action: onContinue)
                .opacity(showContent ? 1 : 0)
        }
        .onAppear {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.8).delay(0.1)) {
                showContent = true
            }
        }
    }
}

struct FitnessLevelCard: View {
    let level: FitnessLevel
    let title: String
    let description: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    private var levelColor: Color {
        switch level {
        case .beginner: return Color(hex: "4ECDC4")
        case .intermediate: return AppTheme.primaryColor
        case .advanced: return Color(hex: "F97316")
        }
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(levelColor.opacity(isSelected ? 0.25 : 0.1))
                        .frame(width: 56, height: 56)
                    
                Image(systemName: icon)
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(isSelected ? levelColor : .white.opacity(0.5))
                }
                
                VStack(alignment: .leading, spacing: 4) {
                Text(title)
                        .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                    
                    Text(description)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.white.opacity(0.5))
                        .lineLimit(2)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(levelColor)
                }
            }
            .padding(18)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color.white.opacity(isSelected ? 0.1 : 0.05))
        .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(isSelected ? levelColor : Color.clear, lineWidth: 2)
                    )
            )
            .scaleEffect(isSelected ? 1.01 : 1)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Goal Step

struct GoalStep: View {
    @Binding var goal: Goal
    let onContinue: () -> Void
    @State private var showContent = false
    
    private let goals: [(Goal, String, String, String, [Color])] = [
        (.muscleGain, "Build Muscle", "Gain strength and size", "dumbbell.fill", [Color(hex: "FF6B6B"), Color(hex: "FF8E53")]),
        (.fatLoss, "Lose Fat", "Burn calories and tone up", "flame.fill", [Color(hex: "4ECDC4"), Color(hex: "44A08D")]),
        (.strength, "Get Stronger", "Increase power and performance", "bolt.fill", [Color(hex: "667EEA"), Color(hex: "764BA2")]),
        (.endurance, "Build Endurance", "Improve stamina and cardio", "figure.run", [Color(hex: "F093FB"), Color(hex: "F5576C")]),
        (.flexibility, "Improve Flexibility", "Enhance mobility and range", "figure.flexibility", [Color(hex: "4FACFE"), Color(hex: "00F2FE")])
    ]

    var body: some View {
        StepContainer {
            VStack(spacing: 20) {
                Spacer()
                    .frame(height: 10)
                
                VStack(spacing: 12) {
                    Text("What's your main goal?")
                        .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    Text("Choose your primary fitness objective")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.white.opacity(0.6))
                }
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 15)
                
                VStack(spacing: 10) {
                    ForEach(Array(goals.enumerated()), id: \.offset) { index, goalData in
                        GoalOptionCard(
                            goal: goalData.0,
                            title: goalData.1,
                            description: goalData.2,
                            icon: goalData.3,
                            colors: goalData.4,
                            isSelected: goal == goalData.0
                        ) {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                                goal = goalData.0
                            }
                        }
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : CGFloat(15 + index * 8))
                    }
                }
            }
        } bottom: {
            PrimaryButton(title: "Continue", action: onContinue)
                .opacity(showContent ? 1 : 0)
        }
        .onAppear {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.8).delay(0.1)) {
                showContent = true
            }
        }
    }
}

struct GoalOptionCard: View {
    let goal: Goal
    let title: String
    let description: String
    let icon: String
    let colors: [Color]
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(colors: colors.map { $0.opacity(isSelected ? 0.35 : 0.15) },
                                         startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .frame(width: 52, height: 52)
                    
                    Image(systemName: icon)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(isSelected ? colors[0] : .white.opacity(0.6))
                }
                
                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Text(description)
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(.white.opacity(0.5))
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 22))
                        .foregroundColor(colors[0])
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(isSelected ? 0.1 : 0.05))
            .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isSelected ? colors[0] : Color.clear, lineWidth: 2)
                    )
            )
            .scaleEffect(isSelected ? 1.01 : 1)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Schedule Step

struct ScheduleStep: View {
    @Binding var daysPerWeek: Int
    @Binding var sessionDuration: Double
    let onContinue: () -> Void
    @State private var showContent = false
    
    private let durations: [(Double, String)] = [
        (1.0, "1h"),
        (1.5, "1.5h"),
        (2.0, "2h"),
        (2.5, "2.5h"),
        (3.0, "3h")
    ]
    
    var body: some View {
        StepContainer {
            VStack(spacing: 24) {
                Spacer()
                    .frame(height: 16)
                
                VStack(spacing: 12) {
                    Text("Plan your schedule")
                        .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    Text("How much time can you commit each week?")
                        .font(.system(size: 16, weight: .regular))
                .foregroundColor(.white.opacity(0.6))
        }
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 15)

                // Days per week
                VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "calendar")
                            .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppTheme.primaryColor)
                        
                        Text("Days per week")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white.opacity(0.8))
                        
                Spacer()
                        
                        Text("\(daysPerWeek) days")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(AppTheme.secondaryColor)
            }

                    HStack(spacing: 10) {
                ForEach(1...7, id: \.self) { day in
                            DayButton(day: day, isSelected: daysPerWeek == day) {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    daysPerWeek = day
                                }
                            }
                        }
                    }
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white.opacity(0.06))
        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.white.opacity(0.08), lineWidth: 1)
                        )
                )
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 20)
                
                // Session duration
                VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "clock.fill")
                            .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppTheme.primaryColor)
                        
                        Text("Session duration")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white.opacity(0.8))
                        
                Spacer()
                        
                        Text("\(sessionDuration, specifier: "%.1f") hours")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(AppTheme.secondaryColor)
            }

                    HStack(spacing: 10) {
                        ForEach(durations, id: \.0) { duration in
                            DurationButton(
                                label: duration.1,
                                isSelected: sessionDuration == duration.0
                            ) {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    sessionDuration = duration.0
                                }
                            }
                        }
                    }
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white.opacity(0.06))
        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.white.opacity(0.08), lineWidth: 1)
                        )
                )
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 25)
            }
        } bottom: {
            PrimaryButton(title: "Continue", action: onContinue)
                .opacity(showContent ? 1 : 0)
        }
        .onAppear {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.8).delay(0.1)) {
                showContent = true
            }
        }
    }
}

struct DayButton: View {
    let day: Int
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text("\(day)")
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundColor(isSelected ? .white : .white.opacity(0.6))
                .frame(maxWidth: .infinity)
                .aspectRatio(1, contentMode: .fit)
                .background(
                    Circle()
                        .fill(
                            isSelected ?
                            LinearGradient(colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                                         startPoint: .topLeading, endPoint: .bottomTrailing) :
                            LinearGradient(colors: [Color.white.opacity(0.08)],
                                         startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct DurationButton: View {
    let label: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(isSelected ? .white : .white.opacity(0.6))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            isSelected ?
                            LinearGradient(colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                                         startPoint: .leading, endPoint: .trailing) :
                            LinearGradient(colors: [Color.white.opacity(0.08)],
                                         startPoint: .leading, endPoint: .trailing)
                        )
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Environment Step

struct EnvironmentStep: View {
    @Binding var workoutEnvironment: WorkoutEnvironment
    let onCreatePlan: () -> Void
    let isGenerating: Bool
    @State private var showContent = false
    
    private let environments: [(WorkoutEnvironment, String, String, String, Color)] = [
        (.gym, "Gym", "Full equipment access", "building.2.fill", Color(hex: "6C5CE7")),
        (.home, "No Equipment", "Bodyweight workouts", "house.fill", Color(hex: "4ECDC4")),
        (.pilates, "Pilates", "Mat-based exercises", "figure.pilates", Color(hex: "F97316"))
    ]

    var body: some View {
        StepContainer {
            VStack(spacing: 24) {
                Spacer()
                    .frame(height: 16)
                
                VStack(spacing: 12) {
                    Text("Where will you train?")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    Text("We'll customize exercises for your environment")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.white.opacity(0.6))
                }
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 15)
                
                VStack(spacing: 14) {
                    ForEach(Array(environments.enumerated()), id: \.offset) { index, env in
                        EnvironmentCard(
                            environment: env.0,
                            title: env.1,
                            description: env.2,
                            icon: env.3,
                            color: env.4,
                            isSelected: workoutEnvironment == env.0
                        ) {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                                workoutEnvironment = env.0
                            }
                        }
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : CGFloat(20 + index * 10))
                    }
                }
            }
        } bottom: {
            Button(action: onCreatePlan) {
                HStack(spacing: 12) {
                    if isGenerating {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.9)
                    } else {
                        Text("Create My Plan")
                            .font(.system(size: 18, weight: .bold))
                        
                        Image(systemName: "sparkles")
                            .font(.system(size: 16, weight: .bold))
                    }
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(
                    LinearGradient(
                        colors: [AppTheme.primaryColor, Color(hex: "8B5CF6")],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(16)
                .shadow(color: AppTheme.primaryColor.opacity(0.4), radius: 16, x: 0, y: 8)
            }
            .disabled(isGenerating)
            .opacity(showContent ? 1 : 0)
        }
        .onAppear {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.8).delay(0.1)) {
                showContent = true
            }
        }
    }
}

struct EnvironmentCard: View {
    let environment: WorkoutEnvironment
    let title: String
    let description: String
    let icon: String
    let color: Color
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(color.opacity(isSelected ? 0.25 : 0.1))
                        .frame(width: 56, height: 56)
                    
                    Image(systemName: icon)
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(isSelected ? color : .white.opacity(0.5))
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Text(description)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.white.opacity(0.5))
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(color)
                }
            }
            .padding(18)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color.white.opacity(isSelected ? 0.1 : 0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(isSelected ? color : Color.clear, lineWidth: 2)
                    )
            )
            .scaleEffect(isSelected ? 1.01 : 1)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Primary Button

struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    var isEnabled: Bool = true
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Text(title)
                    .font(.system(size: 17, weight: .bold))
                
                Image(systemName: "arrow.right")
                    .font(.system(size: 14, weight: .bold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(
        Group {
                    if isEnabled {
                LinearGradient(
                            colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                            startPoint: .leading,
                            endPoint: .trailing
                )
            } else {
                        Color.white.opacity(0.1)
                    }
                }
            )
            .cornerRadius(16)
            .shadow(color: isEnabled ? AppTheme.primaryColor.opacity(0.3) : Color.clear, radius: 12, x: 0, y: 6)
        }
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1 : 0.5)
    }
}

// MARK: - Motivational Loading View

struct MotivationalLoadingView: View {
    @State private var currentQuoteIndex = 0
    @State private var quoteOpacity: Double = 0
    @State private var iconRotation: Double = 0
    @State private var pulseScale: CGFloat = 1.0
    @State private var quoteTimer: Timer?

    private let quotes: [(quote: String, author: String)] = [
        ("The only way to do great work is to love what you do.", "Steve Jobs"),
        ("Discipline is choosing between what you want now and what you want most.", "Abraham Lincoln"),
        ("The body achieves what the mind believes.", "Napoleon Hill"),
        ("Strength does not come from physical capacity. It comes from an indomitable will.", "Mahatma Gandhi"),
        ("The only bad workout is the one that didn't happen.", "Unknown"),
        ("Success is the sum of small efforts repeated day in and day out.", "Robert Collier"),
        ("Take care of your body. It's the only place you have to live.", "Jim Rohn"),
        ("The pain you feel today will be the strength you feel tomorrow.", "Unknown"),
        ("Your limitation—it's only your imagination.", "Unknown"),
        ("Push yourself, because no one else is going to do it for you.", "Unknown")
    ]

    var body: some View {
        ZStack {
            AnimatedGradientBackground()
            
            VStack(spacing: 50) {
                Spacer()

                // Animated icon
                ZStack {
                    // Outer pulse rings
                    ForEach(0..<3) { i in
                    Circle()
                            .stroke(AppTheme.primaryColor.opacity(0.15 - Double(i) * 0.04), lineWidth: 2)
                            .frame(width: 140 + CGFloat(i * 30), height: 140 + CGFloat(i * 30))
                            .scaleEffect(pulseScale)
                    }
                    
                    // Main icon container
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [AppTheme.primaryColor, Color(hex: "8B5CF6")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 120, height: 120)
                        .shadow(color: AppTheme.primaryColor.opacity(0.5), radius: 30, x: 0, y: 15)

                    Image(systemName: "dumbbell.fill")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.white)
                        .rotationEffect(.degrees(iconRotation))
                }

                // Quote section
                VStack(spacing: 20) {
                    Text(quotes[currentQuoteIndex].quote)
                        .font(.system(size: 22, weight: .medium, design: .serif))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                        .opacity(quoteOpacity)

                    Text("— \(quotes[currentQuoteIndex].author)")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(AppTheme.secondaryColor)
                        .opacity(quoteOpacity)
                }
                .frame(height: 180)
                
                // Loading indicator
                VStack(spacing: 16) {
                    HStack(spacing: 8) {
                        ForEach(0..<3) { i in
                            Circle()
                                .fill(AppTheme.secondaryColor)
                                .frame(width: 8, height: 8)
                                .opacity(pulseScale > 1.05 - Double(i) * 0.02 ? 1 : 0.3)
                        }
                    }
                    
                    Text("Creating your personalized plan...")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                }

                Spacer()
            }
        }
        .onAppear {
            startAnimations()
        }
        .onDisappear {
            // IMPORTANT: Clean up timer to prevent memory leaks
            quoteTimer?.invalidate()
            quoteTimer = nil
        }
    }

    private func startAnimations() {
        // Quote fade in
        withAnimation(.easeInOut(duration: 0.8)) {
            quoteOpacity = 1.0
        }
        
        // Icon subtle rotation
        withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
            iconRotation = 5
        }
        
        // Pulse animation
        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
            pulseScale = 1.1
        }
        
        // Quote rotation timer - stored so it can be invalidated
        quoteTimer?.invalidate() // Invalidate any existing timer
        quoteTimer = Timer.scheduledTimer(withTimeInterval: 8.0, repeats: true) { [self] _ in
            withAnimation(.easeOut(duration: 0.6)) {
                quoteOpacity = 0
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                currentQuoteIndex = (currentQuoteIndex + 1) % quotes.count
                withAnimation(.easeIn(duration: 0.6)) {
                    quoteOpacity = 1.0
                }
            }
        }
    }
}

// MARK: - Preview

#if DEBUG
struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
            .environmentObject(UserManager())
    }
}
#endif
