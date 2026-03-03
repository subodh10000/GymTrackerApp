import SwiftUI
import AVFoundation
import AudioToolbox

struct IntervalTimerView: View {
    let rounds: Int
    let workDuration: Int
    let restDuration: Int

    @State private var currentRound = 1
    @State private var timeRemaining: Int
    @State private var isWorking = true
    @State private var isRunning = false
    @State private var isPaused = false
    @State private var isCompleted = false
    @State private var timer: Timer?
    @Environment(\.dismiss) private var dismiss
    
    // Initialize with work duration so user sees what they're about to start
    init(rounds: Int, workDuration: Int, restDuration: Int) {
        self.rounds = rounds
        self.workDuration = workDuration
        self.restDuration = restDuration
        _timeRemaining = State(initialValue: workDuration)
    }

    var body: some View {
        ZStack {
            backgroundGradient
                .ignoresSafeArea()
            
            if isCompleted {
                completionView
            } else {
                timerView
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear {
            // Clean up timer when view disappears
            timer?.invalidate()
            timer = nil
        }
    }
    
    private var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: isWorking 
                ? [Color.green.opacity(0.12), Color.green.opacity(0.06), AppTheme.backgroundColor]
                : [Color.orange.opacity(0.12), Color.orange.opacity(0.06), AppTheme.backgroundColor],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    // Safe progress calculation to prevent NaN
    private var progressValue: Double {
        guard rounds > 0 else { return 0 }
        let progress = Double(currentRound) / Double(rounds)
        // Clamp between 0 and 1 to prevent invalid values
        return max(0, min(1, progress))
    }
    
    private var timerView: some View {
        GeometryReader { geometry in
            let screenHeight = geometry.size.height
            let isCompact = screenHeight < 700
            
            VStack(spacing: isCompact ? 20 : 30) {
                // Round indicator - Responsive sizing
                VStack(spacing: 12) {
                    Text("Round \(currentRound) of \(rounds)")
                        .font(.system(size: isCompact ? 28 : 32, weight: .bold, design: .rounded))
                        .foregroundColor(AppTheme.textPrimaryColor)
                    
                    ProgressView(value: progressValue, total: 1.0)
                        .progressViewStyle(LinearProgressViewStyle(tint: AppTheme.primaryColor))
                        .frame(height: 8)
                        .scaleEffect(x: 1, y: 1.5, anchor: .center)
                }
                .padding(.horizontal, 30)
                .padding(.top, isCompact ? 10 : 20)
                
                Spacer()
                    .frame(height: isCompact ? 10 : 20)
                
                // Phase indicator with timer - Center of screen
                VStack(spacing: 20) {
                    // Phase badge
                    Text(isWorking ? "WORK" : "REST")
                        .font(.system(size: isCompact ? 20 : 24, weight: .heavy, design: .rounded))
                        .foregroundColor(isWorking ? .green : .orange)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(
                            Capsule()
                                .fill((isWorking ? Color.green : Color.orange).opacity(0.15))
                        )
                    
                    // Timer display - Responsive font size
                    Text(timeString(from: timeRemaining))
                        .font(.system(size: isCompact ? 56 : 72, weight: .bold, design: .rounded))
                        .foregroundColor(AppTheme.textPrimaryColor)
                        .monospacedDigit()
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                }
                
                Spacer()
                    .frame(height: isCompact ? 10 : 20)
                
                // Control buttons - Always at bottom
                VStack(spacing: 12) {
                    if !isRunning {
                        Button(action: startTimer) {
                            HStack(spacing: 10) {
                                Image(systemName: "play.fill")
                                    .font(.title3)
                                Text("Start")
                                    .font(.headline.weight(.semibold))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    colors: [Color.green, Color.green.opacity(0.8)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .foregroundColor(.white)
                            .cornerRadius(16)
                            .shadow(color: Color.green.opacity(0.3), radius: 8, x: 0, y: 4)
                        }
                    } else {
                        HStack(spacing: 12) {
                            Button(action: togglePause) {
                                HStack(spacing: 8) {
                                    Image(systemName: isPaused ? "play.fill" : "pause.fill")
                                        .font(.title3)
                                    Text(isPaused ? "Resume" : "Pause")
                                        .font(.headline.weight(.semibold))
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    LinearGradient(
                                        colors: isPaused 
                                            ? [Color.orange, Color.orange.opacity(0.8)]
                                            : [Color.green, Color.green.opacity(0.8)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .foregroundColor(.white)
                                .cornerRadius(16)
                                .shadow(color: (isPaused ? Color.orange : Color.green).opacity(0.3), radius: 8, x: 0, y: 4)
                            }
                            
                            Button(action: resetTimer) {
                                HStack(spacing: 8) {
                                    Image(systemName: "arrow.counterclockwise")
                                        .font(.title3)
                                    Text("Reset")
                                        .font(.headline.weight(.semibold))
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.red)
                                .foregroundColor(.white)
                                .cornerRadius(16)
                                .shadow(color: Color.red.opacity(0.3), radius: 8, x: 0, y: 4)
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, isCompact ? 20 : 30)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    private var completionView: some View {
        GeometryReader { geometry in
            let isCompact = geometry.size.height < 700
            
            VStack(spacing: isCompact ? 20 : 30) {
                Spacer()
                
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: isCompact ? 100 : 120, height: isCompact ? 100 : 120)
                        .shadow(color: AppTheme.primaryColor.opacity(0.3), radius: 20, x: 0, y: 10)
                    
                    Image(systemName: "checkmark")
                        .font(.system(size: isCompact ? 50 : 60, weight: .bold))
                        .foregroundColor(.white)
                }
                
                VStack(spacing: 12) {
                    Text("Workout Complete!")
                        .font(.system(size: isCompact ? 24 : 28, weight: .bold))
                        .foregroundColor(AppTheme.textPrimaryColor)
                    
                    Text("You completed \(rounds) rounds")
                        .font(.system(size: isCompact ? 16 : 18))
                        .foregroundColor(AppTheme.textSecondaryColor)
                }
                
                Spacer()
                
                Button(action: {
                    dismiss()
                }) {
                    Text("Done")
                        .font(.headline.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .foregroundColor(.white)
                        .cornerRadius(16)
                        .shadow(color: AppTheme.primaryColor.opacity(0.3), radius: 12, x: 0, y: 6)
                }
                .padding(.horizontal, 30)
                .padding(.bottom, isCompact ? 20 : 30)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    // MARK: - Timer Logic

    func startTimer() {
        timeRemaining = workDuration
        isWorking = true
        isRunning = true
        isPaused = false
        runTimer()
    }

    func runTimer() {
        timer?.invalidate()
        // Timer.scheduledTimer automatically runs on the current run loop (main thread)
        // Note: No need for [weak self] since structs don't have retain cycles
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            // Timer callback is already on main thread
            if !isPaused {
                if timeRemaining > 0 {
                    timeRemaining -= 1
                } else {
                    switchPhase()
                }
            }
        }
    }
    
    func togglePause() {
        isPaused.toggle()
        if isPaused {
            timer?.invalidate()
        } else {
            // Resume timer - continue from current timeRemaining
            runTimer()
        }
    }

    func switchPhase() {
        // Stop current timer before switching to avoid race conditions
        timer?.invalidate()
        playSound()
        
        // Timer callback is already on main thread, so we can update directly
        if isWorking {
            // Switch to rest
            isWorking = false
            timeRemaining = restDuration
            runTimer()
        } else {
            // Switch to next round or complete
            if currentRound >= rounds {
                completeWorkout()
            } else {
                currentRound += 1
                isWorking = true
                timeRemaining = workDuration
                runTimer()
            }
        }
    }
    
    func completeWorkout() {
        stopTimer()
        isCompleted = true
        playCompletionSound()
    }

    func resetTimer() {
        stopTimer()
        currentRound = 1
        timeRemaining = workDuration  // Show work duration instead of 0
        isWorking = true
        isPaused = false
        isRunning = false
        isCompleted = false
    }
    
    func stopTimer() {
        timer?.invalidate()
        isRunning = false
    }

    func timeString(from seconds: Int) -> String {
        let mins = seconds / 60
        let secs = seconds % 60
        return String(format: "%02d:%02d", mins, secs)
    }

    // MARK: - Audio Feedback

    func playSound() {
        // System sound for phase change - doesn't interrupt other audio
        // Using system sounds that mix with other audio without requiring audio session configuration
        AudioServicesPlaySystemSound(1057)
    }
    
    func playCompletionSound() {
        // System sound for completion - doesn't interrupt other audio
        AudioServicesPlaySystemSound(1054)
    }
}

#if DEBUG
struct IntervalTimerView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            IntervalTimerView(rounds: 5, workDuration: 30, restDuration: 10)
        }
    }
}
#endif
