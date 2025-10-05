// In ChallengeView.swift
import SwiftUI

// --- 1. Define a simple model for our hardcoded data ---
struct Challenge {
    var id = UUID()
    let name: String
    let description: String
    let imageName: String // The name of an image in your Assets
}

// --- 2. Create the main view ---
struct ChallengeView: View {
    
    // --- Here is your hardcoded challenge data ---
    let challenges = [
        Challenge(name: "90 Day Summer Challenge", description: "Get in the best shape of your life this summer.", imageName: "gigachad"),
        Challenge(name: "21 Day Hard Challenge", description: "Test your mental and physical fortitude.", imageName: "zeus"),
        Challenge(name: "Winter Arc", description: "Build a strong foundation during the cold months.", imageName: "roman_bust")
    ]

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    ForEach(challenges, id: \.id) { challenge in
                        NavigationLink(destination: ChallengeDetailView(challenge: challenge)) {
                            ChallengeCard(challenge: challenge)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Challenges")
        }
    }
}

// --- 3. A helper view for the card UI ---
struct ChallengeCard: View {
    let challenge: Challenge

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // Background Image with a dark overlay
            Image(challenge.imageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 200)
                .overlay(
                    LinearGradient(
                        colors: [.black.opacity(0.7), .clear],
                        startPoint: .bottom,
                        endPoint: .center
                    )
                )

            // Text content
            VStack(alignment: .leading, spacing: 5) {
                Text(challenge.name)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text(challenge.description)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.9))
                    .lineLimit(2)
            }
            .padding()
        }
        .frame(height: 200)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.2), radius: 5, y: 3)
    }
}

// --- 4. Add a preview for easy designing ---
struct ChallengeView_Previews: PreviewProvider {
    static var previews: some View {
        ChallengeView()
    }
}
