import SwiftUI

// Define the discrete steps of our flow
enum OnboardingStep: Hashable {
    case name, goal, dateOfBirth, activity, terms
}

struct OnboardingFlowView: View {
    var onComplete: () -> Void
    
    @StateObject private var viewModel = OnboardingViewModel()
    @Environment(\.managedObjectContext) private var viewContext
    
    // This path controls the navigation stack programmatically
    @State private var navigationPath = [OnboardingStep]()

    var body: some View {
        NavigationStack(path: $navigationPath) {
            QuestionNameView() // The first screen
                .navigationDestination(for: OnboardingStep.self) { step in
                    // This is where the coordinator decides which view to show
                    switch step {
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
                    }
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
