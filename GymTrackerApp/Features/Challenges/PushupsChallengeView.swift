// PushupsChallengeView.swift

import SwiftUI

// MARK: - Model for Pushups Day

struct PushupsDay: Identifiable, ChallengeDayProtocol {
    let id = UUID()
    let day: Int
    let title: String
    let iconName: String
    let exercises: [String]
    let tips: String
    
    var dayNumber: Int { day }
}

// MARK: - Main Pushups Challenge View

struct PushupsChallengeView: View {
    @State private var showContent = false
    
    private let gradient = [Color(hex: "36D1DC"), Color(hex: "5B86E5")]
    
    let pushupsPlan: [PushupsDay] = [
        PushupsDay(
            day: 1,
            title: "Foundation Day",
            iconName: "figure.arms.open",
            exercises: ["Wall Pushups: 3 sets of 10", "Knee Pushups: 2 sets of 5", "Plank Hold: 3 x 20s"],
            tips: "Focus on form over reps. Keep your core tight and body in a straight line."
        ),
        PushupsDay(
            day: 2,
            title: "Building Strength",
            iconName: "arrow.up.circle.fill",
            exercises: ["Knee Pushups: 3 sets of 8", "Incline Pushups: 2 sets of 6", "Shoulder Taps: 2 x 10"],
            tips: "Rest 60 seconds between sets. Control the descent for maximum benefit."
        ),
        PushupsDay(
            day: 3,
            title: "Progressive Overload",
            iconName: "chart.line.uptrend.xyaxis",
            exercises: ["Knee Pushups: 4 sets of 10", "Incline Pushups: 3 sets of 8", "Hold at Bottom: 3 x 10s"],
            tips: "Focus on controlled movement. Squeeze your chest at the top of each rep."
        ),
        PushupsDay(
            day: 4,
            title: "Active Recovery",
            iconName: "figure.walk",
            exercises: ["Light stretching", "Shoulder mobility exercises", "30 min walk or light cardio"],
            tips: "Recovery is when muscles rebuild stronger. Stay hydrated and eat protein."
        ),
        PushupsDay(
            day: 5,
            title: "Standard Pushups",
            iconName: "figure.strengthtraining.traditional",
            exercises: ["Standard Pushups: 3 sets of 5", "Knee Pushups: 2 sets of 10", "Wide Pushups: 2 sets of 5"],
            tips: "Time to test your full pushups! Even 1-2 reps is progress."
        ),
        PushupsDay(
            day: 6,
            title: "Intensity Day",
            iconName: "flame.fill",
            exercises: ["Standard Pushups: 4 sets of 8", "Diamond Pushups: 2 sets of 5", "Pushup Hold: 3 x 15s"],
            tips: "Push to your limit but maintain form. Quality over quantity always."
        ),
        PushupsDay(
            day: 7,
            title: "Rest Day",
            iconName: "bed.double.fill",
            exercises: ["Complete rest", "Light foam rolling", "Muscle recovery"],
            tips: "Let your muscles recover and adapt. You've earned this rest!"
        )
    ]
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                // Header
                ChallengeHeaderView(
                    title: "30-Day Pushups Challenge",
                    subtitle: "Upper Body Power",
                    gradient: gradient,
                    totalDays: 7
                )
                
                // Instructions
                ChallengeInstructionsView(restTime: "60s", sets: "3-4", style: "Progressive")
                
                // Day cards
                VStack(spacing: 14) {
                    ForEach(Array(pushupsPlan.enumerated()), id: \.element.id) { index, day in
                        NavigationLink {
                            PushupsDayDetailView(day: day)
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

struct PushupsDayDetailView: View {
    let day: PushupsDay
    
    private let gradient = [Color(hex: "36D1DC"), Color(hex: "5B86E5")]
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
struct PushupsChallengeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            PushupsChallengeView()
        }
    }
}
#endif
