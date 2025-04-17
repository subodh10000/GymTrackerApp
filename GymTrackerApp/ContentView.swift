import SwiftUI

struct ContentView: View {
    @EnvironmentObject var userManager: UserManager

    var body: some View {
        Group {
            if userManager.hasCompletedOnboarding {
                MainTabView()
            } else {
                OnboardingView()
            }
        }
        .onAppear {
            NotificationManager.shared.requestAuthorization(userManager: userManager)
        }
    }
}
