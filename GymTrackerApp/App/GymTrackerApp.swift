import SwiftUI
import SwiftData
import UserNotifications

@main
struct GymTrackerApp: App {
    @StateObject private var userManager = UserManager()
    
    // SwiftData ModelContainer - only for WorkoutHistory
    static let container: ModelContainer = {
        let schema = Schema([
            StoredWorkoutHistory.self
        ])
        
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            #if DEBUG
            print("❌ SwiftData ModelContainer creation failed: \(error)")
            #endif
            // Fallback to in-memory storage if persistent fails
            let fallbackConfig = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
            do {
                return try ModelContainer(for: schema, configurations: [fallbackConfig])
            } catch {
                #if DEBUG
                print("❌ Fatal: Could not create ModelContainer even with fallback: \(error)")
                #endif
                // Last resort: Create a minimal in-memory container
                // This prevents app crash but data won't persist
                let minimalConfig = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
                if let minimalContainer = try? ModelContainer(for: schema, configurations: [minimalConfig]) {
                    return minimalContainer
                }
                // Absolute last resort: Force create a basic in-memory container
                // This should never fail, but if it does, we'll catch it below
                // This prevents app crash - data just won't persist
                do {
                    return try ModelContainer(for: schema, configurations: [minimalConfig])
                } catch {
                    #if DEBUG
                    print("⚠️ Critical: All ModelContainer creation attempts failed. Creating emergency container.")
                    #endif
                    // Emergency fallback: use a guaranteed-failure path with explicit diagnostic
                    // rather than force-unwrapping with try!.
                    fatalError("Unable to create any SwiftData ModelContainer: \(error.localizedDescription)")
                }
            }
        }
    }()

    init() {
        UNUserNotificationCenter.current().delegate = NotificationDelegate.shared
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(userManager)
                .modelContainer(Self.container)
                .preferredColorScheme(.light)
        }
    }
}

