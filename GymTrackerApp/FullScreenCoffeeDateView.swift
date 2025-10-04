import SwiftUI

struct FullScreenCoffeeDateView: View {
    @State private var bounce = false
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            LinearGradient(colors: [Color.pink.opacity(0.6), .white], startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Text("You said YES!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.pink)

                Image(systemName: "cup.and.saucer.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 160, height: 160)
                    .foregroundColor(.brown)
                    .scaleEffect(bounce ? 1.1 : 0.9)
                    .animation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true), value: bounce)
                    .onAppear {
                        bounce = true
                    }

                Text("Coffee vibes loading... ☕️💞")
                    .font(.title3)
                    .foregroundColor(.gray)

                Button(action: {
                    dismiss()
                }) {
                    Text("Back to Reminders")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 10)
                        .background(Color.pink)
                        .cornerRadius(12)
                        .shadow(radius: 4)
                }
                .padding(.top, 30)
            }
        }
    }
}
