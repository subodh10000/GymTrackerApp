// AbsChallengeView.swift

import SwiftUI

// MARK: - Model for Abs Day

struct IntenseAbsDay: Identifiable, ChallengeDayProtocol {
    let id = UUID()
    let day: Int
    let title: String
    let iconName: String
    let exercises: [String]
    let purpose: String
    let why: String
    
    var dayNumber: Int { day }
}

// MARK: - Main Abs Challenge View

struct AbsChallengeView: View {
    @State private var showContent = false
    
    private let gradient = [Color(hex: "FF512F"), Color(hex: "DD2476")]
    
    let intensePlan: [IntenseAbsDay] = [
        IntenseAbsDay(
            day: 1,
            title: "Core Stabilization",
            iconName: "shield.lefthalf.filled",
            exercises: ["Plank (standard)", "Dead Bug", "Hollow Body Hold"],
            purpose: "Build a strong foundation and activate deep core muscles. These exercises improve stability, posture, and reduce injury risk.",
            why: "Planks and dead bugs engage stabilizers like transverse abdominis and internal oblique better than traditional crunches."
        ),
        IntenseAbsDay(
            day: 2,
            title: "Lower Abs & Anti-Extension",
            iconName: "arrow.down.forward.and.arrow.up.backward",
            exercises: ["Leg Raises (lying)", "Flutter Kicks", "Reverse Crunches"],
            purpose: "Target hard-to-hit lower ab region safely.",
            why: "Leg raises produce higher rectus abdominis activation than basic planks alone."
        ),
        IntenseAbsDay(
            day: 3,
            title: "Obliques & Rotation",
            iconName: "arrow.triangle.turn.up.right.diamond.fill",
            exercises: ["Bicycle Crunches", "Russian Twists (weighted if possible)", "Side Plank (Left)"],
            purpose: "Sculpt the waistline and improve rotational strength.",
            why: "Oblique drills improve rotational power and definition."
        ),
        IntenseAbsDay(
            day: 4,
            title: "Active Recovery",
            iconName: "figure.walk",
            exercises: ["Light stretching / yoga", "Brisk walk (20–30 min)", "Diaphragmatic breathing"],
            purpose: "Recovery helps muscle growth, reduces soreness, and supports long-term consistency.",
            why: "Recovery isn't optional — muscles grow during rest."
        ),
        IntenseAbsDay(
            day: 5,
            title: "Strength & Anti-Rotation",
            iconName: "dot.circle.and.hand.point.up.left.fill",
            exercises: ["Pallof Press / Band Anti-Rotation", "Windshield Wipers (lying)", "Plank with Alternating Arm Reach"],
            purpose: "Train core strength from different planes.",
            why: "Anti-rotation drills build deeper core strength and transfer to athletic performance."
        ),
        IntenseAbsDay(
            day: 6,
            title: "Full Core Burn",
            iconName: "flame.fill",
            exercises: ["Mountain Climbers", "Ab Rollouts (use wheel/band)", "Side Plank (Right)"],
            purpose: "Maximum tension and fat burning with core fatigue.",
            why: "Combines endurance, anti-extension, and dynamic stability to boost fat burn."
        ),
        IntenseAbsDay(
            day: 7,
            title: "Rest Day",
            iconName: "bed.double.fill",
            exercises: ["Full rest", "Light foam rolling if needed", "Stay hydrated"],
            purpose: "Essential for repair, strength growth, and preventing injury.",
            why: "Rest supports recovery so you can come back stronger."
        )
    ]
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                // Header
                ChallengeHeaderView(
                    title: "30-Day Abs Challenge",
                    subtitle: "Core Strength",
                    gradient: gradient,
                    totalDays: 7
                )
                
                // Instructions
                ChallengeInstructionsView(restTime: "15s", sets: "3", style: "45s work")
                
                // Day cards
                VStack(spacing: 14) {
                    ForEach(Array(intensePlan.enumerated()), id: \.element.id) { index, day in
                        NavigationLink {
                            AbsDayDetailView(day: day)
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

struct AbsDayDetailView: View {
    let day: IntenseAbsDay
    
    private let gradient = [Color(hex: "FF512F"), Color(hex: "DD2476")]
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
                
                // Purpose card
                ChallengeInfoCard(
                    title: "Today's Focus",
                    content: day.purpose,
                    icon: "target",
                    gradient: gradient
                )
                .padding(.horizontal, 20)
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 25)
                
                // Science card
                ChallengeInfoCard(
                    title: "Why These Work",
                    content: day.why,
                    icon: "sparkles",
                    gradient: gradient
                )
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 30)
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
struct AbsChallengeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            AbsChallengeView()
        }
    }
}
#endif
