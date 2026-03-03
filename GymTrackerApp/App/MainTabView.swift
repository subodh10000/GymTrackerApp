//
//  MainTabView.swift
//  GymTrackerApp
//
//  Created by Subodh Kathayat on 5/19/25.
//


import SwiftUI
import UIKit

struct MainTabView: View {
    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(AppTheme.cardBackgroundColor)
        appearance.shadowColor = UIColor.black.withAlphaComponent(0.08)
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
        UITabBar.appearance().isTranslucent = false
    }
    
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
            
            ChallengeView()
                            .tabItem {
                                Image(systemName: "flame.fill")
                                Text("Challenges")
                            }

            IntervalTrainingView()
                .tabItem {
                    Image(systemName: "stopwatch.fill")
                    Text("Intervals")
                }
            
            ProfileView()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
        }
        .toolbarBackground(AppTheme.cardBackgroundColor, for: .tabBar)
        .toolbarBackground(.visible, for: .tabBar)
    }
}

#Preview {
    MainTabView()
        .environmentObject(UserManager())
}
