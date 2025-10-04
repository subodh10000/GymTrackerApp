import SwiftUI
import AVFoundation

struct IntervalTimerView: View {
    let rounds: Int
    let workDuration: Int
    let restDuration: Int

    @State private var currentRound = 1
    @State private var timeRemaining = 0
    @State private var isWorking = true
    @State private var isRunning = false
    @State private var isPaused = false
    @State private var timer: Timer?
    @State private var audioPlayer: AVAudioPlayer?

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            VStack(spacing: 30) {
                Text("Round \(currentRound) / \(rounds)")
                    .font(.largeTitle.bold())

                Text(isWorking ? "WORK" : "REST")
                    .font(.title)
                    .foregroundColor(isWorking ? .green : .orange)

                Text(timeString(from: timeRemaining))
                    .font(.system(size: 72, weight: .bold, design: .rounded))
                    .foregroundColor(.black)

                HStack(spacing: 30) {
                    Button(isRunning ? (isPaused ? "Resume" : "Pause") : "Start") {
                        if isRunning {
                            isPaused.toggle()
                            isPaused ? timer?.invalidate() : runTimer()
                        } else {
                            startTimer()
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(isPaused ? Color.orange : Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(12)

                    Button("Reset") {
                        stopTimer()
                        resetState()
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .padding(.horizontal)
            }
            .padding()
        }
        .onAppear {
            configureAudioSession()
        }
        .onDisappear {
            timer?.invalidate()
        }
    }

    // MARK: - Timer Logic

    func startTimer() {
        timeRemaining = workDuration
        isWorking = true
        isRunning = true
        runTimer()
    }

    func runTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if !isPaused {
                timeRemaining -= 1
                if timeRemaining <= 0 {
                    switchPhase()
                }
            }
        }
    }

    func switchPhase() {
        if isWorking {
            isWorking = false
            timeRemaining = restDuration
        } else {
            if currentRound >= rounds {
                stopTimer()
            } else {
                isWorking = true
                currentRound += 1
                timeRemaining = workDuration
            }
        }
    }

    func stopTimer() {
        timer?.invalidate()
        isRunning = false
    }

    func resetState() {
        currentRound = 1
        timeRemaining = 0
        isWorking = true
        isPaused = false
        isRunning = false
    }

    func timeString(from seconds: Int) -> String {
        String(format: "%02d:%02d", seconds / 60, seconds % 60)
    }

    // MARK: - Background Audio

    func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Audio session error: \(error)")
        }
    }
}
