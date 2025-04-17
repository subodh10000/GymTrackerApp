// ExerciseRow.swift (Finalized with Set Tracker, Timer, and Color Gradient Theme)

import SwiftUI

struct ExerciseRow: View {
    let exercise: Exercise
    let isCompleted: Bool
    let toggleCompletion: () -> Void

    @State private var showRestTimer = false
    @State private var remainingTime = 0
    @State private var totalTime = 0
    @State private var timer: Timer?
    @State private var isPaused = true
    @State private var completedSets: Set<Int> = []

    var body: some View {
        ZStack {
            AppTheme.secondaryGradient
                .opacity(0.08)
                .cornerRadius(16)

            VStack(alignment: .leading, spacing: 0) {
                Button(action: {
                    toggleCompletion()
                }) {
                    HStack(alignment: .top, spacing: 15) {
                        ZStack {
                            Circle()
                                .stroke(isCompleted ? AppTheme.primaryColor : Color.gray.opacity(0.5), lineWidth: 2)
                                .frame(width: 24, height: 24)

                            if isCompleted {
                                Circle()
                                    .fill(AppTheme.primaryColor)
                                    .frame(width: 24, height: 24)
                                Image(systemName: "checkmark")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text(exercise.name)
                                .font(.headline)
                                .foregroundColor(AppTheme.textPrimaryColor)
                                .strikethrough(isCompleted)

                            Text(exercise.description)
                                .font(.caption)
                                .foregroundColor(AppTheme.textSecondaryColor)

                            HStack(spacing: 10) {
                                Text("\(exercise.sets) sets × \(exercise.reps)")
                                    .font(.subheadline)
                                    .foregroundColor(AppTheme.accentColor)

                                Spacer()

                                if showRestTimer {
                                    TimerRingView(remainingTime: $remainingTime, totalTime: totalTime)
                                        .frame(width: 32, height: 32)
                                        .onTapGesture {
                                            controlRestTimer()
                                        }
                                } else {
                                    Image(systemName: "timer")
                                        .foregroundColor(AppTheme.primaryColor)
                                        .onTapGesture {
                                            startRestTimer()
                                        }
                                }
                            }

                            HStack(spacing: 8) {
                                ForEach(0..<exercise.sets, id: \ .self) { index in
                                    Circle()
                                        .fill(completedSets.contains(index) ? AppTheme.primaryColor : Color.gray.opacity(0.3))
                                        .frame(width: 14, height: 14)
                                        .onTapGesture {
                                            toggleSet(index: index)
                                        }
                                }
                            }
                        }
                    }
                    .padding(.vertical, 15)
                    .padding(.horizontal, 20)
                    .contentShape(Rectangle())
                }
                .buttonStyle(PlainButtonStyle())

                Divider()
                    .padding(.leading, 60)
                    .opacity(0.3)
            }
        }
        .padding(.horizontal)
        .padding(.top, 8)
        .padding(.bottom, 4)
        .background(AppTheme.cardBackgroundColor)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        .onDisappear {
            timer?.invalidate()
        }
    }

    private func startRestTimer() {
        totalTime = exercise.restTime
        remainingTime = exercise.restTime
        showRestTimer = true
        isPaused = false
        startTimer()
    }

    private func controlRestTimer() {
        if isPaused {
            isPaused = false
            startTimer()
        } else {
            isPaused = true
        }
    }

    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { t in
            if !isPaused {
                remainingTime -= 1
                if remainingTime <= 0 {
                    t.invalidate()
                    showRestTimer = false
                }
            }
        }
    }

    private func toggleSet(index: Int) {
        if completedSets.contains(index) {
            completedSets.remove(index)
        } else {
            completedSets.insert(index)
        }
    }
}

struct TimerRingView: View {
    @Binding var remainingTime: Int
    let totalTime: Int

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: 4)

            Circle()
                .trim(from: 0, to: CGFloat(Double(totalTime - remainingTime) / Double(totalTime)))
                .stroke(AppTheme.accentColor, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.linear, value: remainingTime)

            Text("\(remainingTime)s")
                .font(.caption2)
                .foregroundColor(AppTheme.accentColor)
        }
    }
}
