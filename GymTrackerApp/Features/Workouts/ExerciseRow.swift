// ExerciseRow.swift (Enhanced with Weight Tracking, Auto-Rest Timer, and Haptic Feedback)

import SwiftUI
import AudioToolbox

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
    @State private var isExpanded = false
    @State private var currentWeight: String = ""
    @State private var showWeightInput = false
    @AppStorage private var savedWeight: String
    
    private static func stableWeightStorageKey(for exercise: Exercise) -> String {
        let normalizedName = exercise.name
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
            .replacingOccurrences(of: " ", with: "_")
        return "weight_\(normalizedName)"
    }
    
    // Initialize AppStorage with exercise-specific key
    init(exercise: Exercise, isCompleted: Bool, toggleCompletion: @escaping () -> Void) {
        self.exercise = exercise
        self.isCompleted = isCompleted
        self.toggleCompletion = toggleCompletion
        self._savedWeight = AppStorage(
            wrappedValue: "",
            Self.stableWeightStorageKey(for: exercise)
        )
    }
    
    // Safely convert sets string to Int
    private var numberOfSets: Int {
        Int(exercise.sets) ?? 0
    }

    @State private var isPressed = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Main content row
            HStack(alignment: .top, spacing: 14) {
                // Enhanced checkbox with animation
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        toggleCompletion()
                    }
                }) {
                    ZStack {
                        Circle()
                            .fill(isCompleted ? Color(hex: "22C55E").opacity(0.15) : Color.clear)
                            .frame(width: 36, height: 36)
                        
                        Circle()
                            .stroke(isCompleted ? Color(hex: "22C55E") : Color.gray.opacity(0.3), lineWidth: 2.5)
                            .frame(width: 30, height: 30)
                        
                        if isCompleted {
                            Image(systemName: "checkmark")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(Color(hex: "22C55E"))
                                .transition(.scale.combined(with: .opacity))
                        }
                    }
                }
                .buttonStyle(PlainButtonStyle())

                // Exercise content
                VStack(alignment: .leading, spacing: 8) {
                    // Header row with name and expand button
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(exercise.name)
                                .font(.system(size: 17, weight: .bold))
                                .foregroundColor(isCompleted ? AppTheme.textSecondaryColor : AppTheme.textPrimaryColor)
                                .strikethrough(isCompleted)
                                .lineLimit(2)
                            
                            // Description always visible
                            Text(exercise.description)
                                .font(.system(size: 13))
                                .foregroundColor(AppTheme.textSecondaryColor)
                                .lineLimit(3)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        
                        Spacer()
                        
                        // Expand/collapse button for weight logging
                        Button(action: {
                            withAnimation(.spring(response: 0.3)) {
                                isExpanded.toggle()
                            }
                        }) {
                            Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(AppTheme.textSecondaryColor)
                                .padding(8)
                                .background(Color.gray.opacity(0.08))
                                .cornerRadius(8)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }

                    // Quick info row (always visible) - Beginner friendly labels
                    HStack(spacing: 10) {
                        // Sets badge
                        HStack(spacing: 4) {
                            Text("\(exercise.sets)")
                                .font(.system(size: 13, weight: .bold))
                            Text("sets")
                                .font(.system(size: 12, weight: .medium))
                        }
                        .foregroundColor(AppTheme.primaryColor)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(AppTheme.primaryColor.opacity(0.1))
                        .cornerRadius(8)
                        
                        // Reps badge
                        HStack(spacing: 4) {
                            Text("\(exercise.reps)")
                                .font(.system(size: 13, weight: .bold))
                            Text("reps")
                                .font(.system(size: 12, weight: .medium))
                        }
                        .foregroundColor(Color(hex: "8B5CF6"))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color(hex: "8B5CF6").opacity(0.1))
                        .cornerRadius(8)
                        
                        // Rest time badge
                        HStack(spacing: 4) {
                            Image(systemName: "timer")
                                .font(.system(size: 10))
                            Text(exercise.restTime)
                                .font(.system(size: 12, weight: .medium))
                        }
                        .foregroundColor(AppTheme.textSecondaryColor)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.gray.opacity(0.08))
                        .cornerRadius(8)
                        
                        Spacer()
                        
                        // Weight badge (if saved)
                        if !savedWeight.isEmpty {
                            HStack(spacing: 4) {
                                Image(systemName: "scalemass")
                                    .font(.system(size: 10))
                                Text("\(savedWeight) lbs")
                                    .font(.system(size: 12, weight: .bold))
                            }
                            .foregroundColor(Color(hex: "F59E0B"))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color(hex: "F59E0B").opacity(0.1))
                            .cornerRadius(8)
                        }
                    }
                    
                    // Expanded content - Weight logging only
                    if isExpanded {
                        VStack(alignment: .leading, spacing: 12) {
                            // Weight input section
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Log Weight")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(AppTheme.textSecondaryColor)
                                
                                HStack(spacing: 10) {
                                    HStack {
                                        TextField("Weight", text: $currentWeight)
                                            .keyboardType(.decimalPad)
                                            .font(.system(size: 15, weight: .semibold))
                                            .foregroundColor(AppTheme.textPrimaryColor)
                                        
                                        Text("lbs")
                                            .font(.system(size: 13))
                                            .foregroundColor(AppTheme.textSecondaryColor)
                                    }
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 10)
                                    .background(Color.gray.opacity(0.08))
                                    .cornerRadius(10)
                                    
                                    Button(action: {
                                        if !currentWeight.isEmpty {
                                            savedWeight = currentWeight
                                            // Haptic feedback
                                            let generator = UIImpactFeedbackGenerator(style: .medium)
                                            generator.impactOccurred()
                                        }
                                    }) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.system(size: 28))
                                            .foregroundColor(currentWeight.isEmpty ? Color.gray.opacity(0.3) : AppTheme.primaryColor)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    .disabled(currentWeight.isEmpty)
                                }
                            }
                            .padding(.top, 4)
                        }
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }

                    // Set tracker row
                    if numberOfSets > 0 {
                        HStack(spacing: 0) {
                            HStack(spacing: 8) {
                                ForEach(0..<numberOfSets, id: \.self) { index in
                                    Button(action: {
                                        withAnimation(.spring(response: 0.3)) {
                                            toggleSet(index: index)
                                        }
                                    }) {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(completedSets.contains(index) 
                                                    ? AppTheme.primaryColor 
                                                    : Color.gray.opacity(0.1))
                                                .frame(width: 32, height: 32)
                                            
                                            if completedSets.contains(index) {
                                                Image(systemName: "checkmark")
                                                    .font(.system(size: 12, weight: .bold))
                                                    .foregroundColor(.white)
                                            } else {
                                                Text("\(index + 1)")
                                                    .font(.system(size: 13, weight: .semibold))
                                                    .foregroundColor(AppTheme.textSecondaryColor)
                                            }
                                        }
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            
                            Spacer()
                            
                            // Rest timer
                            if showRestTimer {
                                TimerRingView(remainingTime: $remainingTime, totalTime: totalTime)
                                    .frame(width: 44, height: 44)
                                    .onTapGesture {
                                        controlRestTimer()
                                    }
                            } else {
                                Button(action: startRestTimer) {
                                    HStack(spacing: 4) {
                                        Image(systemName: "timer")
                                            .font(.system(size: 11, weight: .semibold))
                                        Text("Rest")
                                            .font(.system(size: 12, weight: .semibold))
                                    }
                                    .foregroundColor(AppTheme.primaryColor)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(AppTheme.primaryColor.opacity(0.1))
                                    .cornerRadius(10)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.top, 8)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(16)
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(isCompleted ? Color(hex: "22C55E").opacity(0.04) : AppTheme.cardBackgroundColor)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isCompleted ? Color(hex: "22C55E").opacity(0.25) : Color.gray.opacity(0.08), lineWidth: 1.5)
        )
        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 3)
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isCompleted)
        .onAppear {
            // Load saved weight into input field
            currentWeight = savedWeight
        }
        .onDisappear {
            timer?.invalidate()
        }
    }

    private func startRestTimer() {
        // Safely convert restTime string (e.g., "90s") to an Int
        let restSeconds = Int(exercise.restTime.replacingOccurrences(of: "s", with: "")) ?? 60
        
        totalTime = restSeconds
        remainingTime = restSeconds
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
                
                // Warning at 5 seconds
                if remainingTime == 5 {
                    let generator = UIImpactFeedbackGenerator(style: .light)
                    generator.impactOccurred()
                }
                
                if remainingTime <= 0 {
                    t.invalidate()
                    withAnimation(.spring(response: 0.3)) {
                        showRestTimer = false
                    }
                    
                    // Strong haptic and sound when timer completes
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.success)
                    
                    // System sound for timer completion
                    AudioServicesPlaySystemSound(1007) // Standard notification sound
                }
            }
        }
    }

    private func toggleSet(index: Int) {
        let wasCompleted = completedSets.contains(index)
        
        if wasCompleted {
            completedSets.remove(index)
        } else {
            completedSets.insert(index)
            
            // Auto-start rest timer after completing a set (unless it's the last set)
            if index < numberOfSets - 1 && !showRestTimer {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    startRestTimer()
                }
            }
            
            // Check if all sets are completed
            if completedSets.count == numberOfSets && !isCompleted {
                // Light haptic to indicate all sets done
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.impactOccurred()
            }
        }
    }
}

struct TimerRingView: View {
    @Binding var remainingTime: Int
    let totalTime: Int

    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(Color.gray.opacity(0.15), lineWidth: 3.5)
            
            // Progress circle
            Circle()
                .trim(from: 0, to: progressValue)
                .stroke(
                    LinearGradient(
                        colors: [AppTheme.primaryColor, AppTheme.accentColor],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: 3.5, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 1.0), value: remainingTime)
            
            // Time text
            VStack(spacing: 0) {
                Text("\(remainingTime)")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(AppTheme.primaryColor)
                Text("s")
                    .font(.system(size: 8, weight: .medium))
                    .foregroundColor(AppTheme.textSecondaryColor)
            }
        }
    }
    
    // Safe progress calculation to prevent NaN
    private var progressValue: CGFloat {
        guard totalTime > 0 else { return 0 }
        let progress = Double(totalTime - remainingTime) / Double(totalTime)
        // Clamp between 0 and 1 to prevent invalid values
        return CGFloat(max(0, min(1, progress)))
    }
}
