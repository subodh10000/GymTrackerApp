import SwiftUI
import UserNotifications

@main
struct GymTrackerApp: App {
    @StateObject private var userManager = UserManager()

    init() {
        UNUserNotificationCenter.current().delegate = NotificationDelegate.shared
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(userManager)
                .preferredColorScheme(.light)
        }
    }
}


// MARK: - Models
// Models remain unchanged

// MARK: - View Models
// UserManager remains unchanged

// MARK: - Theme

struct AppTheme {
    static let primaryGradient = LinearGradient(
        gradient: Gradient(colors: [Color(hex: "4776E6"), Color(hex: "8E54E9")]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let secondaryGradient = LinearGradient(
        gradient: Gradient(colors: [Color(hex: "16BFFD"), Color(hex: "CB3066")]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let primaryColor = Color(hex: "5E60CE")
    static let secondaryColor = Color(hex: "64DFDF")
    static let accentColor = Color(hex: "FF5A5F")
    static let backgroundColor = Color(hex: "F8F9FA")
    static let cardBackgroundColor = Color.white
    static let textPrimaryColor = Color(hex: "2B2D42")
    static let textSecondaryColor = Color(hex: "8D99AE")
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}


// MARK: - Views


struct OnboardingView: View {
    @EnvironmentObject var userManager: UserManager
    @State private var name = ""
    @State private var showError = false
    @State private var animateGradient = false
    
    var body: some View {
        ZStack {
            // Animated background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "4776E6"),
                    Color(hex: "8E54E9"),
                    Color(hex: "16BFFD")
                ]),
                startPoint: animateGradient ? .topLeading : .bottomLeading,
                endPoint: animateGradient ? .bottomTrailing : .topTrailing
            )
            .edgesIgnoringSafeArea(.all)
            .onAppear {
                withAnimation(.linear(duration: 5).repeatForever(autoreverses: true)) {
                    animateGradient.toggle()
                }
            }
            
            // Content
            VStack(spacing: 30) {
                Spacer()
                
                VStack(spacing: 10) {
                    Image(systemName: "figure.strengthtraining.traditional")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 5)
                    
                    Text("GYM TRACKER")
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 2)
                }

                Spacer()
                
                // Card
                VStack(spacing: 25) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Welcome!")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(AppTheme.textPrimaryColor)
                        
                        Text("This app contains your custom strength and leaning workout plan designed specifically for badminton performance.")
                            .font(.body)
                            .foregroundColor(AppTheme.textSecondaryColor)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("What should we call you?")
                            .font(.headline)
                            .foregroundColor(AppTheme.textPrimaryColor)
                        
                        TextField("Enter your name", text: $name)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(AppTheme.primaryColor.opacity(0.5), lineWidth: 1)
                            )
                    }
                    
                    Button(action: {
                        if name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            showError = true
                        } else {
                            userManager.profile.name = name
                            userManager.saveProfile()
                        }
                    }) {
                        Text("Get Started")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                AppTheme.primaryGradient
                            )
                            .cornerRadius(15)
                            .shadow(color: AppTheme.primaryColor.opacity(0.3), radius: 10, x: 0, y: 5)
                    }
                }
                .padding(30)
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.1), radius: 20, x: 0, y: 10)
                )
                .padding(.horizontal, 20)
                
                Spacer()
                Spacer()
            }
            .padding(.vertical, 40)
            .alert(isPresented: $showError) {
                Alert(title: Text("Missing Information"),
                      message: Text("Please enter your name to continue."),
                      dismissButton: .default(Text("OK")))
            }
        }
    }
}

struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Image(systemName: selectedTab == 0 ? "house.fill" : "house")
                    Text("Home")
                }
                .tag(0)
            
            WorkoutListView()
                .tabItem {
                    Image(systemName: selectedTab == 1 ? "figure.run.circle.fill" : "figure.run.circle")
                    Text("Workouts")
                }
                .tag(1)
            
            NutritionView()
                .tabItem {
                    Image(systemName: selectedTab == 2 ? "fork.knife.circle.fill" : "fork.knife.circle")
                    Text("Nutrition")
                }
                .tag(2)
            
            ProfileView()
                .tabItem {
                    Image(systemName: selectedTab == 3 ? "person.crop.circle.fill" : "person.crop.circle")
                    Text("Profile")
                }
                .tag(3)
        }
        .tint(AppTheme.primaryColor)
    }
}

struct HomeView: View {
    @EnvironmentObject var userManager: UserManager
    @State private var animateGlow = false
    @State private var tappedWorkout = false
    @State private var tappedExercise = false
    @State private var showWaterConfetti = false
    @State private var showFireBurst = false


    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Welcome section
                    ZStack(alignment: .topLeading) {
                        // Background with gradient overlay
                        RoundedRectangle(cornerRadius: 20)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color(hex: "5E60CE"), Color(hex: "4EA8DE")]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(height: 180)
                        
                        // Content
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Hello, \(userManager.profile.name)!")
                                        .font(.system(size: 28, weight: .bold, design: .rounded))
                                        .foregroundColor(.white)
                                    
                                    Text("Ready for your workout?")
                                        .font(.headline)
                                        .foregroundColor(.white.opacity(0.85))
                                }
                                
                                Spacer()
                                
                                ZStack {
                                    Circle()
                                        .fill(Color.white.opacity(0.2))
                                        .frame(width: 60, height: 60)
                                    
                                    Image(systemName: "figure.strengthtraining.traditional")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 30, height: 30)
                                        .foregroundColor(.white)
                                }
                            }
                            
                            Spacer(minLength: 20)
                            
                            let todaysWorkout = getTodaysWorkout()
                            if let workout = todaysWorkout {
                                NavigationLink(destination: WorkoutDetailView(workout: workout, workoutIndex: userManager.workouts.firstIndex(where: { $0.id == workout.id }) ?? 0)) {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("Today's Focus: \(workout.focus)")
                                                .font(.headline)
                                                .foregroundColor(.white)
                                            
                                            
                                        }
                                        
                                        Spacer()
                                        
                                        Image(systemName: "arrow.right.circle.fill")
                                            .foregroundColor(.white)
                                            .font(.system(size: 24))
                                    }
                                    .padding()
                                    .background(Color.white.opacity(0.15))
                                    .cornerRadius(12)
                                }
                            } else {
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Rest Day")
                                            .font(.headline)
                                            .foregroundColor(.white)
                                        
                                        Text("Focus on recovery today")
                                            .font(.subheadline)
                                            .foregroundColor(.white.opacity(0.85))
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "bed.double.fill")
                                        .foregroundColor(.white)
                                        .font(.system(size: 20))
                                }
                                .padding()
                                .background(Color.white.opacity(0.15))
                                .cornerRadius(12)
                            }
                        }
                        .padding()
                    }
                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                    
                    // Weekly progress
                    HStack(spacing: 15) {
                        // Workouts Card with Animated Purple Glow + Water Confetti
                        ZStack {
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.purple.opacity(0.5), lineWidth: 3)
                                .scaleEffect(animateGlow ? 1.03 : 1.0)
                                .shadow(color: Color.purple.opacity(animateGlow ? 0.7 : 0.3), radius: 12, x: 0, y: 4)
                                .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: animateGlow)

                            ProgressCard(
                                progress: Double(completedWorkouts()) / Double(userManager.workouts.count),
                                value: "\(completedWorkouts())",
                                total: "\(userManager.workouts.count)",
                                label: "Workouts",
                                color: AppTheme.primaryColor
                            )
                            .scaleEffect(tappedWorkout ? 0.97 : 1.0)
                            .onTapGesture {
                                tappedWorkout = true
                                showWaterConfetti = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                                    tappedWorkout = false
                                    showWaterConfetti = false
                                }
                            }

                            if showWaterConfetti {
                                ForEach(0..<15, id: \.self) { i in
                                    ConfettiDrop(
                                        symbol: "drop.fill",
                                        color: .blue,
                                        xOffset: CGFloat.random(in: -50...50)
                                    )
                                }
                            }

                        }

                        // Exercises Card with Animated Red Glow + Fire Burst
                        ZStack {
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.red.opacity(0.5), lineWidth: 3)
                                .scaleEffect(animateGlow ? 1.03 : 1.0)
                                .shadow(color: Color.red.opacity(animateGlow ? 0.7 : 0.3), radius: 12, x: 0, y: 4)
                                .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: animateGlow)

                            ProgressCard(
                                progress: Double(completedExercises()) / Double(totalExercises()),
                                value: "\(completedExercises())",
                                total: "\(totalExercises())",
                                label: "Exercises",
                                color: AppTheme.accentColor
                            )
                            .scaleEffect(tappedExercise ? 0.97 : 1.0)
                            .onTapGesture {
                                tappedExercise = true
                                showFireBurst = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                                    tappedExercise = false
                                    showFireBurst = false
                                }
                            }

                            if showFireBurst {
                                ForEach(0..<15, id: \.self) { i in
                                    ConfettiDrop(
                                        symbol: "flame.fill",
                                        color: .red,
                                        xOffset: CGFloat.random(in: -50...50)
                                    )
                                }
                            }

                        }
                    }
                    .onAppear {
                        animateGlow = true
                    }

                    
                    // Nutrition tips
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Reminders")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(AppTheme.textPrimaryColor)
                        
                        VStack(spacing: 15) {
                            NutritionReminderCard(
                                icon: "drop.fill",
                                color: Color(hex: "4EA8DE"),
                                text: "Drink at least 3L of water today"
                            )
                            
                            NutritionReminderCard(
                                icon: "flame.fill", // 🔥 Motivation icon
                                color: Color.orange,   // bold for energy
                                text: "You sh*t buddy, be BETTER 😤"
                            )

                            
                            NutritionReminderCard(
                                icon: "leaf.circle.fill", // sarcastic clean-eating vibe
                                color: Color.green,       // natural green tone
                                text: "Cook and eat meal skinny bone"
                            )

                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(AppTheme.cardBackgroundColor)
                            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                    )
                }
                .padding()
                .background(AppTheme.backgroundColor.edgesIgnoringSafeArea(.all))
            }
            .navigationBarHidden(true)
        }
    }
    
    // Helper functions from original code
    private func getTodaysWorkout() -> Workout? {
        // Implementation stays the same
        let today = Calendar.current.component(.weekday, from: Date())
        // Map weekday numbers to workout days (1 = Sunday, 2 = Monday, etc.)
        switch today {
        case 1: // Sunday
            return userManager.workouts.first { $0.day == "Sunday" }
        case 3: // Tuesday
            return nil
        case 4: // Wednesday
            return userManager.workouts.first { $0.day == "Wednesday" }
        case 5: // Thursday
            return userManager.workouts.first { $0.day == "Thursday" }
        case 6: // Friday
            return userManager.workouts.first { $0.day == "Friday" }
        case 7: // Saturday
            return userManager.workouts.first { $0.day == "Saturday" }
        default:
            return nil
        }
    }
    
    private func completedWorkouts() -> Int {
        // Implementation stays the same
        var count = 0
        for workout in userManager.workouts {
            let completed = !workout.exercises.contains { !$0.isCompleted }
            if completed {
                count += 1
            }
        }
        return count
    }
    
    private func totalExercises() -> Int {
        // Implementation stays the same
        return userManager.workouts.reduce(0) { $0 + $1.exercises.count }
    }
    
    private func completedExercises() -> Int {
        // Implementation stays the same
        return userManager.workouts.reduce(0) { $0 + $1.exercises.filter(\.isCompleted).count }
    }
}

struct NutritionReminderCard: View {
    let icon: String
    let color: Color
    let text: String
    
    var body: some View {
        HStack(spacing: 15) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundColor(color)
            }
            
            Text(text)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(AppTheme.textPrimaryColor)
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.05))
        )
    }
}

struct ProgressCard: View {
    let progress: Double
    let value: String
    let total: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 15) {
            ZStack {
                Circle()
                    .stroke(color.opacity(0.2), lineWidth: 10)
                    .frame(width: 80, height: 80)
                
                Circle()
                    .trim(from: 0, to: CGFloat(min(progress, 1.0)))
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
                .fill(Color.white)
                .shadow(color: Color.gray.opacity(0.1), radius: 5, x: 0, y: 3)
        )
    }
}

struct WorkoutListView: View {
    @EnvironmentObject var userManager: UserManager
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 15) {
                    ForEach(Array(userManager.workouts.enumerated()), id: \.element.id) { index, workout in
                        NavigationLink(destination: WorkoutDetailView(workout: workout, workoutIndex: index)) {
                            WorkoutCard(workout: workout)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding()
            }
            .background(AppTheme.backgroundColor.edgesIgnoringSafeArea(.all))
            .navigationTitle("Weekly Workouts")
            .toolbar {
                Button(action: {
                    userManager.resetAllWorkouts()
                }) {
                    Text("Reset")
                        .foregroundColor(AppTheme.primaryColor)
                }
            }
        }
    }
}

struct WorkoutCard: View {
    let workout: Workout
    
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            // Left side circle with day initial
            ZStack {
                Circle()
                    .fill(WorkoutGradientProvider.gradient(for: workout.day))
                    .frame(width: 42, height: 42) // ✅ reduced size
                    .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)

                Text(String(workout.day.prefix(1)))
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
            }

            
            // Right side content
            VStack(alignment: .leading, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(workout.day)
                        .font(.headline)
                        .foregroundColor(AppTheme.textPrimaryColor)
                    
                    Text(workout.focus)
                        .font(.subheadline)
                        .foregroundColor(AppTheme.textSecondaryColor)
                        .lineLimit(2)
                }
                
                HStack {
                    // Exercise count
                    HStack(spacing: 5) {
                        Image(systemName: "dumbbell.fill")
                            .font(.system(size: 12))
                            .foregroundColor(AppTheme.primaryColor)
                        
                        Text("\(workout.exercises.count) exercises")
                            .font(.caption)
                            .foregroundColor(AppTheme.textSecondaryColor)
                    }
                    
                    Spacer()
                    
                    // Completion status
                    let completedExercises = workout.exercises.filter { $0.isCompleted }.count
                    HStack(spacing: 5) {
                        if completedExercises == workout.exercises.count && completedExercises > 0 {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("Complete")
                                .font(.caption)
                                .foregroundColor(.green)
                        } else {
                            Text("\(completedExercises)/\(workout.exercises.count)")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(completedExercises > 0 ? AppTheme.primaryColor : AppTheme.textSecondaryColor)
                        }
                    }
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(AppTheme.textSecondaryColor)
                .padding(.top, 15)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(AppTheme.cardBackgroundColor)
                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
        )
    }
}

struct WorkoutDetailView: View {
    @EnvironmentObject var userManager: UserManager
    var workout: Workout
    var workoutIndex: Int
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header section with gradient background
                ZStack(alignment: .bottomLeading) {
                    Rectangle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [AppTheme.primaryColor, AppTheme.secondaryColor]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(height: 170)
                        .edgesIgnoringSafeArea(.top)
                    
                    VStack(alignment: .leading, spacing: 5) {
                        Text(workout.day)
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text(workout.focus)
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.85))
                            .lineLimit(2)
                        
                        // Progress bar
                        let completedCount = workout.exercises.filter(\.isCompleted).count
                        let progress = Double(completedCount) / Double(workout.exercises.count)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("\(completedCount)/\(workout.exercises.count) completed")
                                    .font(.subheadline)
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                Text(String(format: "%.0f%%", progress * 100))
                                    .font(.subheadline)
                                    .foregroundColor(.white)
                            }
                            
                            GeometryReader { geometry in
                                ZStack(alignment: .leading) {
                                    Capsule()
                                        .fill(Color.white.opacity(0.3))
                                        .frame(height: 8)
                                    
                                    Capsule()
                                        .fill(Color.white)
                                        .frame(width: geometry.size.width * CGFloat(progress), height: 8)
                                }
                            }
                            .frame(height: 8)
                        }
                        .padding(.top, 10)
                    }
                    .padding(20)
                }
                
                // Exercises list
                VStack(alignment: .leading, spacing: 5) {
                    Text("Exercises")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(AppTheme.textPrimaryColor)
                        .padding(.horizontal, 20)
                    
                    ForEach(Array(workout.exercises.enumerated()), id: \.element.id) { index, exercise in
                        ExerciseRow(
                            exercise: exercise,
                            isCompleted: exercise.isCompleted,
                            toggleCompletion: {
                                userManager.toggleExerciseCompletion(
                                    workoutIndex: workoutIndex,
                                    exerciseIndex: index
                                )
                            }
                        )
                    }
                }
                .padding(.top, 10)
            }
        }
        .background(AppTheme.backgroundColor)
        .edgesIgnoringSafeArea(.top)
        .navigationBarTitleDisplayMode(.inline)
    }
}


struct NutritionView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header image/banner
                    ZStack(alignment: .bottom) {
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color(hex: "FF5A5F"), Color(hex: "FF9A8B")]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(height: 160)
                        
                        HStack {
                            VStack(alignment: .leading, spacing: 5) {
                                Text("Nutrition Plan")
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(.white)
                                
                                Text("Fuel your performance")
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.85))
                            }
                            
                            Spacer()
                            
                            Image(systemName: "leaf.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 40)
                                .foregroundColor(.white.opacity(0.8))
                       
                        }
                                                .padding(20)
                                            }
                                            
                                            // Macronutrient goals
                                            VStack(alignment: .leading, spacing: 15) {
                                                Text("Daily Nutrition Goals")
                                                    .font(.title2)
                                                    .fontWeight(.bold)
                                                    .foregroundColor(AppTheme.textPrimaryColor)
                                                
                                                HStack(spacing: 12) {
                                                    MacroCard(
                                                        icon: "figure.strengthtraining.traditional",
                                                        color: AppTheme.primaryColor,
                                                        value: "145g",
                                                        name: "Protein"
                                                    )
                                                    
                                                    MacroCard(
                                                        icon: "flame.fill",
                                                        color: AppTheme.accentColor,
                                                        value: "Slight Deficit",
                                                        name: "Calories"
                                                    )
                                                    
                                                    MacroCard(
                                                        icon: "drop.fill",
                                                        color: Color(hex: "4EA8DE"),
                                                        value: "3L+",
                                                        name: "Water"
                                                    )
                                                }
                                            }
                                            .padding()
                                            .background(
                                                RoundedRectangle(cornerRadius: 20)
                                                    .fill(AppTheme.cardBackgroundColor)
                                                    .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                                            )
                                            
                                            // Nutrition tips
                                            VStack(alignment: .leading, spacing: 15) {
                                                Text("Nutrition Tips")
                                                    .font(.title2)
                                                    .fontWeight(.bold)
                                                    .foregroundColor(AppTheme.textPrimaryColor)
                                                
                                                VStack(spacing: 15) {
                                                    EnhancedNutritionTip(
                                                        title: "Protein Sources",
                                                        description: "Focus on lean meats, eggs, fish, and plant-based proteins like beans and lentils.",
                                                        icon: "fish.fill",
                                                        color: Color(hex: "F9A826")
                                                    )
                                                    
                                                    EnhancedNutritionTip(
                                                        title: "Carbohydrates",
                                                        description: "Choose complex carbs like oats, brown rice, and sweet potatoes over processed options.",
                                                        icon: "leaf.fill",
                                                        color: Color(hex: "4FC08D")
                                                    )
                                                    
                                                    EnhancedNutritionTip(
                                                        title: "Stay Hydrated",
                                                        description: "Drink water consistently throughout the day, especially before and after workouts.",
                                                        icon: "drop.fill",
                                                        color: Color(hex: "4EA8DE")
                                                    )
                                                    
                                                    EnhancedNutritionTip(
                                                        title: "Optional Supplements",
                                                        description: "Consider creatine (5g/day), whey protein, and a multivitamin to support your goals.",
                                                        icon: "pill.fill",
                                                        color: AppTheme.primaryColor
                                                    )
                                                }
                                            }
                                            .padding()
                                            .background(
                                                RoundedRectangle(cornerRadius: 20)
                                                    .fill(AppTheme.cardBackgroundColor)
                                                    .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                                            )
                                            
                                            // Foods to limit
                                            VStack(alignment: .leading, spacing: 15) {
                                                Text("Foods to Limit")
                                                    .font(.title2)
                                                    .fontWeight(.bold)
                                                    .foregroundColor(AppTheme.textPrimaryColor)
                                                
                                                VStack(spacing: 12) {
                                                    FoodToAvoidRow(text: "Processed sugar and sweets")
                                                    FoodToAvoidRow(text: "Highly processed foods")
                                                    FoodToAvoidRow(text: "Excessive alcohol")
                                                    FoodToAvoidRow(text: "Fried and fast foods")
                                                }
                                            }
                                            .padding()
                                            .background(
                                                RoundedRectangle(cornerRadius: 20)
                                                    .fill(AppTheme.cardBackgroundColor)
                                                    .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                                            )
                                        }
                                        .padding()
                                        .background(AppTheme.backgroundColor.edgesIgnoringSafeArea(.all))
                                    }
                                    .navigationTitle("Nutrition")
                                    .navigationBarTitleDisplayMode(.inline)
                                }
                            }
                        }

                        struct MacroCard: View {
                            let icon: String
                            let color: Color
                            let value: String
                            let name: String
                            
                            var body: some View {
                                VStack(spacing: 10) {
                                    ZStack {
                                        Circle()
                                            .fill(color.opacity(0.15))
                                            .frame(width: 50, height: 50)
                                        
                                        Image(systemName: icon)
                                            .font(.system(size: 22))
                                            .foregroundColor(color)
                                    }
                                    
                                    Text(value)
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(AppTheme.textPrimaryColor)
                                    
                                    Text(name)
                                        .font(.caption)
                                        .foregroundColor(AppTheme.textSecondaryColor)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 15)
                                .background(
                                    RoundedRectangle(cornerRadius: 15)
                                        .fill(Color.gray.opacity(0.05))
                                )
                            }
                        }

                        struct EnhancedNutritionTip: View {
                            let title: String
                            let description: String
                            let icon: String
                            let color: Color
                            
                            var body: some View {
                                HStack(alignment: .top, spacing: 15) {
                                    ZStack {
                                        Circle()
                                            .fill(color.opacity(0.15))
                                            .frame(width: 40, height: 40)
                                        
                                        Image(systemName: icon)
                                            .font(.system(size: 18))
                                            .foregroundColor(color)
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(title)
                                            .font(.headline)
                                            .foregroundColor(AppTheme.textPrimaryColor)
                                        
                                        Text(description)
                                            .font(.subheadline)
                                            .foregroundColor(AppTheme.textSecondaryColor)
                                            .fixedSize(horizontal: false, vertical: true)
                                    }
                                    
                                    Spacer()
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.gray.opacity(0.05))
                                )
                            }
                        }

                        struct FoodToAvoidRow: View {
                            let text: String
                            
                            var body: some View {
                                HStack(spacing: 12) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(AppTheme.accentColor)
                                        .font(.system(size: 16))
                                    
                                    Text(text)
                                        .font(.subheadline)
                                        .foregroundColor(AppTheme.textPrimaryColor)
                                    
                                    Spacer()
                                }
                                .padding(.vertical, 8)
                            }
                        }

                        struct ProfileView: View {
                            @EnvironmentObject var userManager: UserManager
                            @State private var showingLogoutAlert = false
                            
                            var body: some View {
                                NavigationView {
                                    ScrollView {
                                        VStack(spacing: 20) {
                                            // Profile header
                                            ZStack {
                                                // Background Gradient (Blue to Red)
                                                LinearGradient(
                                                    gradient: Gradient(colors: [
                                                        Color(hex: "2193b0"), // blue
                                                        Color(hex: "ff6e7f")  // red/pink blend
                                                    ]),
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                                .ignoresSafeArea()

                                                VStack(spacing: 12) {
                                                    ZStack {
                                                        Circle()
                                                            .fill(Color.white.opacity(0.15))
                                                            .frame(width: 95, height: 95)
                                                            .blur(radius: 3)
                                                            .shadow(color: .white.opacity(0.6), radius: 12, x: 0, y: 0)

                                                        Image(systemName: "person.circle.fill")
                                                            .resizable()
                                                            .frame(width: 80, height: 80)
                                                            .foregroundColor(.white)
                                                    }

                                                    Text(userManager.profile.name)
                                                        .font(.title2.bold())
                                                        .foregroundColor(.white)

                                                    Text("Badminton Player")
                                                        .font(.subheadline)
                                                        .foregroundColor(.white.opacity(0.9))
                                                }
                                                .padding(.top, 50)
                                                .padding(.bottom, 30)
                                            }

                                            
                                            // Profile info cards
                                            VStack(spacing: 20) {
                                                // Personal information
                                                InfoCard(title: "Personal Information") {
                                                    InfoRow(label: "Age", value: "\(userManager.profile.age) years")
                                                    InfoRow(label: "Height", value: userManager.profile.height)
                                                    InfoRow(label: "Weight", value: "\(userManager.profile.weight) lbs")
                                                }
                                                
                                                // Fitness goal
                                                // Fitness goal
                                                InfoCard(title: "Fitness Goal") {
                                                    VStack(alignment: .leading, spacing: 8) {
                                                        Text(userManager.profile.goal)
                                                            .font(.subheadline)
                                                            .foregroundColor(AppTheme.textSecondaryColor)
                                                            .multilineTextAlignment(.leading)
                                                            .fixedSize(horizontal: false, vertical: true)
                                                    }
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                }



                                                
                                                // Training schedule
                                                InfoCard(title: "Training Information") {
                                                    VStack(spacing: 12) {
                                                        InfoRow(label: "Training Days", value: "5 days/week")
                                                        InfoRow(label: "Session Duration", value: "1.5 hours")
                                                        
                                                        Divider()
                                                        
                                                        Text("Weekly Schedule")
                                                            .font(.headline)
                                                            .foregroundColor(AppTheme.textPrimaryColor)
                                                            .frame(maxWidth: .infinity, alignment: .leading)
                                                            .padding(.top, 5)
                                                        
                                                        ForEach(userManager.workouts) { workout in
                                                            HStack {
                                                                Text(workout.day)
                                                                    .font(.subheadline)
                                                                    .foregroundColor(AppTheme.textPrimaryColor)
                                                                
                                                                Spacer()
                                                                
                                                                Text(workout.focus)
                                                                    .font(.subheadline)
                                                                    .foregroundColor(AppTheme.textSecondaryColor)
                                                                    .lineLimit(1)
                                                            }
                                                            .padding(.vertical, 4)
                                                        }
                                                    }
                                                }
                                                
                                                // Reset button
                                                Button(action: {
                                                    showingLogoutAlert = true
                                                }) {
                                                    Text("Reset App")
                                                        .font(.headline)
                                                        .foregroundColor(.white)
                                                        .frame(maxWidth: .infinity)
                                                        .padding(.vertical, 14)
                                                        .background(
                                                            LinearGradient(
                                                                gradient: Gradient(colors: [Color(hex: "FF5A5F"), Color(hex: "FF9A8B")]),
                                                                startPoint: .leading,
                                                                endPoint: .trailing
                                                            )
                                                        )
                                                        .cornerRadius(15)
                                                        .shadow(color: Color(hex: "FF5A5F").opacity(0.3), radius: 10, x: 0, y: 5)
                                                }
                                                .padding(.top, 20)
                                            }
                                            .padding(.horizontal)
                                        }
                                        .background(AppTheme.backgroundColor.edgesIgnoringSafeArea(.all))
                                    }
                                    .navigationTitle("Profile")
                                    .navigationBarTitleDisplayMode(.inline)
                                    .alert(isPresented: $showingLogoutAlert) {
                                        Alert(
                                            title: Text("Reset App"),
                                            message: Text("This will clear all your data and restart the app. Are you sure?"),
                                            primaryButton: .destructive(Text("Reset")) {
                                                UserDefaults.standard.removeObject(forKey: "userProfile")
                                                userManager.profile = UserProfile(name: "")
                                                userManager.hasCompletedOnboarding = false
                                                userManager.resetAllWorkouts()
                                            },
                                            secondaryButton: .cancel()
                                        )
                                    }
                                }
                            }
                        }

                        struct InfoCard<Content: View>: View {
                            let title: String
                            let content: Content
                            
                            init(title: String, @ViewBuilder content: () -> Content) {
                                self.title = title
                                self.content = content()
                            }
                            
                            var body: some View {
                                VStack(alignment: .leading, spacing: 15) {
                                    Text(title)
                                        .font(.title3)
                                        .fontWeight(.bold)
                                        .foregroundColor(AppTheme.textPrimaryColor)
                                    
                                    content
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(AppTheme.cardBackgroundColor)
                                        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                                )
                            }
                        }

                        struct InfoRow: View {
                            let label: String
                            let value: String
                            
                            var body: some View {
                                HStack {
                                    Text(label)
                                        .font(.subheadline)
                                        .foregroundColor(AppTheme.textPrimaryColor)
                                    
                                    Spacer()
                                    
                                    Text(value)
                                        .font(.subheadline)
                                        .foregroundColor(AppTheme.textSecondaryColor)
                                }
                                .padding(.vertical, 4)
                            }
                        }
struct ConfettiDrop: View {
    let symbol: String
    let color: Color
    let xOffset: CGFloat
    @State private var yOffset: CGFloat = -40
    @State private var opacity: Double = 1.0

    var body: some View {
        Image(systemName: symbol)
            .foregroundColor(color)
            .font(.caption)
            .opacity(opacity)
            .offset(x: xOffset, y: yOffset)
            .onAppear {
                withAnimation(Animation.easeOut(duration: 1.2)) {
                    yOffset = CGFloat.random(in: 60...120)
                    opacity = 0
                }
            }
    }
}

