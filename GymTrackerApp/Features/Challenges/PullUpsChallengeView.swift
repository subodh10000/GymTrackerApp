// PullUpsChallengeView.swift

import SwiftUI

// MARK: - Model for Pull-Ups Day

struct PullUpsDay: Identifiable, ChallengeDayProtocol {
    let id = UUID()
    let day: Int
    let title: String
    let iconName: String
    let exercises: [String]
    let tips: String
    
    var dayNumber: Int { day }
}

// MARK: - Main Pull-Ups Challenge View

struct PullUpsChallengeView: View {
    @State private var showContent = false
    
    private let gradient = [Color(hex: "11998E"), Color(hex: "38EF7D")]
    
    let pullUpsPlan: [PullUpsDay] = [
        PullUpsDay(
            day: 1,
            title: "Foundation Day",
            iconName: "figure.climbing",
            exercises: [
                "Dead Hangs: 3 x 30s",
                "Negative Pull-Ups: 2 x 3",
                "Scapular Pulls: 3 x 10"
            ],
            tips: "Focus on grip strength and shoulder engagement. Dead hangs build the foundation for all pulling movements."
        ),
        PullUpsDay(
            day: 2,
            title: "Building Grip",
            iconName: "hand.raised.fill",
            exercises: [
                "Dead Hangs: 4 x 45s",
                "Assisted Pull-Ups: 3 x 5",
                "Hanging Knee Raises: 2 x 8"
            ],
            tips: "Use a resistance band for assisted pull-ups if needed. Control every movement."
        ),
        PullUpsDay(
            day: 3,
            title: "Progressive Training",
            iconName: "arrow.up.circle.fill",
            exercises: [
                "Negative Pull-Ups: 4 x 5",
                "Assisted Pull-Ups: 3 x 6",
                "Dead Hangs: 2 x 60s"
            ],
            tips: "Slow negatives (5 seconds down) build incredible strength. Focus on the eccentric phase."
        ),
        PullUpsDay(
            day: 4,
            title: "Active Recovery",
            iconName: "figure.walk",
            exercises: [
                "Light stretching",
                "Shoulder mobility drills",
                "Back stretches & foam rolling"
            ],
            tips: "Recovery is crucial for muscle repair. Light movement promotes blood flow without strain."
        ),
        PullUpsDay(
            day: 5,
            title: "Strength Building",
            iconName: "figure.strengthtraining.traditional",
            exercises: [
                "Assisted Pull-Ups: 4 x 8",
                "Negative Pull-Ups: 3 x 6",
                "Dead Hangs: 3 x 45s"
            ],
            tips: "Try to reduce band assistance each week. You're building real strength!"
        ),
        PullUpsDay(
            day: 6,
            title: "Intensity Day",
            iconName: "flame.fill",
            exercises: [
                "Max effort Pull-Ups (assisted if needed)",
                "Negative Pull-Ups: 4 x 8",
                "Dead Hang Challenge: 3 x max time"
            ],
            tips: "Test your limits today. Even one unassisted rep is a huge win!"
        ),
        PullUpsDay(
            day: 7,
            title: "Rest Day",
            iconName: "bed.double.fill",
            exercises: [
                "Complete rest",
                "Light stretching if desired",
                "Stay hydrated & eat protein"
            ],
            tips: "Your muscles grow during rest. You've earned this recovery day!"
        )
    ]
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                // Header
                ChallengeHeaderView(
                    title: "30-Day Pull-Ups Challenge",
                    subtitle: "Back & Grip",
                    gradient: gradient,
                    totalDays: 7
                )
                
                // Instructions
                ChallengeInstructionsView(restTime: "90s", sets: "3-4", style: "Progressive")
                
                // Day cards
                VStack(spacing: 14) {
                    ForEach(Array(pullUpsPlan.enumerated()), id: \.element.id) { index, day in
                        NavigationLink {
                            PullUpsDayDetailView(day: day)
                        } label: {
                            ChallengeDayCard(day: day, gradient: gradient)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 20)
                        .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(Double(index) * 0.05), value: showContent)
                    }
                }
                .padding(20)
                .padding(.bottom, 100)
            }
        }
        .ignoresSafeArea(edges: .top)
        .navigationBarTitleDisplayMode(.inline)
        .background(AppTheme.backgroundColor.ignoresSafeArea())
        .onAppear {
            withAnimation {
                showContent = true
            }
        }
    }
}

// MARK: - Day Detail View

struct PullUpsDayDetailView: View {
    let day: PullUpsDay
    
    private let gradient = [Color(hex: "11998E"), Color(hex: "38EF7D")]
    @State private var showContent = false
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                // Header
                DayDetailHeader(
                    dayNumber: day.day,
                    title: day.title,
                    iconName: day.iconName,
                    gradient: gradient
                )
                
                // Exercise list
                ExerciseListCard(exercises: day.exercises, gradient: gradient)
                    .padding(.horizontal, 20)
                    .padding(.top, -30)
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 20)
                
                // Tips card
                ChallengeInfoCard(
                    title: "Pro Tips",
                    content: day.tips,
                    icon: "lightbulb.fill",
                    gradient: gradient
                )
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 25)
            }
        }
        .ignoresSafeArea(edges: .top)
        .navigationBarTitleDisplayMode(.inline)
        .background(AppTheme.backgroundColor.ignoresSafeArea())
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2)) {
                showContent = true
            }
        }
    }
}

// MARK: - Preview

#if DEBUG
struct PullUpsChallengeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            PullUpsChallengeView()
        }
    }
}
#endif
