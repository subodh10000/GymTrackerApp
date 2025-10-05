import SwiftUI

struct CoffeeDateView: View {
    var body: some View {
        NavigationLink(destination: FullScreenCoffeeDateView()) {
            NutritionReminderCard(
                icon: "cup.and.saucer.fill",
                color: .pink,
                text: "Can I take you on a coffee date?"
            )
        }
    }
}
