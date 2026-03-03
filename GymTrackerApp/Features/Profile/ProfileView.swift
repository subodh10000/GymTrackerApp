import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var userManager: UserManager
    @State private var showingLogoutAlert = false
    @State private var bustScale: CGFloat = 0.85
    @State private var hasAnimated = false  // Prevent animation replay

    var body: some View {
        NavigationStack {  // Updated from deprecated NavigationView
            ZStack {
                AppTheme.backgroundColor
                    .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        if let profile = userManager.profile {
                            profileHeader(for: profile)
                            infoSections(for: profile)
                            
                            // Delete Account Button - Always visible when profile exists
                            Button(action: {
                                showingLogoutAlert = true
                            }) {
                                HStack {
                                    Image(systemName: "trash.fill")
                                        .font(.system(size: 16, weight: .semibold))
                                    Text("Delete Account")
                                        .font(.headline)
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color.red)
                                .cornerRadius(15)
                                .shadow(color: Color.red.opacity(0.3), radius: 10, x: 0, y: 5)
                            }
                            .padding(.horizontal)
                            .padding(.top, 10)
                            .padding(.bottom, 40)
                        } else {
                            emptyState
                        }
                    }
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .alert("Delete Account", isPresented: $showingLogoutAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete Account", role: .destructive) {
                    userManager.deleteAccount()
                }
            } message: {
                Text("This will permanently delete your account and all associated data, including your profile, workouts, workout history, personal records, and reminders. This action cannot be undone.")
            }
        }
    }

    private func profileHeader(for profile: UserProfile) -> some View {
        ZStack {
            // Improved gradient using app theme colors
            LinearGradient(
                colors: [
                    AppTheme.primaryColor,
                    AppTheme.secondaryColor.opacity(0.8)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

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

            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.15))
                        .frame(width: 110, height: 110)
                        .blur(radius: 3)
                        .shadow(color: .white.opacity(0.6), radius: 12, x: 0, y: 0)

                    Image("lad")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.3), lineWidth: 6)
                        )
                        .shadow(color: .white.opacity(0.5), radius: 10, x: 0, y: 0)
                        .scaleEffect(bustScale)
                        .onAppear {
                            // Only animate once, not on every navigation back
                            guard !hasAnimated else { return }
                            hasAnimated = true
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.5)) {
                                bustScale = 1.0
                            }
                        }
                }

                Text(profile.name)
                    .font(.title2.bold())
                    .foregroundColor(.white)

                Text(profile.goal.rawValue)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.9))
            }
            .padding(.top, 50)
            .padding(.bottom, 30)
        }
        .frame(height: 220)
        .cornerRadius(24)
        .padding(.horizontal)
        .shadow(color: AppTheme.primaryColor.opacity(0.3), radius: 16, x: 0, y: 8)
    }

    // Helper to format height in feet and inches
    private func formatHeight(_ totalInches: Double) -> String {
        let feet = Int(totalInches) / 12
        let inches = Int(totalInches) % 12
        return "\(feet)'\(inches)\""
    }
    
    private func infoSections(for profile: UserProfile) -> some View {
        VStack(spacing: 20) {
            // Workout Stats Card
            WorkoutStatsCard()
            
            InfoCard(title: "Personal Information") {
                InfoRow(label: "Age", value: "\(profile.age) years")
                InfoRow(label: "Height", value: formatHeight(profile.height))
                InfoRow(label: "Weight", value: "\(Int(profile.weight)) lbs")
            }

            InfoCard(title: "Fitness Goal") {
                Text(profile.goal.rawValue)
                    .font(.subheadline)
                    .foregroundColor(AppTheme.textSecondaryColor)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            InfoCard(title: "Training Information") {
                VStack(spacing: 12) {
                    InfoRow(label: "Training Days", value: "\(profile.daysPerWeek) days/week")
                    InfoRow(label: "Session Duration", value: String(format: "%.1f hours", profile.sessionDurationHours))

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
        }
        .padding(.horizontal)
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.crop.circle.badge.questionmark")
                .font(.system(size: 60))
                .foregroundColor(AppTheme.primaryColor)

            Text("No profile found")
                .font(.headline)
                .foregroundColor(AppTheme.textPrimaryColor)

            Text("Complete onboarding to personalize your experience.")
                .font(.subheadline)
                .foregroundColor(AppTheme.textSecondaryColor)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

// MARK: - Workout Stats Card for Profile

struct WorkoutStatsCard: View {
    @EnvironmentObject var userManager: UserManager
    @State private var showFullHistory = false
    
    private var hasHistory: Bool {
        !userManager.workoutHistory.isEmpty
    }
    
    private var stats: WorkoutStats {
        WorkoutStats.calculate(from: userManager.workoutHistory)
    }
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "chart.bar.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(AppTheme.primaryColor)
                    Text("Workout History")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(AppTheme.textPrimaryColor)
                }
                
                Spacer()
                
                if hasHistory {
                    Button(action: { showFullHistory = true }) {
                        HStack(spacing: 4) {
                            Text("View All")
                                .font(.system(size: 14, weight: .semibold))
                            Image(systemName: "chevron.right")
                                .font(.system(size: 11, weight: .semibold))
                        }
                        .foregroundColor(AppTheme.primaryColor)
                    }
                }
            }
            
            if hasHistory {
                // Stats grid
                HStack(spacing: 12) {
                    ProfileStatItem(
                        value: "\(stats.totalWorkouts)",
                        label: "Total",
                        icon: "checkmark.circle.fill",
                        color: Color(hex: "22C55E")
                    )
                    
                    ProfileStatItem(
                        value: "\(stats.currentStreak)",
                        label: "Streak",
                        icon: "flame.fill",
                        color: Color(hex: "F97316")
                    )
                    
                    ProfileStatItem(
                        value: "\(stats.longestStreak)",
                        label: "Best",
                        icon: "trophy.fill",
                        color: Color(hex: "EAB308")
                    )
                    
                    ProfileStatItem(
                        value: "\(stats.thisMonthCount)",
                        label: "Month",
                        icon: "calendar",
                        color: AppTheme.primaryColor
                    )
                }
            } else {
                // Empty state
                VStack(spacing: 12) {
                    Image(systemName: "figure.run.circle")
                        .font(.system(size: 40))
                        .foregroundColor(AppTheme.primaryColor.opacity(0.4))
                    
                    Text("No workouts completed yet")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(AppTheme.textSecondaryColor)
                    
                    Text("Complete your first workout to start tracking!")
                        .font(.system(size: 13))
                        .foregroundColor(AppTheme.textSecondaryColor.opacity(0.7))
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(AppTheme.cardBackgroundColor)
                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
        )
        .sheet(isPresented: $showFullHistory) {
            FullWorkoutHistoryView()
                .environmentObject(userManager)
        }
    }
}

struct ProfileStatItem: View {
    let value: String
    let label: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.textPrimaryColor)
            
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(AppTheme.textSecondaryColor)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.08))
        )
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

// InfoRow is defined in HomeHistoryView.swift

#if DEBUG
struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
            .environmentObject(UserManager())
    }
}
#endif

