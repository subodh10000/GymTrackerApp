import SwiftUI

enum IntervalRoute: Hashable {
    case timer(rounds: Int, workDuration: Int, restDuration: Int)
}

struct IntervalTrainingView: View {
    @State private var rounds: Int = 5
    @State private var workDuration: Int = 30
    @State private var restDuration: Int = 10
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                AppTheme.backgroundColor
                    .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        presetsSection
                        configurationSection
                        summarySection
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle("Start Interval Time")
            .navigationBarTitleDisplayMode(.large)
            .navigationDestination(for: IntervalRoute.self) { route in
                switch route {
                case .timer(let rounds, let workDuration, let restDuration):
                    IntervalTimerView(
                        rounds: rounds,
                        workDuration: workDuration,
                        restDuration: restDuration
                    )
                }
            }
        }
    }
    
    private var presetsSection: some View {
        startButton
    }

    private var configurationSection: some View {
        VStack(spacing: 14) {
            IntervalConfigRow(
                title: "Rounds",
                icon: "repeat",
                value: $rounds,
                range: 1...20,
                step: 1,
                color: AppTheme.primaryColor,
                unit: "rounds"
            )
            
            IntervalConfigRow(
                title: "Work",
                subtitle: "High effort time",
                icon: "flame.fill",
                value: $workDuration,
                range: 10...180,
                step: 5,
                color: .green,
                unit: "sec"
            )
            
            IntervalConfigRow(
                title: "Rest",
                subtitle: "Recovery time",
                icon: "pause.circle.fill",
                value: $restDuration,
                range: 5...120,
                step: 5,
                color: .orange,
                unit: "sec"
            )
        }
    }
    
    private var summarySection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Summary")
                .font(.headline)
                .foregroundColor(AppTheme.textPrimaryColor)
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Total time")
                        .font(.subheadline)
                        .foregroundColor(AppTheme.textSecondaryColor)
                    Text(totalDurationString)
                        .font(.title3.weight(.bold))
                        .foregroundColor(AppTheme.textPrimaryColor)
                }
                Spacer()
                HStack(spacing: 6) {
                    Text("\(rounds)")
                        .font(.headline)
                        .foregroundColor(AppTheme.primaryColor)
                    Text("rounds")
                        .font(.subheadline)
                        .foregroundColor(AppTheme.textSecondaryColor)
                }
            }
        }
        .padding(16)
        .background(AppTheme.cardBackgroundColor)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
    }
    
    private var startButton: some View {
        Button(action: {
            // Capture current values when button is clicked
            path.append(IntervalRoute.timer(
                rounds: rounds,
                workDuration: workDuration,
                restDuration: restDuration
            ))
        }) {
            HStack(spacing: 12) {
                Image(systemName: "play.fill")
                    .font(.title3)
                Text("Start Interval Training")
                    .font(.headline.weight(.semibold))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(
                LinearGradient(
                    colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .foregroundColor(.white)
            .cornerRadius(16)
            .shadow(color: AppTheme.primaryColor.opacity(0.4), radius: 12, x: 0, y: 6)
        }
    }
    
    private var totalDurationString: String {
        let totalSeconds = rounds * workDuration + max(0, rounds - 1) * restDuration
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return minutes > 0 ? "\(minutes)m \(seconds)s" : "\(seconds)s"
    }
    
    private func applyPreset(rounds: Int, work: Int, rest: Int) {
        withAnimation(.easeInOut(duration: 0.2)) {
            self.rounds = rounds
            self.workDuration = work
            self.restDuration = rest
        }
    }
}

struct IntervalConfigRow: View {
    let title: String
    var subtitle: String? = nil
    let icon: String
    @Binding var value: Int
    let range: ClosedRange<Int>
    var step: Int = 1
    let color: Color
    let unit: String
    
    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.15))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(color)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.headline.weight(.semibold))
                        .foregroundColor(AppTheme.textPrimaryColor)
                    
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.caption)
                            .foregroundColor(AppTheme.textSecondaryColor)
                    }
                }
                
                Spacer()
                
                HStack(spacing: 6) {
                    Text("\(value)")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(color)
                        .monospacedDigit()
                    Text(unit)
                        .font(.caption)
                        .foregroundColor(AppTheme.textSecondaryColor)
                }
            }
            
            Slider(value: Binding(
                get: { Double(value) },
                set: { newValue in
                    value = Int(newValue.rounded())
                }
            ), in: Double(range.lowerBound)...Double(range.upperBound), step: Double(step))
            .tint(color)
            
            HStack(spacing: 10) {
                Button(action: { value = max(range.lowerBound, value - step) }) {
                    Image(systemName: "minus")
                        .font(.subheadline.weight(.semibold))
                        .frame(width: 36, height: 36)
                        .background(color.opacity(0.12))
                        .foregroundColor(color)
                        .clipShape(Circle())
                }
                Spacer()
                Button(action: { value = min(range.upperBound, value + step) }) {
                    Image(systemName: "plus")
                        .font(.subheadline.weight(.semibold))
                        .frame(width: 36, height: 36)
                        .background(color.opacity(0.12))
                        .foregroundColor(color)
                        .clipShape(Circle())
                }
            }
        }
        .padding(16)
        .background(AppTheme.cardBackgroundColor)
        .cornerRadius(18)
        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
    }
}

struct PresetChip: View {
    let title: String
    let detail: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(AppTheme.textPrimaryColor)
                Text(detail)
                    .font(.caption)
                    .foregroundColor(AppTheme.textSecondaryColor)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(AppTheme.cardBackgroundColor)
            .cornerRadius(14)
            .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 3)
        }
    }
}

#if DEBUG
struct IntervalTrainingView_Previews: PreviewProvider {
    static var previews: some View {
        IntervalTrainingView()
    }
}
#endif
