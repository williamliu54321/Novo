import SwiftUI
import SuperwallKit

@main
struct MyApp: App {
    // Create persistence controller
    let persistenceController = PersistenceController.shared

    init() {
        Superwall.configure(apiKey: "pk_k1p_T3BBJHgUpK8eIUPys")
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                // 👇 Inject the Core Data context into the environment
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
