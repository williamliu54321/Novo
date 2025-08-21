import SwiftUI

// Define the discrete steps of our flow
enum OnboardingStep: Hashable {
    case journeyStart // <-- ADD THIS
    case name, goal, dateOfBirth, activity, terms
    // Adding medication and dose here to match the switch statement
    case medication, dose
}

struct OnboardingFlowView: View {
    var onComplete: () -> Void
    
    @StateObject private var viewModel = OnboardingViewModel()
    @Environment(\.managedObjectContext) private var viewContext
    
    // This path controls the navigation stack programmatically
    @State private var navigationPath = [OnboardingStep]()

    var body: some View {
        NavigationStack(path: $navigationPath) {
            
            OnboardingJourneyStartView()
            
                .navigationDestination(for: OnboardingStep.self) { step in
                    switch step {
                    case .journeyStart:
                        OnboardingJourneyStartView()
                    case .name:
                        QuestionNameView()
                    case .goal:
                        QuestionGoalView()
                    case .dateOfBirth:
                        QuestionDOBView()
                    case .activity:
                        QuestionActivityView()
                    case .terms:
                        QuestionTermsView(onComplete: handleCompletion)
                        
                    // --- BRACKETS FIXED HERE ---
                    // The following cases have been moved inside the switch statement's closing brace.
                    case .medication:
                        OnboardingSingleSelectionView(
                            title: "Which GLP-1 medication are you taking?",
                            subtitle: "If it's not listed, choose \"Other\".", // Example of using the optional subtitle
                            options: ["Zepbound®", "Mounjaro®", "Ozempic®", "Wegovy®", "Trulicity®", "Compounded Semaglutide", "Compounded Tirzepatide", "Other"],
                            selection: $viewModel.medication, // Binds to the ViewModel
                            nextStep: .dose,                   // Tells it where to go next
                            progress: 0.2                      // Sets the progress bar
                        )

                    default:
                        Text("View for this step is not built yet.")
                    } // <-- This is the correct closing brace for the switch statement.
                }
        }
        // All child views will have access to the same instance of the ViewModel
        .environmentObject(viewModel)
    }
    
    private func handleCompletion() {
        viewModel.saveUserProfile(in: viewContext)
        onComplete()
    }
}
