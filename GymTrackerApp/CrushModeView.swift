import SwiftUI

// --- Data ---
private enum CrushModeData {
    static let bunnyImageNames = ["bunny", "bunny_dumbbell", "bunny_pushup"]
    static let repeatedBunnyImages = Array(repeating: bunnyImageNames, count: 4).flatMap { $0 }

    static let motivationalMessages = [
        "She’s not gonna fall for a guy who skips leg day. Squat like you mean it 😤🍑",
        "Biceps don’t text back. You do. But first, curl them up 💬💪",
        "Push that weight like it’s her luggage at the airport ✈️💼",
        "Abs aren't built in the DMs. Now plank, lover boy 😘",
        "Send her '😳' after this set. She deserves it. So do you 💌",
        "You’re 3 reps away from looking like her dream and her dad's nightmare 😈",
        "Do it for the pump. Do it for the ‘wow’ when she sees you 🤯❤️",
        "Imagine her clapping when you hit that PR. Go make it real 🥹👏",
        "Don’t let your crush date a cardio bunny. Be her beast 🐰🦍",
        "Text her after this set: ‘I just did 10 for you.’ She’ll marry you 💍"
    ]

    static let sadQuotes = [
        "She left you on read... but gym won’t 💔",
        "Her love faded... but the pre-workout never does 🥲💥",
        "She stopped replying... but the weights still wait 😞🏋️",
        "She ghosted you... but you’ll never ghost leg day 👻🦵",
        "She said 'it’s not you'... but the gym said 'it’s always been you' 😔❤️‍🔥",
        "You lost her... but you found your gains 🏋️‍♂️🫀",
        "She broke your heart... but your bench press stayed loyal 💘➡️💪",
        "Her hugs are gone... but gym towels are forever 🧼😩",
        "She’s with Chad now... but you’re with the grind now 😤🔥",
        "She deleted your pics... but gym mirrors never lie 🪞😭",
        "She took your hoodie... but she can’t take your PRs 🥺🏆",
        "Your love story ended... but your cutting phase just began ✂️💔",
        "She blocked you... but the pump is still unblocked 🧱💉"
    ]
}

// --- Constants ---
private enum CrushModeConstants {
    static let swipeThreshold: CGFloat = 120
    static let cardHeight: CGFloat = 280
    static let heartSize: CGFloat = 80
    static let heartAnimationDuration: Double = 0.4
    static let heartTapScale: CGFloat = 1.3
    static let cardSwipeAnimationDuration: Double = 0.3
    static let confettiCount = 20
    static let rainDropCount = 100
    static let cryingBunnySize: CGFloat = 150
}

struct CrushModeView: View {
    @Environment(\.dismiss) var dismiss
    @State private var showConfetti = true
    @State private var currentCardIndex = 0
    @State private var cardOffset: CGSize = .zero
    @State private var isHeartBroken = false
    @State private var heartScale: CGFloat = 1.0
    @State private var sadQuoteIndex = 0

    private let bunnyImages = CrushModeData.repeatedBunnyImages
    private let messages = CrushModeData.motivationalMessages
    private let sadQuotes = CrushModeData.sadQuotes

    var body: some View {
        ZStack {
            backgroundView
            VStack(spacing: 30) {
                if isHeartBroken {
                    heartbrokenStateView.transition(.opacity.combined(with: .scale(scale: 0.8)))
                } else {
                    cardStackView.transition(.opacity.combined(with: .scale(scale: 1.0)))
                }
                heartToggleButton
                actionButton
            }
            .padding()

            if showConfetti && !isHeartBroken {
                confettiOverlay
            }
        }
        .animation(.easeInOut(duration: 0.5), value: isHeartBroken)
    }

    private var backgroundView: some View {
        Group {
            if isHeartBroken {
                LinearGradient(colors: [Color.gray.opacity(0.6), Color.black.opacity(0.9)],
                               startPoint: .top, endPoint: .bottom)
            } else {
                LinearGradient(colors: [Color.pink.opacity(0.1), Color.white],
                               startPoint: .top, endPoint: .bottom)
            }
        }
        .ignoresSafeArea()
        .animation(.easeInOut(duration: 0.6), value: isHeartBroken)
    }

    private var cardStackView: some View {
        ZStack {
            ForEach(currentCardIndex..<min(currentCardIndex + 2, bunnyImages.count), id: \.self) { index in
                let isTopCard = (index == currentCardIndex)
                BunnyCard(imageName: bunnyImages[index])
                    .offset(x: isTopCard ? cardOffset.width : 0, y: isTopCard ? 0 : 10)
                    .rotationEffect(.degrees(isTopCard ? Double(cardOffset.width / 20) : 0))
                    .scaleEffect(isTopCard ? 1 : 0.9)
                    .animation(.spring(), value: isTopCard ? cardOffset : .zero)
                    .gesture(isTopCard ? dragGesture : nil)
            }
        }
        .frame(height: CrushModeConstants.cardHeight)
    }

    private var quoteTextView: some View {
        Text(isHeartBroken ? sadQuotes[sadQuoteIndex % sadQuotes.count] : messages[currentCardIndex % messages.count])
            .font(.system(size: 12, weight: .semibold))
            .foregroundColor(isHeartBroken ? .white.opacity(0.8) : .pink.opacity(0.9))
            .multilineTextAlignment(.center)
            .lineLimit(nil)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal, 30)
            .frame(maxWidth: .infinity)
            .animation(.easeInOut, value: isHeartBroken ? sadQuoteIndex : currentCardIndex)
    }


    private var heartToggleButton: some View {
        ZStack {
            if !isHeartBroken {
                HealingSpark()
            }
            Image(systemName: isHeartBroken ? "heart.slash.fill" : "heart.fill")
                .resizable()
                .scaledToFit()
                .frame(width: CrushModeConstants.heartSize, height: CrushModeConstants.heartSize)
                .foregroundColor(isHeartBroken ? .gray : .pink)
                .scaleEffect(heartScale)
                .animation(.spring(response: 0.4, dampingFraction: 0.6), value: heartScale)
                .animation(.easeInOut(duration: 0.6), value: isHeartBroken)
                .onTapGesture {
                    toggleHeartState()
                }
        }
    }

    private var actionButton: some View {
        Button {
            dismiss()
        } label: {
            Text(isHeartBroken ? "GYM is there. 😤" : "DONE")
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal, 30)
                .padding(.vertical, 12)
                .background(Capsule().fill(isHeartBroken ? Color.gray.opacity(0.8) : Color.pink))
                .shadow(color: .gray.opacity(0.5), radius: 5, x: 0, y: 2)
        }
        .animation(.easeInOut, value: isHeartBroken)
    }

    private var heartbrokenStateView: some View {
        ZStack {
            AnimatedCloudLayer().zIndex(0)
            LightningFlashView().zIndex(1)
            GeometryReader { geo in
                ForEach(0..<CrushModeConstants.rainDropCount, id: \.self) { _ in
                    RainDrop()
                        .position(
                            x: CGFloat.random(in: 0...geo.size.width),
                            y: CGFloat.random(in: -geo.size.height * 0.5...geo.size.height * 1.5)
                        )
                }
            }
            .clipped()
            .zIndex(2)

            VStack(spacing: 12) {
                Spacer()

                // 🐰 Crying bunny in gym
                Image("bunny_crying_gym")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 160)
                    .shadow(radius: 8)
                    .padding(.bottom, 10)

                // 💔 Sad quote
                Text(isHeartBroken ? sadQuotes[sadQuoteIndex % sadQuotes.count] : "")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 30)

                // 👆 Swipe gesture helper
                Text("Swipe here to see what she made you...")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
                    .padding(.top, 5)
                    .gesture(swipeSadQuoteGesture)

                Spacer()
            }
            .frame(height: CrushModeConstants.cardHeight)
            .zIndex(3)
        }
    }

    private var confettiOverlay: some View {
        ZStack {
            ForEach(0..<CrushModeConstants.confettiCount, id: \.self) { _ in
                HeartConfetti()
                    .frame(width: 20, height: 20)
                    .position(x: CGFloat.random(in: 50...UIScreen.main.bounds.width - 50),
                              y: CGFloat.random(in: -50...UIScreen.main.bounds.height + 50))
                    .rotationEffect(.degrees(Double.random(in: 0...360)))
                    .opacity(Double.random(in: 0.4...0.9))
            }
        }
        .allowsHitTesting(false)
    }

    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { gesture in
                cardOffset = gesture.translation
            }
            .onEnded { _ in
                if abs(cardOffset.width) > CrushModeConstants.swipeThreshold {
                    swipeCard()
                } else {
                    withAnimation(.spring()) {
                        cardOffset = .zero
                    }
                }
            }
    }

    private var swipeSadQuoteGesture: some Gesture {
        DragGesture(minimumDistance: 30, coordinateSpace: .local)
            .onEnded { _ in
                changeSadQuote()
            }
    }

    private func swipeCard() {
        let swipeDirectionMultiplier: CGFloat = (cardOffset.width > 0) ? 1 : -1
        let offscreenX = UIScreen.main.bounds.width * swipeDirectionMultiplier * 1.5

        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            cardOffset = CGSize(width: offscreenX, height: 0)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + CrushModeConstants.cardSwipeAnimationDuration) {
            currentCardIndex = (currentCardIndex + 1) % bunnyImages.count
            cardOffset = .zero
        }
    }

    private func toggleHeartState() {
        withAnimation(.easeInOut(duration: CrushModeConstants.heartAnimationDuration / 2)) {
            isHeartBroken.toggle()
            heartScale = CrushModeConstants.heartTapScale
        }
        withAnimation(.spring(response: 0.4, dampingFraction: 0.6).delay(CrushModeConstants.heartAnimationDuration / 2)) {
            heartScale = 1.0
        }
        if !isHeartBroken {
            sadQuoteIndex = 0
        }
    }

    private func changeSadQuote() {
        withAnimation {
            sadQuoteIndex += 1
        }
    }
}
// --- Helper Views (Mostly unchanged, but reviewed/cleaned) ---

// --- Helper Views (Mostly unchanged, but reviewed/cleaned) ---

struct HealingSpark: View {
    @State private var animate = false

    var body: some View {
        Circle()
            .stroke(
                LinearGradient(colors: [.pink.opacity(0.8), .white.opacity(0)], startPoint: .top, endPoint: .bottom),
                lineWidth: 2
            )
            .frame(width: CrushModeConstants.heartSize + 10, height: CrushModeConstants.heartSize + 10)
            .scaleEffect(animate ? 1.5 : 0.9)
            .opacity(animate ? 0 : 0.7)
            .animation(.easeOut(duration: 1.0), value: animate)
            .onAppear {
                animate = true
            }
    }
}

struct ProteinSplashView: View {
    @State private var animate = false

    var body: some View {
        VStack {
            if animate {
                Image("protein_splash")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 160)
                    .transition(.scale.combined(with: .opacity))
                    .offset(y: -20)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                animate = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation(.easeOut(duration: 0.5)) {
                    animate = false
                }
            }
        }
    }
}

struct AnimatedCloudLayer: View {
    @State private var xOffset: CGFloat = -30

    var body: some View {
        HStack(spacing: 60) {
            Image(systemName: "cloud.fill")
            Image(systemName: "cloud.sun.fill")
            Image(systemName: "cloud.fill")
            Image(systemName: "cloud.fill")
            Image(systemName: "cloud.sun.fill")
            Image(systemName: "cloud.fill")
        }
        .font(.system(size: 90))
        .foregroundColor(.white.opacity(0.25))
        .offset(x: xOffset)
        .animation(Animation.linear(duration: 10).repeatForever(autoreverses: true), value: xOffset) // 💨 faster
        .onAppear {
            xOffset = 30
        }
        .offset(y: -UIScreen.main.bounds.height * 0.3)
        .blur(radius: 2.0)
    }
}


struct BunnyCard: View {
    let imageName: String

    var body: some View {
        Image(imageName)
            .resizable()
            .scaledToFit()
            .background(Color.white)
            .cornerRadius(20)
            .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
    }
}

struct HeartConfetti: View {
    @State private var yOffset: CGFloat = -50
    @State private var rotation: Double = Double.random(in: -30...30)
    let animationDuration = Double.random(in: 3.5...6.5)
    let delay = Double.random(in: 0...0.5)

    var body: some View {
        Image(systemName: "heart.fill")
            .foregroundColor(.pink.opacity(Double.random(in: 0.6...1.0)))
            .rotationEffect(.degrees(rotation))
            .offset(y: yOffset)
            .onAppear {
                withAnimation(
                    .linear(duration: animationDuration)
                        .delay(delay)
                        .repeatForever(autoreverses: false)
                ) {
                    yOffset = UIScreen.main.bounds.height + 100
                    rotation += Double.random(in: -180...180)
                }
            }
    }
}

struct LightningFlashView: View {
    @State private var showFlash = false
    @State private var timer: Timer? = nil

    var body: some View {
        Rectangle()
            .fill(Color.white)
            .opacity(showFlash ? 0.4 : 0)
            .animation(.easeInOut(duration: 0.1), value: showFlash)
            .ignoresSafeArea()
            .onAppear(perform: startFlashing)
            .onDisappear(perform: stopFlashing)
    }

    private func startFlashing() {
        stopFlashing()
        scheduleNextFlash()
    }

    private func scheduleNextFlash() {
        timer = Timer.scheduledTimer(withTimeInterval: Double.random(in: 5...10), repeats: false) { _ in
            showFlash = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                showFlash = false
                scheduleNextFlash()
            }
        }
    }

    private func stopFlashing() {
        timer?.invalidate()
        timer = nil
    }
}

struct RainDrop: View {
    @State private var offsetY: CGFloat = -150
    let dropWidth: CGFloat = CGFloat.random(in: 1.4...2.2)
    let dropHeight: CGFloat = CGFloat.random(in: 14...20)
    let duration: Double = Double.random(in: 2.0...3.5)

    var body: some View {
        RoundedRectangle(cornerRadius: 1)
            .fill(Color.white.opacity(0.4))
            .frame(width: dropWidth, height: dropHeight)
            .offset(y: offsetY)
            .onAppear {
                withAnimation(
                    .easeOut(duration: duration)
                        .repeatForever(autoreverses: false)
                ) {
                    offsetY = UIScreen.main.bounds.height + 200
                }
            }
    }
}

#if DEBUG
struct CrushModeView_Previews: PreviewProvider {
    static var previews: some View {
        CrushModeView()
    }
}
#endif
