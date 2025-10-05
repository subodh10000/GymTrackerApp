//
//  CommitmentView.swift
//  GymTrackerApp
//
//  Created by Subodh Kathayat on 10/5/25.
//


import SwiftUI

struct CommitmentView: View {
    @EnvironmentObject var userManager: UserManager

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("Weekly Commitment")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(AppTheme.textPrimaryColor)
                Spacer()
                
                let rank = userManager.getCurrentRank()
                HStack {
                    Text(rank.icon)
                        .font(.title2)
                    Text(rank.title)
                        .font(.headline)
                        .foregroundColor(AppTheme.textSecondaryColor)
                }
            }

            // Commitment Grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                // Ensure we only show 7 days, even if there are more workouts
                ForEach(0..<min(userManager.workouts.count, 7), id: \.self) { index in
                    let workout = userManager.workouts[index]
                    let isCompleted = !workout.exercises.isEmpty && !workout.exercises.contains(where: { !$0.isCompleted })
                    
                    VStack(spacing: 4) {
                        Text(String(workout.day.prefix(1)))
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.gray)
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(isCompleted ? Color.green.opacity(0.7) : Color.gray.opacity(0.2))
                            .frame(height: 35)
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(AppTheme.cardBackgroundColor)
                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
        )
    }
}