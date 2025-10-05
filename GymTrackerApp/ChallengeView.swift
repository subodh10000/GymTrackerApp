// In ChallengeView.swift
import SwiftUI

struct ChallengeView: View {
    // Placeholder challenges
    let challenges = [
        ("90 Day Summer Challenge", "Get in the best shape of your life this summer.", "summit"),
        ("21 Day Hard Challenge", "Test your mental and physical fortitude.", "winter"),
        ("Winter Arc", "Build a strong foundation during the cold months.", "strength")
    ]

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 15) {
                    ForEach(challenges, id: \.0) { name, description, imageName in
                        NavigationLink(destination: Text("\(name) Detail View - Coming Soon!")) {
                            ChallengeCard(title: name, description: description, imageName: imageName)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Challenges")
        }
    }
}

// A helper view for the challenge card UI
struct ChallengeCard: View {
    let title: String
    let description: String
    let imageName: String

    var body: some View {
        ZStack {
            Image(imageName) // Assuming you'll add images with these names to your assets
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 180)
                .overlay(
                    LinearGradient(colors: [.black.opacity(0.8), .clear], startPoint: .bottom, endPoint: .center)
                )

            VStack(alignment: .leading) {
                Spacer()
                Text(title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.9))
                    .lineLimit(2)
            }
            .padding()
        }
        .frame(height: 180)
        .cornerRadius(20)
        .shadow(radius: 5)
    }
}