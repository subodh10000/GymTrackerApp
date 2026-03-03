// HomeHistoryView.swift - Workout History with Stats & Calendar

import SwiftUI

// MARK: - Shared DateFormatters (expensive to create, so cache them)

private enum DateFormatters {
    static let dayOfWeek: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter
    }()
    
    static let today: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "'Today'"
        return formatter
    }()
    
    static let monthYear: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }()
    
    static let weekdayMonthDay: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter
    }()
    
    static let fullDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter
    }()
}

private struct HistoryDateSelection: Identifiable {
    let date: Date
    
    var id: Date {
        Calendar.current.startOfDay(for: date)
    }
}

// MARK: - Workout Stats Calculator

struct WorkoutStats: Equatable {
    let totalWorkouts: Int
    let currentStreak: Int
    let longestStreak: Int
    let thisWeekCount: Int
    let thisMonthCount: Int
    let averagePerWeek: Double
    
    // Cache key to avoid recalculation
    private static var lastHistoryCount: Int = -1
    private static var lastHistoryHash: Int = 0
    private static var cachedStats: WorkoutStats?
    
    static func calculate(from history: [WorkoutHistory]) -> WorkoutStats {
        // Quick cache check based on count and hash
        let historyHash = history.map { $0.date.timeIntervalSince1970 }.hashValue
        if history.count == lastHistoryCount && historyHash == lastHistoryHash, let cached = cachedStats {
            return cached
        }
        
        let stats = performCalculation(from: history)
        
        // Update cache
        lastHistoryCount = history.count
        lastHistoryHash = historyHash
        cachedStats = stats
        
        return stats
    }
    
    private static func performCalculation(from history: [WorkoutHistory]) -> WorkoutStats {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // Sort dates
        let sortedDates = history.map { calendar.startOfDay(for: $0.date) }.sorted()
        let uniqueDates = Array(Set(sortedDates)).sorted()
        
        // Total workouts
        let totalWorkouts = uniqueDates.count
        
        // Current streak
        var currentStreak = 0
        var checkDate = today
        
        // Check if worked out today or yesterday (allow for grace period)
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        let hasRecentWorkout = uniqueDates.contains(today) || uniqueDates.contains(yesterday)
        
        if hasRecentWorkout {
            // Start counting from the most recent workout day
            let startDate = uniqueDates.contains(today) ? today : yesterday
            checkDate = startDate
            
            while uniqueDates.contains(checkDate) {
                currentStreak += 1
                guard let previousDay = calendar.date(byAdding: .day, value: -1, to: checkDate) else { break }
                checkDate = previousDay
            }
        }
        
        // Longest streak
        var longestStreak = 0
        var tempStreak = 0
        var previousDate: Date?
        
        for date in uniqueDates {
            if let prev = previousDate {
                let dayDiff = calendar.dateComponents([.day], from: prev, to: date).day ?? 0
                if dayDiff == 1 {
                    tempStreak += 1
                } else {
                    longestStreak = max(longestStreak, tempStreak)
                    tempStreak = 1
                }
            } else {
                tempStreak = 1
            }
            previousDate = date
        }
        longestStreak = max(longestStreak, tempStreak)
        
        // This week count
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today))!
        let thisWeekCount = uniqueDates.filter { $0 >= startOfWeek && $0 <= today }.count
        
        // This month count
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: today))!
        let thisMonthCount = uniqueDates.filter { $0 >= startOfMonth && $0 <= today }.count
        
        // Average per week (last 4 weeks)
        let fourWeeksAgo = calendar.date(byAdding: .day, value: -28, to: today)!
        let recentCount = uniqueDates.filter { $0 >= fourWeeksAgo && $0 <= today }.count
        let averagePerWeek = Double(recentCount) / 4.0
        
        return WorkoutStats(
            totalWorkouts: totalWorkouts,
            currentStreak: currentStreak,
            longestStreak: longestStreak,
            thisWeekCount: thisWeekCount,
            thisMonthCount: thisMonthCount,
            averagePerWeek: averagePerWeek
        )
    }
    
    // Clear cache when app goes to background or data changes significantly
    static func invalidateCache() {
        lastHistoryCount = -1
        lastHistoryHash = 0
        cachedStats = nil
    }
}

// MARK: - Home History Section (Compact for HomeView)

struct HomeHistorySection: View {
    @EnvironmentObject var userManager: UserManager
    @State private var showFullHistory = false
    
    private var stats: WorkoutStats {
        WorkoutStats.calculate(from: userManager.workoutHistory)
    }
    
    private var hasHistory: Bool {
        !userManager.workoutHistory.isEmpty
    }
    
    private var daysSinceLastWorkout: Int? {
        guard let lastDate = userManager.workoutHistory.map({ $0.date }).max() else { return nil }
        let calendar = Calendar.current
        let days = calendar.dateComponents([.day], from: calendar.startOfDay(for: lastDate), to: calendar.startOfDay(for: Date())).day ?? 0
        return days
    }
    
    private var motivationalMessage: String {
        if !hasHistory {
            return "Complete your first workout to start tracking!"
        }
        
        guard let days = daysSinceLastWorkout else { return "" }
        
        switch days {
        case 0:
            return "Great job today! Keep it up! 💪"
        case 1:
            return "Yesterday was strong! Ready for today?"
        case 2...3:
            return "Time to get back on track!"
        case 4...7:
            return "Your streak is waiting! Let's go! 🔥"
        default:
            return "Welcome back! Every day is a fresh start."
        }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "calendar.badge.clock")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(AppTheme.primaryColor)
                    Text("Workout History")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(AppTheme.textPrimaryColor)
                }
                
                Spacer()
                
                if hasHistory {
                    Button(action: { showFullHistory = true }) {
                        HStack(spacing: 4) {
                            Text("View All")
                                .font(.system(size: 14, weight: .semibold))
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .semibold))
                        }
                        .foregroundColor(AppTheme.primaryColor)
                    }
                }
            }
            
            if hasHistory {
                // Quick stats row
                HStack(spacing: 12) {
                    QuickStatCard(
                        value: "\(stats.currentStreak)",
                        label: "Day Streak",
                        icon: "flame.fill",
                        color: stats.currentStreak > 0 ? Color(hex: "F97316") : AppTheme.textSecondaryColor
                    )
                    
                    QuickStatCard(
                        value: "\(stats.thisWeekCount)",
                        label: "This Week",
                        icon: "calendar",
                        color: AppTheme.primaryColor
                    )
                    
                    QuickStatCard(
                        value: "\(stats.totalWorkouts)",
                        label: "Total",
                        icon: "checkmark.circle.fill",
                        color: Color(hex: "22C55E")
                    )
                }
                
                // Motivational message if needed
                if let days = daysSinceLastWorkout, days > 1 {
                    HStack(spacing: 8) {
                        Image(systemName: days > 3 ? "exclamationmark.circle.fill" : "info.circle.fill")
                            .font(.system(size: 14))
                            .foregroundColor(days > 3 ? Color(hex: "F97316") : AppTheme.primaryColor)
                        
                        Text(motivationalMessage)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(AppTheme.textSecondaryColor)
                        
                        Spacer()
                    }
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill((days > 3 ? Color(hex: "F97316") : AppTheme.primaryColor).opacity(0.08))
                    )
                }
                
                // Mini calendar (current week)
                MiniWeekCalendar(workoutHistory: userManager.workoutHistory)
                
            } else {
                // Empty state for new users
                VStack(spacing: 12) {
                    Image(systemName: "calendar.badge.plus")
                        .font(.system(size: 36))
                        .foregroundColor(AppTheme.primaryColor.opacity(0.5))
                    
                    Text("No workout history yet")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(AppTheme.textSecondaryColor)
                    
                    Text(motivationalMessage)
                        .font(.system(size: 13))
                        .foregroundColor(AppTheme.textSecondaryColor.opacity(0.8))
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(AppTheme.cardBackgroundColor)
                .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 4)
        )
        .sheet(isPresented: $showFullHistory) {
            FullWorkoutHistoryView()
                .environmentObject(userManager)
        }
    }
}

// MARK: - Quick Stat Card

struct QuickStatCard: View {
    let value: String
    let label: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(color)
                
                Text(value)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(AppTheme.textPrimaryColor)
            }
            
            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(AppTheme.textSecondaryColor)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(color.opacity(0.08))
        )
    }
}

// MARK: - Mini Week Calendar

struct MiniWeekCalendar: View {
    let workoutHistory: [WorkoutHistory]
    private let calendar = Calendar.current
    
    private var weekDays: [(date: Date, label: String)] {
        let today = Date()
        var days: [(Date, String)] = []
        
        for i in -6...0 {
            if let date = calendar.date(byAdding: .day, value: i, to: today) {
                // Use cached formatters instead of creating new ones
                let label = i == 0 
                    ? DateFormatters.today.string(from: date)
                    : DateFormatters.dayOfWeek.string(from: date)
                days.append((calendar.startOfDay(for: date), label))
            }
        }
        return days
    }
    
    private func hasWorkout(on date: Date) -> Bool {
        let normalizedDate = calendar.startOfDay(for: date)
        return workoutHistory.contains { calendar.startOfDay(for: $0.date) == normalizedDate }
    }
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(weekDays, id: \.date) { day in
                VStack(spacing: 6) {
                    Text(day.label)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(AppTheme.textSecondaryColor)
                    
                    ZStack {
                        Circle()
                            .fill(hasWorkout(on: day.date) ?
                                  LinearGradient(colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                                               startPoint: .topLeading, endPoint: .bottomTrailing) :
                                  LinearGradient(colors: [Color.gray.opacity(0.15)],
                                               startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 36, height: 36)
                        
                        if hasWorkout(on: day.date) {
                            Image(systemName: "checkmark")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                        } else {
                            Text("\(calendar.component(.day, from: day.date))")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(AppTheme.textSecondaryColor)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.top, 8)
    }
}

// MARK: - Full Workout History View

struct FullWorkoutHistoryView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var userManager: UserManager
    @State private var selectedMonth = Date()
    @State private var selectedHistoryDate: HistoryDateSelection?
    
    private var stats: WorkoutStats {
        WorkoutStats.calculate(from: userManager.workoutHistory)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Stats overview
                    StatsOverviewSection(stats: stats)
                    
                    // Full calendar
                    FullCalendarSection(
                        selectedMonth: $selectedMonth,
                        workoutHistory: userManager.workoutHistory,
                        onDateSelected: { date in
                            selectedHistoryDate = HistoryDateSelection(date: date)
                        }
                    )
                    
                    // Recent history list
                    RecentHistoryList(history: userManager.workoutHistory)
                }
                .padding(20)
                .padding(.bottom, 40)
            }
            .background(AppTheme.backgroundColor.ignoresSafeArea())
            .navigationTitle("Workout History")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .fontWeight(.semibold)
                }
            }
            .sheet(item: $selectedHistoryDate) { selection in
                WorkoutHistoryDetailView(date: selection.date)
                    .environmentObject(userManager)
            }
        }
    }
}

// MARK: - Stats Overview Section

struct StatsOverviewSection: View {
    let stats: WorkoutStats
    
    var body: some View {
        VStack(spacing: 16) {
            // Main streak display
            HStack(spacing: 20) {
                // Current streak (prominent)
                VStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: stats.currentStreak > 0 ?
                                        [Color(hex: "F97316"), Color(hex: "EF4444")] :
                                        [Color.gray.opacity(0.2)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 80, height: 80)
                            .shadow(color: stats.currentStreak > 0 ? Color(hex: "F97316").opacity(0.4) : Color.clear,
                                   radius: 12, x: 0, y: 6)
                        
                        VStack(spacing: 2) {
                            Text("\(stats.currentStreak)")
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            
                            Image(systemName: "flame.fill")
                                .font(.system(size: 14))
                                .foregroundColor(.white.opacity(0.9))
                        }
                    }
                    
                    Text("Current Streak")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(AppTheme.textSecondaryColor)
                }
                
                // Other stats
                VStack(spacing: 12) {
                    StatRow(icon: "trophy.fill", label: "Best Streak", value: "\(stats.longestStreak) days", color: Color(hex: "EAB308"))
                    StatRow(icon: "calendar", label: "This Month", value: "\(stats.thisMonthCount) workouts", color: AppTheme.primaryColor)
                    StatRow(icon: "chart.line.uptrend.xyaxis", label: "Weekly Avg", value: String(format: "%.1f", stats.averagePerWeek), color: AppTheme.secondaryColor)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(AppTheme.cardBackgroundColor)
                .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 4)
        )
    }
}

struct StatRow: View {
    let icon: String
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(color)
                .frame(width: 20)
            
            Text(label)
                .font(.system(size: 14))
                .foregroundColor(AppTheme.textSecondaryColor)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(AppTheme.textPrimaryColor)
        }
    }
}

// MARK: - Full Calendar Section

struct FullCalendarSection: View {
    @Binding var selectedMonth: Date
    let workoutHistory: [WorkoutHistory]
    let onDateSelected: (Date) -> Void
    
    private let calendar = Calendar.current
    private let daysOfWeek = ["S", "M", "T", "W", "T", "F", "S"]
    
    var body: some View {
        VStack(spacing: 16) {
            // Month navigation
            HStack {
                Button {
                    withAnimation(.spring(response: 0.3)) {
                        selectedMonth = calendar.date(byAdding: .month, value: -1, to: selectedMonth) ?? selectedMonth
                    }
                } label: {
                    Image(systemName: "chevron.left.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(AppTheme.primaryColor)
                }
                
                Spacer()
                
                Text(DateFormatters.monthYear.string(from: selectedMonth))
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(AppTheme.textPrimaryColor)
                
                Spacer()
                
                Button {
                    withAnimation(.spring(response: 0.3)) {
                        selectedMonth = calendar.date(byAdding: .month, value: 1, to: selectedMonth) ?? selectedMonth
                    }
                } label: {
                    Image(systemName: "chevron.right.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(AppTheme.primaryColor)
                }
            }
            
            // Day labels
            HStack {
                ForEach(daysOfWeek, id: \.self) { day in
                    Text(day)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(AppTheme.textSecondaryColor)
                        .frame(maxWidth: .infinity)
                }
            }
            
            // Calendar grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 7), spacing: 8) {
                ForEach(fetchDaysInMonth(), id: \.self) { day in
                    if let dateValue = day {
                        CalendarDayCell(
                            date: dateValue,
                            hasWorkout: hasWorkout(on: dateValue),
                            isToday: calendar.isDateInToday(dateValue),
                            onTap: { onDateSelected(dateValue) }
                        )
                    } else {
                        Color.clear
                            .frame(height: 44)
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(AppTheme.cardBackgroundColor)
                .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 4)
        )
    }
    
    private func fetchDaysInMonth() -> [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: selectedMonth) else { return [] }
        
        let firstDayOfMonth = monthInterval.start
        let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth)
        
        var days: [Date?] = Array(repeating: nil, count: firstWeekday - 1)
        
        guard let range = calendar.range(of: .day, in: .month, for: selectedMonth) else { return days }
        
        let year = calendar.component(.year, from: selectedMonth)
        let month = calendar.component(.month, from: selectedMonth)
        
        days += range.compactMap { day -> Date? in
            calendar.date(from: DateComponents(year: year, month: month, day: day))
        }
        
        return days
    }
    
    private func hasWorkout(on date: Date) -> Bool {
        let normalizedDate = calendar.startOfDay(for: date)
        return workoutHistory.contains { calendar.startOfDay(for: $0.date) == normalizedDate }
    }
}

struct CalendarDayCell: View {
    let date: Date
    let hasWorkout: Bool
    let isToday: Bool
    let onTap: () -> Void
    
    private var dayNumber: Int {
        Calendar.current.component(.day, from: date)
    }
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                if hasWorkout {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(
                            LinearGradient(
                                colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: AppTheme.primaryColor.opacity(0.3), radius: 4, x: 0, y: 2)
                } else {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.gray.opacity(0.08))
                }
                
                Text("\(dayNumber)")
                    .font(.system(size: 15, weight: isToday ? .bold : .medium))
                    .foregroundColor(hasWorkout ? .white : AppTheme.textPrimaryColor)
                
                if isToday {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(AppTheme.primaryColor, lineWidth: 2)
                }
            }
            .frame(height: 44)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Recent History List

struct RecentHistoryList: View {
    let history: [WorkoutHistory]
    
    private var recentHistory: [WorkoutHistory] {
        Array(history.sorted { $0.date > $1.date }.prefix(10))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recent Workouts")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(AppTheme.textPrimaryColor)
            
            if recentHistory.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "calendar.badge.exclamationmark")
                        .font(.system(size: 40))
                        .foregroundColor(AppTheme.textSecondaryColor.opacity(0.5))
                    
                    Text("No workouts yet")
                        .font(.system(size: 15))
                        .foregroundColor(AppTheme.textSecondaryColor)
                    
                    Text("Complete your first workout to start tracking!")
                        .font(.system(size: 13))
                        .foregroundColor(AppTheme.textSecondaryColor.opacity(0.7))
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 30)
            } else {
                VStack(spacing: 10) {
                    ForEach(recentHistory) { item in
                        HStack(spacing: 14) {
                            // Date circle
                            ZStack {
                                Circle()
                                    .fill(AppTheme.primaryColor.opacity(0.12))
                                    .frame(width: 44, height: 44)
                                
                                Image(systemName: "checkmark")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(AppTheme.primaryColor)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(item.workoutDay)
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(AppTheme.textPrimaryColor)
                                
                                Text(DateFormatters.weekdayMonthDay.string(from: item.date))
                                    .font(.system(size: 13))
                                    .foregroundColor(AppTheme.textSecondaryColor)
                            }
                            
                            Spacer()
                            
                            Text(item.workoutFocus)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(AppTheme.primaryColor)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(AppTheme.primaryColor.opacity(0.1))
                                .cornerRadius(8)
                        }
                        .padding(14)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(AppTheme.cardBackgroundColor)
                                .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
                        )
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(AppTheme.cardBackgroundColor)
                .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 4)
        )
    }
}

// MARK: - Legacy Views (keeping for compatibility)

struct HomeHistoryView: View {
    @EnvironmentObject var userManager: UserManager
    @State private var date = Date()
    @State private var selectedHistoryDate: HistoryDateSelection?

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text(DateFormatters.monthYear.string(from: date))
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(AppTheme.textPrimaryColor)
                Spacer()
                
                Button(action: {
                    withAnimation {
                        self.date = Calendar.current.date(byAdding: .month, value: -1, to: self.date) ?? self.date
                    }
                }) {
                    Image(systemName: "chevron.left.circle.fill")
                        .foregroundColor(AppTheme.primaryColor)
                        .font(.title3)
                }
                
                Button(action: {
                    withAnimation {
                        self.date = Calendar.current.date(byAdding: .month, value: 1, to: self.date) ?? self.date
                    }
                }) {
                    Image(systemName: "chevron.right.circle.fill")
                        .foregroundColor(AppTheme.primaryColor)
                        .font(.title3)
                }
            }

            ContributionCalendarView(
                date: $date,
                workoutHistory: userManager.workoutHistory,
                onDateSelected: { selectedDate in
                    self.selectedHistoryDate = HistoryDateSelection(date: selectedDate)
                }
            )
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(AppTheme.cardBackgroundColor)
                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
        )
        .sheet(item: $selectedHistoryDate) { selection in
            WorkoutHistoryDetailView(date: selection.date)
                .environmentObject(userManager)
        }
    }
}

// MARK: - Contribution Calendar View

struct ContributionCalendarView: View {
    @Binding var date: Date
    let workoutHistory: [WorkoutHistory]
    let onDateSelected: (Date) -> Void
    
    private let calendar = Calendar.current
    private let daysOfWeek = [
        (0, "S"), (1, "M"), (2, "T"), (3, "W"), (4, "T"), (5, "F"), (6, "S")
    ]
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                ForEach(daysOfWeek, id: \.0) { index, day in
                    Text(day)
                        .frame(maxWidth: .infinity)
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundColor(AppTheme.textSecondaryColor)
                }
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 7), spacing: 4) {
                ForEach(Array(fetchDaysInMonth().enumerated()), id: \.offset) { index, day in
                    if let dateValue = day {
                        ContributionDayCell(
                            date: dateValue,
                            hasWorkout: getIntensityForDate(dateValue) == 1,
                            isToday: calendar.isDateInToday(dateValue),
                            onTap: { onDateSelected(dateValue) }
                        )
                    } else {
                        Rectangle()
                            .fill(Color.clear)
                            .frame(height: 32)
                    }
                }
            }
        }
        .id(workoutHistory.count)
    }

    private func fetchDaysInMonth() -> [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: date) else { return [] }
        
        let firstDayOfMonth = monthInterval.start
        let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth)
        
        var days: [Date?] = Array(repeating: nil, count: firstWeekday - 1)
        
        guard let range = calendar.range(of: .day, in: .month, for: date) else { return days }
        
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        
        days += range.compactMap { day -> Date? in
            calendar.date(from: DateComponents(year: year, month: month, day: day))
        }
        
        return days
    }
    
    private func getIntensityForDate(_ date: Date) -> Int {
        let normalizedDate = calendar.startOfDay(for: date)
        let hasWorkout = workoutHistory.contains { history in
            let normalizedHistoryDate = calendar.startOfDay(for: history.date)
            return normalizedHistoryDate == normalizedDate
        }
        return hasWorkout ? 1 : 0
    }
}

// MARK: - Contribution Day Cell

struct ContributionDayCell: View {
    let date: Date
    let hasWorkout: Bool
    let isToday: Bool
    let onTap: () -> Void
    
    private var dayNumber: Int {
        Calendar.current.component(.day, from: date)
    }
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                RoundedRectangle(cornerRadius: 6)
                    .fill(hasWorkout ?
                          LinearGradient(colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                                        startPoint: .topLeading, endPoint: .bottomTrailing) :
                          LinearGradient(colors: [Color.gray.opacity(0.1)],
                                        startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(height: 32)
                    .shadow(color: hasWorkout ? AppTheme.primaryColor.opacity(0.3) : Color.clear,
                           radius: hasWorkout ? 4 : 0, x: 0, y: 2)
                
                Text("\(dayNumber)")
                    .font(.system(size: 11, weight: isToday ? .bold : .regular))
                    .foregroundColor(hasWorkout ? .white : AppTheme.textPrimaryColor)
                
                if isToday {
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(AppTheme.primaryColor, lineWidth: 2)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Workout History Detail View

struct WorkoutHistoryDetailView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var userManager: UserManager
    let date: Date
    
    private var workoutHistory: WorkoutHistory? {
        let calendar = Calendar.current
        let normalizedDate = calendar.startOfDay(for: date)
        return userManager.workoutHistory.first { history in
            calendar.startOfDay(for: history.date) == normalizedDate
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    if let history = workoutHistory {
                        // Success header
                        VStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [Color(hex: "22C55E"), Color(hex: "16A34A")],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 70, height: 70)
                                    .shadow(color: Color(hex: "22C55E").opacity(0.4), radius: 12, x: 0, y: 6)
                                
                                Image(systemName: "checkmark")
                                    .font(.system(size: 30, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            
                            VStack(spacing: 6) {
                                Text("Workout Complete!")
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundColor(AppTheme.textPrimaryColor)
                                
                                Text(DateFormatters.fullDate.string(from: date))
                                    .font(.system(size: 15))
                                    .foregroundColor(AppTheme.textSecondaryColor)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 24)
                        
                        // Workout details
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Workout Details")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(AppTheme.textPrimaryColor)
                            
                            VStack(spacing: 12) {
                                DetailRow(label: "Day", value: history.workoutDay)
                                Divider()
                                DetailRow(label: "Focus", value: history.workoutFocus)
                            }
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(AppTheme.cardBackgroundColor)
                                    .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
                            )
                        }
                        
                        // Exercises if available
                        if let workoutId = history.workoutId,
                           let workout = userManager.workouts.first(where: { $0.id == workoutId }) {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Exercises Completed")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(AppTheme.textPrimaryColor)
                                
                                VStack(spacing: 10) {
                                    ForEach(workout.exercises) { exercise in
                                        HStack(spacing: 12) {
                                            Image(systemName: "checkmark.circle.fill")
                                                .font(.system(size: 18))
                                                .foregroundColor(Color(hex: "22C55E"))
                                            
                                            VStack(alignment: .leading, spacing: 2) {
                                                Text(exercise.name)
                                                    .font(.system(size: 15, weight: .medium))
                                                    .foregroundColor(AppTheme.textPrimaryColor)
                                                
                                                Text("\(exercise.sets) sets × \(exercise.reps)")
                                                    .font(.system(size: 13))
                                                    .foregroundColor(AppTheme.textSecondaryColor)
                                            }
                                            
                                            Spacer()
                                        }
                                        .padding(12)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(Color(hex: "22C55E").opacity(0.08))
                                        )
                                    }
                                }
                            }
                        }
                    } else {
                        // No workout state
                        VStack(spacing: 20) {
                            Image(systemName: "calendar.badge.exclamationmark")
                                .font(.system(size: 60))
                                .foregroundColor(AppTheme.textSecondaryColor.opacity(0.4))
                            
                            VStack(spacing: 8) {
                                Text("Rest Day")
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundColor(AppTheme.textPrimaryColor)
                                
                                Text("No workout was recorded on this day")
                                    .font(.system(size: 15))
                                    .foregroundColor(AppTheme.textSecondaryColor)
                                    .multilineTextAlignment(.center)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 60)
                    }
                }
                .padding(20)
            }
            .background(AppTheme.backgroundColor.ignoresSafeArea())
            .navigationTitle("Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .fontWeight(.semibold)
                }
            }
        }
    }
}

struct DetailRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 15))
                .foregroundColor(AppTheme.textSecondaryColor)
            Spacer()
            Text(value)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(AppTheme.textPrimaryColor)
        }
    }
}

struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(AppTheme.textSecondaryColor)
            Spacer()
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(AppTheme.textPrimaryColor)
        }
    }
}

// MARK: - Preview

#if DEBUG
struct HomeHistorySection_Previews: PreviewProvider {
    static var previews: some View {
        HomeHistorySection()
            .environmentObject(UserManager())
            .padding()
            .background(AppTheme.backgroundColor)
    }
}
#endif
