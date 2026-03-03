// ChallengeView.swift

import SwiftUI

// MARK: - Challenge Metadata

enum ChallengeType: String, CaseIterable, Identifiable {
    case abs, pushups, face, pullups
    
    var id: Self { self }
    
    @ViewBuilder
    func destinationView() -> some View {
        switch self {
        case .abs:
            AbsChallengeView()
        case .pushups:
            PushupsChallengeView()
        case .face:
            FaceExercisesChallengeView()
        case .pullups:
            PullUpsChallengeView()
        }
    }
}

struct Challenge: Identifiable {
    let id = UUID()
    let type: ChallengeType
    let title: String
    let subtitle: String
    let description: String
    let duration: String
    let frequency: String
    let timePerDay: String
    let equipment: String
    let level: String
    let icon: String
    let gradient: [Color]
    let imageName: String?
    let totalDays: Int
}

// MARK: - Main Challenge View

struct ChallengeView: View {
    @State private var showContent = false
    
    private let challenges: [Challenge] = [
        Challenge(
            type: .abs,
            title: "30-Day Abs",
            subtitle: "Core Strength",
            description: "Build deep core strength and visible definition with this progressive plan.",
            duration: "30 days",
            frequency: "Daily",
            timePerDay: "10-15 min",
            equipment: "None",
            level: "All Levels",
            icon: "figure.core.training",
            gradient: [Color(hex: "FF512F"), Color(hex: "DD2476")],
            imageName: nil,
            totalDays: 7
        ),
        Challenge(
            type: .pushups,
            title: "30-Day Pushups",
            subtitle: "Upper Body Power",
            description: "Master the pushup and build serious upper body strength.",
            duration: "30 days",
            frequency: "Daily",
            timePerDay: "10-20 min",
            equipment: "None",
            level: "Beginner",
            icon: "dumbbell.fill",
            gradient: [Color(hex: "36D1DC"), Color(hex: "5B86E5")],
            imageName: nil,
            totalDays: 7
        ),
        Challenge(
            type: .face,
            title: "30-Day Face",
            subtitle: "Facial Toning",
            description: "Tone facial muscles and reduce puffiness naturally.",
            duration: "30 days",
            frequency: "Daily",
            timePerDay: "5-10 min",
            equipment: "None",
            level: "Beginner",
            icon: "face.smiling",
            gradient: [Color(hex: "A18CD1"), Color(hex: "FBC2EB")],
            imageName: nil,
            totalDays: 7
        ),
        Challenge(
            type: .pullups,
            title: "30-Day Pull-Ups",
            subtitle: "Back & Grip",
            description: "Develop back strength and achieve your first pull-up.",
            duration: "30 days",
            frequency: "Daily",
            timePerDay: "15-25 min",
            equipment: "Pull-up bar",
            level: "Intermediate",
            icon: "bolt.fill",
            gradient: [Color(hex: "11998E"), Color(hex: "38EF7D")],
            imageName: nil,
            totalDays: 7
        )
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.backgroundColor
                    .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        // Header section
                        headerSection
                            .opacity(showContent ? 1 : 0)
                            .offset(y: showContent ? 0 : 20)
                        
                        // All challenges grid
                        challengesSection
                            .opacity(showContent ? 1 : 0)
                            .offset(y: showContent ? 0 : 25)
                    }
                    .padding(.bottom, 8)
                }
            }
            .navigationTitle("Challenges")
            .navigationBarTitleDisplayMode(.large)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) {
                showContent = true
            }
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Push Your Limits")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(AppTheme.primaryColor)
                .textCase(.uppercase)
                .tracking(1.2)
            
            Text("Choose a challenge and transform your fitness in 30 days")
                .font(.system(size: 15))
                .foregroundColor(AppTheme.textSecondaryColor)
                .lineSpacing(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 24)
    }
    
    // MARK: - Challenges Section
    
    private var challengesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("All Challenges")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(AppTheme.textPrimaryColor)
                .padding(.horizontal, 20)
            
            VStack(spacing: 16) {
                ForEach(Array(challenges.enumerated()), id: \.element.id) { index, challenge in
                    NavigationLink {
                        challenge.type.destinationView()
                    } label: {
                        ChallengeCard(challenge: challenge)
                    }
                    .buttonStyle(ChallengeCardButtonStyle())
                }
            }
            .padding(.horizontal, 20)
        }
    }
}

// MARK: - Challenge Card (Simplified - No Progress Tracking)

struct ChallengeCard: View {
    let challenge: Challenge
    @State private var isPressed = false
    
    var body: some View {
        ZStack {
            // Background gradient
            RoundedRectangle(cornerRadius: 24)
                .fill(
                    LinearGradient(
                        colors: challenge.gradient,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            // Decorative elements
            GeometryReader { geo in
                // Large decorative circle
                Circle()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 180, height: 180)
                    .offset(x: geo.size.width - 90, y: -40)
                
                // Smaller circle
                Circle()
                    .fill(Color.white.opacity(0.08))
                    .frame(width: 100, height: 100)
                    .offset(x: geo.size.width - 140, y: geo.size.height - 60)
            }
            .clipped()
            
            // Content
            HStack(spacing: 16) {
                // Left side - Icon
                VStack {
                    ZStack {
                        // Icon background circle
                        Circle()
                            .fill(Color.white.opacity(0.2))
                            .frame(width: 72, height: 72)
                        
                        Image(systemName: challenge.icon)
                            .font(.system(size: 30, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                .padding(.leading, 4)
                
                // Right side - Info
                VStack(alignment: .leading, spacing: 8) {
                    // Subtitle badge
                    Text(challenge.subtitle.uppercased())
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.white.opacity(0.85))
                        .tracking(1.2)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(8)
                    
                    Text(challenge.title)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text(challenge.description)
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.85))
                        .lineLimit(2)
                        .lineSpacing(2)
                    
                    Spacer()
                    
                    // Bottom info row
                    HStack(spacing: 16) {
                        ChallengeInfoBadge(icon: "clock.fill", text: challenge.timePerDay)
                        ChallengeInfoBadge(icon: "calendar", text: challenge.duration)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                .padding(.vertical, 4)
            }
            .padding(20)
        }
        .frame(height: 200)
        .cornerRadius(24)
        .shadow(color: challenge.gradient[0].opacity(0.35), radius: 16, x: 0, y: 8)
        .scaleEffect(isPressed ? 0.98 : 1)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
    }
}

struct ChallengeInfoBadge: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 11, weight: .semibold))
            Text(text)
                .font(.system(size: 12, weight: .medium))
        }
        .foregroundColor(.white.opacity(0.85))
    }
}

// MARK: - Button Style

struct ChallengeCardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

// MARK: - Challenge Info Row (for detail views)

struct ChallengeInfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 15))
                .foregroundColor(AppTheme.textSecondaryColor)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(AppTheme.textPrimaryColor)
        }
        .padding(.vertical, 6)
    }
}

// MARK: - Preview

struct ChallengeView_Previews: PreviewProvider {
    static var previews: some View {
        ChallengeView()
    }
}
