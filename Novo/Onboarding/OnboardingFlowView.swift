import SwiftUI
import UIKit // Needed for styling the page dots
import Foundation

enum OnboardingStep: Hashable {
    case journeyStatus
    case name, goal, dateOfBirth, activity, terms
    case medication, dose
}

struct OnboardingPageInfo: Identifiable {
    let id = UUID()
    let sfSymbolName: String
    let title: String
    let description: String
}

// A private helper view to display one intro page
private struct OnboardingPageView: View {
    let page: OnboardingPageInfo
    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                RoundedRectangle(cornerRadius: 30).fill(Color(uiColor: .systemGray6))
                    .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
                Image(systemName: page.sfSymbolName).resizable().scaledToFit().frame(width: 100, height: 100).foregroundColor(.secondary)
            }.frame(height: 350).padding(40)
            Text(page.title).font(.title).fontWeight(.bold).multilineTextAlignment(.center).padding(.horizontal)
            Text(page.description).font(.body).foregroundStyle(.secondary).multilineTextAlignment(.center).padding(.horizontal, 30)
            Spacer()
        }
    }
}

struct OnboardingFlowView: View {
    var onComplete: () -> Void
    
    @StateObject private var viewModel = OnboardingViewModel()
    @Environment(\.managedObjectContext) private var viewContext
    @State private var navigationPath = [OnboardingStep]()

    private let introPages: [OnboardingPageInfo] = [
        .init(sfSymbolName: "camera.viewfinder", title: "Snack, Snap & Track in Seconds", description: "Just snap a photo of your meal—and instantly log protein, fiber, and more."),
        .init(sfSymbolName: "pawprint.fill", title: "Virtual Capybara, Real Motivation", description: "Get gentle nudges and good vibes as you log your protein, fiber, water, and steps."),
        .init(sfSymbolName: "chart.line.uptrend.xyaxis", title: "Watch Your Weight Transform", description: "Clear trends and milestones. With MeAgain, you'll see your progress day by day."),
        .init(sfSymbolName: "list.bullet.clipboard.fill", title: "Stay on top of your GLP-1 journey", description: "See your current dose, progress metrics, and daily goals—all in one place.")
    ]
    @State private var currentPageIndex = 0

    init(onComplete: @escaping () -> Void) {
        self.onComplete = onComplete
        UIPageControl.appearance().currentPageIndicatorTintColor = .black
        UIPageControl.appearance().pageIndicatorTintColor = UIColor.black.withAlphaComponent(0.2)
    }

    var body: some View {
        // --- 1. Everything is inside ONE NavigationStack ---
        // There is no more if/else.
        NavigationStack(path: $navigationPath) {
            
            // --- 2. The intro pages are now the "root" view of the stack ---
            VStack(spacing: 0) {
                TabView(selection: $currentPageIndex) {
                    ForEach(introPages.indices, id: \.self) { index in
                         OnboardingPageView(page: introPages[index]).tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                
                NavigationLink(value: OnboardingStep.journeyStatus) {
                    Text("Get Started")
                        .font(.headline).fontWeight(.bold).foregroundColor(.white)
                        .frame(maxWidth: .infinity).padding().background(Color.black).cornerRadius(16)
                }
                .padding(20)
            }
            .navigationTitle("")
            
            .navigationDestination(for: OnboardingStep.self) { step in
                switch step {
                case .journeyStatus:
                     OnboardingSingleSelectionView(
                        title: "Ready to feel like you again?",
                        subtitle: "Where are you with your GLP-1 journey?",
                        selection: $viewModel.journeyStatus,
                        nextStep: .medication,
                        progress: 0.1,
                        options: ["I'm already on a GLP-1", "I'm about to start a GLP-1"]
                     )

                case .medication:
                    // Using the simple convenience initializer for String selection
                    OnboardingSingleSelectionView(
                        title: "Which GLP-1 medication do you plan to use?",
                        subtitle: "If you're not sure, pick your best guess — you can always change it later.",
                        selection: $viewModel.medication,
                        nextStep: .dose,
                        progress: 0.2,
                        options: [
                            "Mounjaro®",
                            "Ozempic®", 
                            "Wegovy®",
                            "Trulicity®",
                            "Compounded Semaglutide",
                            "Compounded Tirzepatide"
                        ],
                        customInputEnabled: true, // Allow custom medication entry
                        customModalTitle: "Medication",
                        customModalPlaceholder: "Enter Missing Medication",
                        customModalOptions: [
                            "Saxenda®",
                            "Rybelsus®", 
                            "Victoza®",
                            "Byetta®",
                            "Adlyxin®"
                        ]
                    )

                case .dose:
                    // Using the full generic initializer for Double selection
                    OnboardingSingleSelectionView(
                        title: "Do you know your recommended starting dose?",
                        subtitle: "It's okay if you're not sure!",
                        selection: $viewModel.dose, // Binds to the Double? property
                        nextStep: .activity,
                        progress: 0.4,
                        options: [
                            (title: "0.25mg", value: 0.25),
                            (title: "0.5mg", value: 0.5),
                            (title: "1.0mg", value: 1.0),
                            (title: "2.5mg", value: 2.5),
                            (title: "5.0mg", value: 5.0),
                            (title: "7.5mg", value: 7.5),
                            (title: "10.0mg", value: 10.0)
                        ],
                        customModalTitle: "Dosage",
                        customModalPlaceholder: "Enter Custom Dosage",
                        customModalOptions: [
                            "0.125mg",
                            "0.7mg",
                            "1.7mg",
                            "2.0mg",
                            "2.4mg"
                        ],
                        valueToString: { dose in // How to display a Double
                            let formatter = NumberFormatter()
                            formatter.minimumFractionDigits = 0
                            formatter.maximumFractionDigits = 3
                            let numString = formatter.string(from: NSNumber(value: dose)) ?? "\(dose)"
                            return "\(numString)mg"
                        },
                        stringToValue: { text in // How to parse user text
                            // Remove "mg" suffix if present and convert to Double
                            let cleanText = text.replacingOccurrences(of: "mg", with: "").trimmingCharacters(in: .whitespaces)
                            return Double(cleanText)
                        }
                    )

                default:
                    VStack(spacing: 16) {
                        Text("Final Step")
                            .font(.title).bold()
                        Button {
                            handleCompletion()   // <-- only runs when user taps Continue
                        } label: {
                            Text("Continue")
                                .font(.headline).bold()
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.black)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.top, 24)
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
