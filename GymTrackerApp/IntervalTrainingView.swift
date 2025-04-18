import SwiftUI
import AVFoundation

enum IntervalRoute: Hashable {
    case timer
}

struct IntervalTrainingView: View {
    @State private var rounds: Int = 5
    @State private var workDuration: Int = 50
    @State private var restDuration: Int = 10
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: 30) {
                // Glowing bust image
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [Color.white.opacity(0.9), Color.brown.opacity(0.2)]),
                                center: .center,
                                startRadius: 10,
                                endRadius: 90
                            )
                        )
                        .frame(width: 160, height: 160)
                        .shadow(color: .white.opacity(0.3), radius: 20)

                    Image("roman_bust")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        .shadow(radius: 5)
                }


                Text("Customize Interval")
                    .font(.system(size: 28, weight: .heavy, design: .rounded))
                    .foregroundColor(Color(hex: "2B2D42"))
                    .shadow(color: .gray.opacity(0.2), radius: 2, x: 0, y: 2)

                VStack(spacing: 24) {
                    Label("Rounds", systemImage: "repeat")
                        .font(.headline)
                        .foregroundColor(.primary)

                    Picker("Rounds", selection: $rounds) {
                        ForEach(1..<21, id: \.self) { Text("\($0)") }
                    }.pickerStyle(.wheel)

                    Label("Work", systemImage: "dumbbell.fill")
                        .font(.headline)
                        .foregroundColor(.green)

                    Picker("Work Duration (sec)", selection: $workDuration) {
                        ForEach(Array(stride(from: 10, through: 180, by: 5)), id: \.self) {
                            Text("\($0) sec")
                        }
                    }.pickerStyle(.wheel)

                    Label("Rest", systemImage: "pause.circle.fill")
                        .font(.headline)
                        .foregroundColor(.orange)

                    Picker("Rest Duration (sec)", selection: $restDuration) {
                        ForEach(Array(stride(from: 5, through: 120, by: 5)), id: \.self) {
                            Text("\($0) sec")
                        }
                    }.pickerStyle(.wheel)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(16)
                .padding(.horizontal)

                Button(action: {
                    path.append(IntervalRoute.timer)
                }) {
                    Text("Start Interval")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .padding(.horizontal)

                Spacer()
            }
            .navigationDestination(for: IntervalRoute.self) { route in
                switch route {
                case .timer:
                    IntervalTimerView(rounds: rounds, workDuration: workDuration, restDuration: restDuration)
                }
            }
        }
    }
}





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
            // Background: Simple White
            Color.white
                .ignoresSafeArea()

            VStack(spacing: 24) {
                // Glowing Lad Image
                ZStack {
                    Circle()
                        .fill(LinearGradient(colors: [Color.brown.opacity(0.2), Color.white.opacity(0.4)], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 160, height: 160)
                        .shadow(color: .white.opacity(0.6), radius: 25)

                    Image("lad")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                        .shadow(radius: 10)
                }

                // Round Info
                Text("Round \(currentRound) / \(rounds)")
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundColor(.gray)

                // Work or Rest Label
                Label(isWorking ? "Work" : "Rest", systemImage: isWorking ? "dumbbell.fill" : "leaf.fill")
                    .font(.title2)
                    .foregroundColor(isWorking ? .green : .orange)

                // Timer Display
                Text(String(format: "%02d:%02d", timeRemaining / 60, timeRemaining % 60))
                    .font(.system(size: 100, weight: .heavy, design: .rounded))
                    .foregroundColor(.black)
                    .shadow(radius: 4)

                // Control Buttons
                HStack(spacing: 30) {
                    Button(action: {
                        if isRunning {
                            isPaused.toggle()
                            isPaused ? timer?.invalidate() : runTimer()
                        } else {
                            startTimer()
                        }
                    }) {
                        Text(isRunning ? (isPaused ? "Resume" : "Pause") : "Start")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 28)
                            .padding(.vertical, 12)
                            .background(isPaused ? Color.orange : Color.green)
                            .cornerRadius(12)
                    }

                    Button(action: resetTimer) {
                        Text("Reset")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 28)
                            .padding(.vertical, 12)
                            .background(Color.gray)
                            .cornerRadius(12)
                    }
                }

                Spacer()
            }
            .padding()
        }
        .onDisappear { timer?.invalidate() }
    }

    // MARK: - Timer Functions

    func startTimer() {
        guard !isRunning else { return }
        isRunning = true
        timeRemaining = isWorking ? workDuration : restDuration
        runTimer()
    }

    func runTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                playBeepSound()
                if isWorking {
                    isWorking = false
                    timeRemaining = restDuration
                } else {
                    if currentRound < rounds {
                        currentRound += 1
                        isWorking = true
                        timeRemaining = workDuration
                    } else {
                        timer?.invalidate()
                        isRunning = false
                    }
                }
            }
        }
    }

    func resetTimer() {
        timer?.invalidate()
        currentRound = 1
        timeRemaining = 0
        isRunning = false
        isPaused = false
        isWorking = true
    }

    func playBeepSound() {
        if let url = Bundle.main.url(forResource: "beep", withExtension: "mp3") {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.prepareToPlay()
                audioPlayer?.play()
            } catch {
                print("❌ Beep failed: \(error.localizedDescription)")
            }
        } else {
            print("❌ Beep.mp3 not found in bundle.")
        }
    }

}

// MARK: - Hex Color Extension

