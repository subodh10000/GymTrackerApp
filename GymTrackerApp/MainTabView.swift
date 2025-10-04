import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }

            WorkoutListView()
                .tabItem {
                    Image(systemName: "dumbbell.fill")
                    Text("Workouts")
                }

            IntervalTrainingView()
                .tabItem {
                    Image(systemName: "stopwatch.fill")
                    Text("Intervals")
                }
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(UserManager())
}
