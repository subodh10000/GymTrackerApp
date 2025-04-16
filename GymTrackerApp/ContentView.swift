//
//  ContentView.swift
//  GymTrackerApp
//
//  Created by Subodh Kathayat on 4/16/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var userManager: UserManager
    
    var body: some View {
        if userManager.hasCompletedOnboarding {
            MainTabView()
        } else {
            OnboardingView()
        }
    }
}

#Preview {
    ContentView()
}
