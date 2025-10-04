import SwiftUI
import Lottie // Make sure you have DotLottie integrated properly

struct CoffeeDateView: View {
    @State private var showAnimation = false
    @State private var isAccepted = false

    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.pink.opacity(0.15))
                    .frame(height: 140)
                    .shadow(color: Color.pink.opacity(0.3), radius: 5, x: 0, y: 2)

                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Can I take you on a coffee date?")
                            .font(.headline)
                            .foregroundColor(AppTheme.textPrimaryColor)

                        if isAccepted {
                            Text("Yayy! ☕ It’s a date 💖")
                                .font(.subheadline)
                                .foregroundColor(.green)
                        } else {
                            Button("Yes ☕️") {
                                withAnimation(.spring()) {
                                    showAnimation = true
                                    isAccepted = true
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                                    showAnimation = false
                                }
                            }
                            .font(.subheadline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 6)
                            .background(Color.pink)
                            .cornerRadius(10)
                        }
                    }

                    Spacer()

                    if showAnimation {
                        AnimationView()
                            .frame(width: 80, height: 80)
                    } else {
                        Image(systemName: "cup.and.saucer.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 36, height: 36)
                            .foregroundColor(.pink)
                            .opacity(0.8)
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical, 10)
    }
}

struct AnimationView: View {
    var body: some View {
        DotLottieAnimation(
            webURL: "https://lottie.host/c6c5c9a3-15c0-49eb-8083-e009a2346eba/9yVfubnXWV.lottie"
        ).view()
    }
}
