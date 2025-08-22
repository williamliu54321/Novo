import SwiftUI

struct OnboardingFlowView: View {
    var onComplete: () -> Void
    
    @StateObject private var viewModel = OnboardingViewModel()
    @Environment(\.managedObjectContext) private var viewContext
    @State private var navigationPath = [OnboardingStep]()

    var body: some View {
        NavigationStack(path: $navigationPath) {
            
            // --- THIS IS THE FIRST PAGE ---
            // It's the root view of the stack, defined only once.
            // It uses the initializer that accepts (title, iconName) pairs.
            OnboardingSingleSelectionView(
                title: "Ready to feel like you again?",
                subtitle: "Where are you with your GLP-1 journey?",
                selection: $viewModel.journeyStatus,
                nextStep: .medication,
                progress: 0.1,
                options: [
                    (title: "I'm already on a GLP-1", iconName: "sparkles"),
                    (title: "I'm about to start a GLP-1", iconName: "play.fill")
                ]
            )
            .navigationDestination(for: OnboardingStep.self) { step in
                switch step {
                case .medication:
                    // This is the second page.
                    // It uses the simpler initializer that just takes an array of strings.
                    OnboardingSingleSelectionView(
                        title: "Which GLP-1 medication are you taking?",
                        subtitle: "If it's not listed, choose \"Other\".",
                        selection: $viewModel.medication,
                        nextStep: .dose,
                        progress: 0.2,
                        options: [
                            "Zepbound®",
                            "Mounjaro®",
                            "Ozempic®",
                            "Wegovy®",
                            "Trulicity®",
                            "Compounded Semaglutide",
                            "Compounded Tirzepatide",
                            "Other"
                        ]
                    )
                
                // Add your other onboarding steps here
                default:
                     Text("View for this step is not built yet.")
                }
            }
        }
        .environmentObject(viewModel)
    }
    
    private func handleCompletion() {
        viewModel.saveUserProfile(in: viewContext)
        onComplete()
    }
}
