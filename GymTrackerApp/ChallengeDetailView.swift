//
//  Participant.swift
//  GymTrackerApp
//
//  Created by Subodh Kathayat on 10/5/25.
//


import SwiftUI

// --- 1. Define a model for a participant (for hardcoded data) ---
struct Participant: Identifiable {
    var id = UUID()
    let name: String
    let progress: Double // Progress from 0.0 to 1.0
}

// --- 2. Create the main detail view ---
struct ChallengeDetailView: View {
    let challenge: Challenge
    @State private var hasJoined = false

    // --- Hardcoded participant data ---
    let participants = [
        Participant(name: "David", progress: 0.85),
        Participant(name: "Sarah", progress: 0.72),
        Participant(name: "Mike", progress: 0.65),
        Participant(name: "Jenna", progress: 0.50)
    ]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // --- Header Image ---
                Image(challenge.imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 250)
                    .clipped()
                
                // --- Challenge Info & Join Button ---
                VStack(alignment: .leading, spacing: 15) {
                    Text(challenge.name)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text(challenge.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Button(action: {
                        hasJoined.toggle()
                    }) {
                        Text(hasJoined ? "You're In!" : "Join Challenge")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(hasJoined ? Color.gray : Color.blue)
                            .cornerRadius(12)
                    }
                    .animation(.easeInOut, value: hasJoined)
                    
                }
                .padding(.horizontal)
                
                Divider()

                // --- My Progress Section ---
                VStack(alignment: .leading, spacing: 10) {
                    Text("My Progress")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    VStack {
                        ProgressView(value: 0.45) // Hardcoded progress for "You"
                        Text("Days Completed: 40 / 90")
                            .font(.caption)
                    }
                }
                .padding(.horizontal)

                Divider()

                // --- Participants Section ---
                VStack(alignment: .leading, spacing: 10) {
                    Text("Participants")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    ForEach(participants) { participant in
                        ParticipantRowView(participant: participant)
                    }
                }
                .padding(.horizontal)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .ignoresSafeArea(edges: .top)
    }
}

// --- 3. A helper view for each row in the participants list ---
struct ParticipantRowView: View {
    let participant: Participant
    
    var body: some View {
        HStack {
            Image(systemName: "person.circle.fill")
                .font(.largeTitle)
                .foregroundColor(.gray.opacity(0.5))
            
            VStack(alignment: .leading) {
                Text(participant.name)
                    .fontWeight(.semibold)
                ProgressView(value: participant.progress)
                    .tint(.green)
            }
            
            Spacer()
            
            Text("\(Int(participant.progress * 100))%")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 5)
    }
}