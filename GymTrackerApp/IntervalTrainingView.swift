import SwiftUI

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
                Text("Customize Interval")
                    .font(.system(size: 28, weight: .heavy, design: .rounded))
                    .foregroundColor(Color(hex: "2B2D42"))

                VStack(spacing: 24) {
                    Label("Rounds", systemImage: "repeat")
                        .font(.headline)

                    Picker("Rounds", selection: $rounds) {
                        ForEach(1..<21, id: \.self) { Text("\($0)") }
                    }.pickerStyle(.wheel)

                    Label("Work", systemImage: "dumbbell.fill")
                        .font(.headline)
                        .foregroundColor(.green)

                    Picker("Work Duration (sec)", selection: $workDuration) {
                        ForEach(Array(stride(from: 10, through: 180, by: 5)), id: \.self) { value in
                            Text("\(value)")
                        }

                    }.pickerStyle(.wheel)

                    Label("Rest", systemImage: "pause.circle.fill")
                        .font(.headline)
                        .foregroundColor(.orange)

                    Picker("Rest Duration (sec)", selection: $restDuration) {
                        ForEach(Array(stride(from: 10, through: 180, by: 5)), id: \.self) { value in
                            Text("\(value) sec")
                        }

                    }.pickerStyle(.wheel)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(16)

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
            .padding()
            .navigationDestination(for: IntervalRoute.self) { route in
                switch route {
                case .timer:
                    IntervalTimerView(
                        rounds: rounds,
                        workDuration: workDuration,
                        restDuration: restDuration
                    )
                }
            }
        }
    }
}
