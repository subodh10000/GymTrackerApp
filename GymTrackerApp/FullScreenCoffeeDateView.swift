import SwiftUI

struct FullScreenCoffeeDateView: View {
    @Environment(\.dismiss) var dismiss
    @State private var animateHearts = false
    @State private var glow = false

    var body: some View {
        ZStack {
            // 🌸 Background gradient
            LinearGradient(colors: [Color.white, Color.pink.opacity(0.15)], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            VStack(spacing: 28) {
                Spacer()

                Text("You said YES!")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.pink)

                ZStack {
                    // 🌟 Glowing Aura
                    Circle()
                        .fill(Color.pink.opacity(0.2))
                        .frame(width: 260, height: 260)
                        .scaleEffect(glow ? 1.08 : 0.95)
                        .animation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: glow)

                    // ☕ Lottie coffee animation
                    LottieView(animationName: "coffeeDate", loopMode: .loop)
                        .frame(width: 200, height: 200)

                    // 💖 Floating hearts
                    ForEach(0..<8) { i in
                        FloatingHeart(offset: Double(i) * 50, delay: Double(i) * 0.3)
                    }
                }
                .padding(.vertical, 10)

                Spacer()

                Button(action: {
                    dismiss()
                }) {
                    Text("HI ")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 14)
                        .background(Color.pink)
                        .cornerRadius(14)
                        .shadow(radius: 4)
                }

                Spacer(minLength: 60)
            }
            .padding(.horizontal, 20)
            .onAppear {
                glow = true
                animateHearts = true
            }
        }
    }
}
struct FloatingHeart: View {
    var offset: Double
    var delay: Double

    @State private var animateUp = false
    @State private var opacity = 0.0
    private let heartSize: CGFloat = 24

    var body: some View {
        Image(systemName: "heart.fill")
            .resizable()
            .frame(width: heartSize, height: heartSize)
            .foregroundColor(.pink.opacity(0.7))
            .offset(x: CGFloat.random(in: -60...60), y: animateUp ? -220 : 0)
            .opacity(opacity)
            .onAppear {
                withAnimation(Animation.easeOut(duration: 2.5).delay(delay)) {
                    animateUp = true
                    opacity = 1
                }
            }
    }
}
