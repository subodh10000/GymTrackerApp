//
//  ContentView.swift
//  GymTrackerApp
//
//  Created by Subodh Kathayat on 4/16/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @EnvironmentObject var userManager: UserManager
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        Group {
            if userManager.hasCompletedOnboarding {
                MainTabView()
            } else {
                OnboardingView()
            }
        }
        .alert("Personalized Plan Ready", isPresented: $userManager.showPendingPlanPrompt) {
            Button("Not Now", role: .cancel) {
                userManager.dismissPendingPlanReplacement()
            }
            Button("Load Plan") {
                userManager.confirmPendingPlanReplacement()
            }
        } message: {
            Text("We generated a new AI workout plan based on your stats. Replace your current plan with the new one?")
        }
        .onAppear {
            // Set model context when view appears
            if userManager.modelContext == nil {
                userManager.setModelContext(modelContext)
            }
        }
    }
}

#Preview {
    ContentView()
}
