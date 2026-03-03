// FaceExercisesChallengeView.swift

import SwiftUI

// MARK: - Model for Face Exercise Day

struct FaceExerciseDay: Identifiable, ChallengeDayProtocol {
    let id = UUID()
    let day: Int
    let title: String
    let iconName: String
    let exercises: [String]
    let purpose: String
    let why: String
    
    var dayNumber: Int { day }
}

// MARK: - Main Face Exercises Challenge View

struct FaceExercisesChallengeView: View {
    @State private var showContent = false
    
    private let gradient = [Color(hex: "A18CD1"), Color(hex: "FBC2EB")]
    
    let facePlan: [FaceExerciseDay] = [
        FaceExerciseDay(
            day: 1,
            title: "Jawline & Neck",
            iconName: "face.smiling",
            exercises: [
                "Chin Lift Hold: 3 x 10s",
                "Jaw Resistance Open: 3 x 8",
                "Neck Flexion Hold: 3 x 10s",
                "Jaw Relaxation Release: 30-60s"
            ],
            purpose: "Build postural stability for the jaw and neck while reducing clenching tension.",
            why: "Masseter, suprahyoid, and platysma respond best to isometric holds. This improves jaw posture and awareness."
        ),
        FaceExerciseDay(
            day: 2,
            title: "Cheeks & Mid-Face",
            iconName: "face.smiling",
            exercises: [
                "Cheek Lifter Smile Hold: 3 x 10s",
                "Air Puff Transfer: 2 x 10",
                "Closed-Lip Smile: 3 x 8s"
            ],
            purpose: "Improve cheek tone and mid-face posture with low-force control.",
            why: "Zygomaticus responds to gentle isometrics, and air transfer improves motor control and lymphatic movement."
        ),
        FaceExerciseDay(
            day: 3,
            title: "Eyes & Upper Face",
            iconName: "eye.fill",
            exercises: [
                "Eye Squeeze + Relax: 3 x 8",
                "Brow Lift Resistance: 3 x 6s",
                "Slow Blink Control: 2 x 10"
            ],
            purpose: "Build gentle control around the eyes and forehead without overloading delicate tissue.",
            why: "Orbicularis oculi fatigues quickly. Short holds with relaxation improve awareness and circulation."
        ),
        FaceExerciseDay(
            day: 4,
            title: "Recovery & Drainage",
            iconName: "figure.walk",
            exercises: [
                "Gentle lymphatic massage",
                "Diaphragmatic breathing: 5 min",
                "Neck mobility stretches"
            ],
            purpose: "Support recovery, reduce puffiness, and prevent overtraining of facial muscles.",
            why: "Facial puffiness is fluid-related. Light pressure and breathing improve lymphatic flow."
        ),
        FaceExerciseDay(
            day: 5,
            title: "Mouth & Lip Strength",
            iconName: "sparkles",
            exercises: [
                "Lip Press Hold: 3 x 8s",
                "O-E Controlled Reps: 2 x 12",
                "Resistance Breathing: 3 x 6"
            ],
            purpose: "Build endurance in the lips and improve articulation control.",
            why: "Orbicularis oris is an endurance muscle. Controlled articulation improves tone and speech mechanics."
        ),
        FaceExerciseDay(
            day: 6,
            title: "Full Face Toning",
            iconName: "flame.fill",
            exercises: [
                "Lion Face (gentle): 3 x 10s",
                "Jaw Hold + Nasal Breathing: 3 x 15s",
                "Cheek Hold + Eye Control: 2 x 10s"
            ],
            purpose: "Full-face activation for circulation and neuromuscular control without overstretching.",
            why: "Short, gentle holds boost blood flow and coordination. Keep intensity light."
        ),
        FaceExerciseDay(
            day: 7,
            title: "Rest Day",
            iconName: "bed.double.fill",
            exercises: [
                "Full rest",
                "Light face massage if desired",
                "Stay hydrated"
            ],
            purpose: "Allow full recovery so facial muscles adapt and remain healthy.",
            why: "Rest prevents overuse and supports long-term tone and comfort."
        )
    ]
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                // Header
                ChallengeHeaderView(
                    title: "30-Day Face Exercises",
                    subtitle: "Facial Toning",
                    gradient: gradient,
                    totalDays: 7
                )
                
                // Instructions
                ChallengeInstructionsView(restTime: "30s", sets: "2-3", style: "Daily")
                
                // Day cards
                VStack(spacing: 14) {
                    ForEach(Array(facePlan.enumerated()), id: \.element.id) { index, day in
                        NavigationLink {
                            FaceExerciseDayDetailView(day: day)
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
                .padding(.bottom, 8)
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

struct FaceExerciseDayDetailView: View {
    let day: FaceExerciseDay
    
    private let gradient = [Color(hex: "A18CD1"), Color(hex: "FBC2EB")]
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
struct FaceExercisesChallengeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            FaceExercisesChallengeView()
        }
    }
}
#endif
