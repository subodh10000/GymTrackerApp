import SwiftUI

struct NutritionView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    header
                    macroGoals
                    nutritionTips
                    foodsToLimit
                }
                .padding()
                .background(AppTheme.backgroundColor.edgesIgnoringSafeArea(.all))
            }
            .navigationTitle("Nutrition")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var header: some View {
        ZStack(alignment: .bottom) {
            Rectangle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [Color(hex: "FF5A5F"), Color(hex: "FF9A8B")]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(height: 160)

            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Nutrition Plan")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)

                    Text("Fuel your performance")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.85))
                }

                Spacer()

                Image(systemName: "leaf.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding(20)
        }
    }

    private var macroGoals: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Daily Nutrition Goals")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(AppTheme.textPrimaryColor)

            HStack(spacing: 12) {
                MacroCard(
                    icon: "figure.strengthtraining.traditional",
                    color: AppTheme.primaryColor,
                    value: "145g",
                    name: "Protein"
                )

                MacroCard(
                    icon: "flame.fill",
                    color: AppTheme.accentColor,
                    value: "Slight Deficit",
                    name: "Calories"
                )

                MacroCard(
                    icon: "drop.fill",
                    color: Color(hex: "4EA8DE"),
                    value: "3L+",
                    name: "Water"
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(AppTheme.cardBackgroundColor)
                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
        )
    }

    private var nutritionTips: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Nutrition Tips")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(AppTheme.textPrimaryColor)

            VStack(spacing: 15) {
                EnhancedNutritionTip(
                    title: "Protein Sources",
                    description: "Focus on lean meats, eggs, fish, and plant-based proteins like beans and lentils.",
                    icon: "fish.fill",
                    color: Color(hex: "F9A826")
                )

                EnhancedNutritionTip(
                    title: "Carbohydrates",
                    description: "Choose complex carbs like oats, brown rice, and sweet potatoes over processed options.",
                    icon: "leaf.fill",
                    color: Color(hex: "4FC08D")
                )

                EnhancedNutritionTip(
                    title: "Stay Hydrated",
                    description: "Drink water consistently throughout the day, especially before and after workouts.",
                    icon: "drop.fill",
                    color: Color(hex: "4EA8DE")
                )

                EnhancedNutritionTip(
                    title: "Optional Supplements",
                    description: "Consider creatine (5g/day), whey protein, and a multivitamin to support your goals.",
                    icon: "pill.fill",
                    color: AppTheme.primaryColor
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(AppTheme.cardBackgroundColor)
                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
        )
    }

    private var foodsToLimit: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Foods to Limit")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(AppTheme.textPrimaryColor)

            VStack(spacing: 12) {
                FoodToAvoidRow(text: "Processed sugar and sweets")
                FoodToAvoidRow(text: "Highly processed foods")
                FoodToAvoidRow(text: "Excessive alcohol")
                FoodToAvoidRow(text: "Fried and fast foods")
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

struct MacroCard: View {
    let icon: String
    let color: Color
    let value: String
    let name: String

    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 50, height: 50)

                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundColor(color)
            }

            Text(value)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(AppTheme.textPrimaryColor)

            Text(name)
                .font(.caption)
                .foregroundColor(AppTheme.textSecondaryColor)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 15)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.gray.opacity(0.05))
        )
    }
}

struct EnhancedNutritionTip: View {
    let title: String
    let description: String
    let icon: String
    let color: Color

    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 40, height: 40)

                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(color)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(AppTheme.textPrimaryColor)

                Text(description)
                    .font(.subheadline)
                    .foregroundColor(AppTheme.textSecondaryColor)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.05))
        )
    }
}

struct FoodToAvoidRow: View {
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "xmark.circle.fill")
                .foregroundColor(AppTheme.accentColor)
                .font(.system(size: 16))

            Text(text)
                .font(.subheadline)
                .foregroundColor(AppTheme.textPrimaryColor)

            Spacer()
        }
        .padding(.vertical, 8)
    }
}

#if DEBUG
struct NutritionView_Previews: PreviewProvider {
    static var previews: some View {
        NutritionView()
    }
}
#endif

