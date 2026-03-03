// ChallengeSharedComponents.swift
// Shared components for all challenge views

import SwiftUI

// MARK: - Enhanced Header View (Simplified - No Progress)

struct ChallengeHeaderView: View {
    let title: String
    let subtitle: String
    let gradient: [Color]
    let totalDays: Int
    var height: CGFloat = 220
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Background gradient
            LinearGradient(
                colors: gradient,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Decorative elements
            GeometryReader { geo in
                Circle()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 250, height: 250)
                    .offset(x: geo.size.width - 100, y: -80)
                
                Circle()
                    .fill(Color.white.opacity(0.08))
                    .frame(width: 150, height: 150)
                    .offset(x: -50, y: geo.size.height - 80)
            }
            
            // Content
            VStack(spacing: 0) {
                Spacer()
                
                VStack(spacing: 16) {
                    VStack(spacing: 6) {
                        Text(subtitle.uppercased())
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white.opacity(0.85))
                            .tracking(1.5)
                        
                        Text(title)
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                    }
                    
                    // Duration badge
                    HStack(spacing: 6) {
                        Image(systemName: "calendar")
                            .font(.system(size: 14))
                        Text("\(totalDays) Day Plan")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(20)
                }
                .padding(.bottom, 24)
            }
        }
        .frame(height: height)
    }
}

// MARK: - Legacy Header (for backward compatibility)

struct ChallengeHeaderImageView: View {
    let title: String
    let subtitle: String
    let gradient: [Color]
    var height: CGFloat = 180
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            LinearGradient(
                colors: gradient,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(height: height)
            
            // Decorative overlay
            GeometryReader { geo in
                Circle()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 200, height: 200)
                    .offset(x: geo.size.width - 80, y: -60)
            }
            .clipped()
            
            // Content
            VStack(alignment: .leading, spacing: 6) {
                Text(subtitle.uppercased())
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white.opacity(0.85))
                    .tracking(1.5)
                
                Text(title)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .frame(height: height)
    }
}

// MARK: - Instructions Card

struct ChallengeInstructionsView: View {
    let restTime: String
    let sets: String
    let style: String
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("The Plan")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(AppTheme.textPrimaryColor)
                Spacer()
            }
            
            HStack(spacing: 0) {
                InstructionItem(value: restTime, label: "Rest", icon: "timer")
                
                Divider()
                    .frame(height: 40)
                    .padding(.horizontal, 8)
                
                InstructionItem(value: sets, label: "Sets", icon: "repeat")
                
                Divider()
                    .frame(height: 40)
                    .padding(.horizontal, 8)
                
                InstructionItem(value: style, label: "Style", icon: "bolt.fill")
            }
        }
        .padding(20)
        .background(AppTheme.cardBackgroundColor)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 4)
        .padding(.horizontal, 20)
        .padding(.top, -30)
        .padding(.bottom, 8)
    }
}

struct InstructionItem: View {
    let value: String
    let label: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(AppTheme.primaryColor)
                Text(value)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(AppTheme.textPrimaryColor)
            }
            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(AppTheme.textSecondaryColor)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Shared Instruction Item (Legacy)

struct ChallengeInstructionItem: View {
    let value: String
    let label: String
    
    var body: some View {
        HStack(spacing: 4) {
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.primaryColor)
            Text(label)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(AppTheme.textSecondaryColor)
        }
    }
}

// MARK: - Day Card Component (Simplified - No Completion Tracking)

struct ChallengeDayCard<T>: View where T: ChallengeDayProtocol {
    let day: T
    let gradient: [Color]
    
    var isRestDay: Bool {
        day.dayNumber == 4 || day.dayNumber == 7
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Day indicator
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        isRestDay ?
                        LinearGradient(colors: [AppTheme.primaryColor.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing) :
                        LinearGradient(colors: gradient.map { $0.opacity(0.15) }, startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .frame(width: 72, height: 72)
                
                VStack(spacing: 4) {
                    Text("\(day.dayNumber)")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(isRestDay ? .white : gradient[0])
                    
                    Image(systemName: day.iconName)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(isRestDay ? .white.opacity(0.9) : gradient[0].opacity(0.8))
                }
            }
            
            // Day info
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(day.title)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(AppTheme.textPrimaryColor)
                    
                    Spacer()
                    
                    if isRestDay {
                        Text("REST")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(AppTheme.primaryColor)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(AppTheme.primaryColor.opacity(0.12))
                            .cornerRadius(6)
                    }
                }
                
                // Exercise preview (first 2 exercises)
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(day.exercises.prefix(2), id: \.self) { exercise in
                        HStack(spacing: 8) {
                            Circle()
                                .fill(gradient[0].opacity(0.4))
                                .frame(width: 5, height: 5)
                            
                            Text(exercise)
                                .font(.system(size: 14))
                                .foregroundColor(AppTheme.textSecondaryColor)
                                .lineLimit(1)
                        }
                    }
                    
                    if day.exercises.count > 2 {
                        Text("+\(day.exercises.count - 2) more")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(AppTheme.textSecondaryColor.opacity(0.7))
                            .padding(.leading, 13)
                    }
                }
            }
            
            // Chevron
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(AppTheme.textSecondaryColor.opacity(0.5))
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(AppTheme.cardBackgroundColor)
        )
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 3)
    }
}

// MARK: - Day Protocol

protocol ChallengeDayProtocol {
    var dayNumber: Int { get }
    var title: String { get }
    var iconName: String { get }
    var exercises: [String] { get }
}

// MARK: - Day Detail Header (Simplified - No Completion Button)

struct DayDetailHeader: View {
    let dayNumber: Int
    let title: String
    let iconName: String
    let gradient: [Color]
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Background
            LinearGradient(
                colors: gradient,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Decorative
            GeometryReader { geo in
                Circle()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 200, height: 200)
                    .offset(x: geo.size.width - 80, y: -60)
            }
            .clipped()
            
            // Content
            VStack(spacing: 16) {
                // Icon
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: iconName)
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                }
                
                VStack(spacing: 6) {
                    Text("Day \(dayNumber)".uppercased())
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white.opacity(0.85))
                        .tracking(1.5)
                    
                    Text(title)
                        .font(.system(size: 26, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            .padding(.bottom, 28)
        }
        .frame(height: 240)
    }
}

// MARK: - Exercise List Card

struct ExerciseListCard: View {
    let exercises: [String]
    let gradient: [Color]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: "list.bullet.circle.fill")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(gradient[0])
                Text("Today's Exercises")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(AppTheme.textPrimaryColor)
            }
            
            VStack(spacing: 12) {
                ForEach(Array(exercises.enumerated()), id: \.offset) { index, exercise in
                    HStack(spacing: 14) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(colors: gradient.map { $0.opacity(0.15) },
                                                 startPoint: .topLeading, endPoint: .bottomTrailing)
                                )
                                .frame(width: 36, height: 36)
                            
                            Text("\(index + 1)")
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundColor(gradient[0])
                        }
                        
                        Text(exercise)
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(AppTheme.textPrimaryColor)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        Spacer()
                    }
                    
                    if index < exercises.count - 1 {
                        Divider()
                            .padding(.leading, 50)
                    }
                }
            }
        }
        .padding(20)
        .background(AppTheme.cardBackgroundColor)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
    }
}

// MARK: - Info Card

struct ChallengeInfoCard: View {
    let title: String
    let content: String
    let icon: String
    let gradient: [Color]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(gradient[0])
                Text(title)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(AppTheme.textPrimaryColor)
            }
            
            Text(content)
                .font(.system(size: 15))
                .foregroundColor(AppTheme.textSecondaryColor)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.cardBackgroundColor)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
    }
}

// MARK: - Back Button

struct ChallengeBackButtonView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        Button(action: {
            presentationMode.wrappedValue.dismiss()
        }) {
            HStack(spacing: 6) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                Text("Back")
                    .font(.system(size: 15, weight: .semibold))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(Color.black.opacity(0.3))
            .cornerRadius(20)
        }
    }
}
