import SwiftUI
import UIKit // Needed for styling the page dots
import Foundation
import StoreKit
import UserNotifications

enum OnboardingStep: Hashable {
    case journeyStatus
    case medication, dose, shotFrequency, benefits, gender
    case name, goal, dateOfBirth, heightWeight, startWeightDate, dreamWeight, summary, goalPace
    case glpEffectiveness, activity, toughestDayInfo, cravingsDay, sideEffects, rating, motivation, notifications, completion, personalPlan, terms
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
                            "Compounded Tirzepatide",
                            "I haven't decided"
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
                        nextStep: .shotFrequency,
                        progress: 0.4,
                        options: [
                            (title: "0.25mg", value: 0.25),
                            (title: "0.5mg", value: 0.5),
                            (title: "1.0mg", value: 1.0),
                            (title: "2.5mg", value: 2.5),
                            (title: "5.0mg", value: 5.0),
                            (title: "7.5mg", value: 7.5),
                            (title: "10.0mg", value: 10.0),
                            (title: "Not sure yet", value: -1.0)
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
                            if dose == -1.0 { return "Not sure yet" }
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

                case .shotFrequency:
                    // Shot frequency selection with last shot date
                    ShotFrequencyView {
                        navigationPath.append(.benefits)
                    }

                case .benefits:
                    // Benefits screen with chart
                    BenefitsView(
                        onContinue: {
                            navigationPath.append(.gender)
                        }
                    )

                case .gender:
                    // Gender selection
                    OnboardingSingleSelectionView(
                        title: "Help us get the basics right.",
                        subtitle: "We use a few simple details to better tailor your nutrition, activity, and wellness plan — all based on what works best for your body.",
                        selection: $viewModel.gender,
                        nextStep: .dateOfBirth,
                        progress: 0.7,
                        options: ["Male", "Female", "Other", "Prefer not to say"]
                    )

                case .dateOfBirth:
                    // Birthday selection with wheel picker
                    BirthdayView {
                        navigationPath.append(.heightWeight)
                    }

                case .heightWeight:
                    // Height and current weight selection
                    HeightWeightView {
                        navigationPath.append(.startWeightDate)
                    }

                case .startWeightDate:
                    // Start weight and date selection
                    StartWeightDateView {
                        navigationPath.append(.dreamWeight)
                    }

                case .dreamWeight:
                    // Dream weight selection with interactive picker
                    DreamWeightView {
                        navigationPath.append(.summary)
                    }
                    
                case .summary:
                    // Summary view with weight loss message
                    GoalSummaryView {
                        navigationPath.append(.goalPace)
                    }
                    
                case .goalPace:
                    // Goal pace selection
                    GoalPaceView {
                        navigationPath.append(.glpEffectiveness)
                    }
                    
                case .glpEffectiveness:
                    // GLP effectiveness informational screen
                    GLPEffectivenessView {
                        navigationPath.append(.activity)
                    }
                    
                case .activity:
                    // Activity level selection (daily routine)
                    OnboardingSingleSelectionView(
                        title: "Tell us a bit about your daily routine.",
                        subtitle: nil,
                        selection: $viewModel.activityLevelString,
                        nextStep: .toughestDayInfo,
                        progress: 0.95,
                        options: [
                            "Sedentary (mostly inactive, little exercise)",
                            "Lightly Active (light daily activity and movement)",
                            "Active (regular workouts or physical labor)",
                            "Very Active (intense exercise or very physical job)"
                        ]
                    )
                    
                case .toughestDayInfo:
                    // Toughest day informational screen
                    ToughestDayView {
                        navigationPath.append(.cravingsDay)
                    }
                    
                case .cravingsDay:
                    // Food cravings day selection
                    OnboardingSingleSelectionView(
                        title: "Which day does food noise and cravings hit hardest?",
                        subtitle: "We'll time your GLP-1 dose so it works hardest when cravings—and food noise—are at their peak.",
                        selection: $viewModel.toughestDay,
                        nextStep: .sideEffects,
                        progress: 0.97,
                        options: ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
                    )
                    
                case .sideEffects:
                    // Side effects concern selection  
                    OnboardingSingleSelectionView(
                        title: "What side effects are you most concerned about?",
                        subtitle: "Share what's on your mind — we'll tailor support to your needs.",
                        selection: $viewModel.primarySideEffectConcern,
                        nextStep: .motivation,
                        progress: 0.98,
                        options: [
                            "Nausea",
                            "Fatigue", 
                            "Hair Loss",
                            "Muscle Loss",
                            "Constipation",
                            "Bloating",
                            "Sulfur Burps",
                            "Heartburn",
                            "Food Noise"
                        ],
                        customInputEnabled: true,
                        customModalTitle: "Other",
                        customModalPlaceholder: "Add your own side effects",
                        customModalOptions: [
                            "Migraine",
                            "Diarrhea",
                            "Injection Site Reaction",
                            "Mood Swings",
                            "Metallic Taste",
                            "Stomach Pain",
                            "Suppressed Appetite"
                        ]
                    )

                case .motivation:
                    // Motivation slide 
                    MotivationView {
                        navigationPath.append(.rating)
                    }

                case .rating:
                    // Rating slide with testimonials
                    RatingView {
                        navigationPath.append(.notifications)
                    }

                case .notifications:
                    // Notification permission slide
                    NotificationPermissionView {
                        navigationPath.append(.completion)
                    }

                case .completion:
                    // Final completion slide
                    CompletionView {
                        navigationPath.append(.personalPlan)
                    }
                
                case .personalPlan:
                    PersonalPlanView(viewModel: viewModel) {
                        handleCompletion()
                    }

                case .name:
                    // Name selection placeholder
                    QuestionNameView()
                    
                case .goal:
                    // Goal selection placeholder 
                    VStack(spacing: 16) {
                        Text("Goal Selection")
                            .font(.title).bold()
                        Button {
                            navigationPath.append(.dateOfBirth)
                        } label: {
                            Text("Continue")
                                .font(.headline).bold()
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.black)
                                .foregroundColor(.white)
                                .cornerRadius(16)
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.top, 24)

                case .terms:
                    // Final step/terms
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
                                .cornerRadius(16)
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

// MARK: - Additional Onboarding Views

private struct BenefitsView: View {
    let onContinue: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            OnboardingHeaderView(progress: 0.6)
            
            VStack(alignment: .leading, spacing: 16) {
                Text("See better results, fewer ups and downs")
                    .font(.largeTitle)
                    .bold()
                    .padding(.top)
                
                Text("Novo supports your GLP-1 journey by helping you manage weight loss, tackle cravings, and avoid weight rebounds.")
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal)
            
            Spacer()
            
            // Weight Chart Section
            VStack(spacing: 16) {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(uiColor: .systemGray6))
                    .frame(height: 280)
                    .overlay(
                        VStack(spacing: 16) {
                            HStack {
                                Text("Your Weight")
                                    .font(.headline)
                                    .bold()
                                Spacer()
                            }
                            
                            // Simplified chart representation
                            ZStack {
                                // Background area for restrictive diets (red/pink)
                                Path { path in
                                    path.move(to: CGPoint(x: 50, y: 80))
                                    path.addLine(to: CGPoint(x: 150, y: 120))
                                    path.addLine(to: CGPoint(x: 250, y: 60))
                                    path.addLine(to: CGPoint(x: 300, y: 40))
                                    path.addLine(to: CGPoint(x: 300, y: 140))
                                    path.addLine(to: CGPoint(x: 250, y: 140))
                                    path.addLine(to: CGPoint(x: 150, y: 140))
                                    path.addLine(to: CGPoint(x: 50, y: 140))
                                    path.closeSubpath()
                                }
                                .fill(Color.red.opacity(0.2))
                                
                                // Novo line (blue/purple)
                                Path { path in
                                    path.move(to: CGPoint(x: 50, y: 80))
                                    path.addQuadCurve(to: CGPoint(x: 150, y: 100), control: CGPoint(x: 100, y: 70))
                                    path.addQuadCurve(to: CGPoint(x: 250, y: 120), control: CGPoint(x: 200, y: 110))
                                    path.addQuadCurve(to: CGPoint(x: 300, y: 130), control: CGPoint(x: 275, y: 125))
                                }
                                .stroke(Color.blue, lineWidth: 3)
                                
                                // Start and end points
                                Circle()
                                    .fill(Color.blue)
                                    .frame(width: 8, height: 8)
                                    .position(x: 50, y: 80)
                                
                                Circle()
                                    .fill(Color.blue)
                                    .frame(width: 8, height: 8)
                                    .position(x: 300, y: 130)
                                
                                // Labels
                                Text("Restrictive Diets")
                                    .font(.caption)
                                    .foregroundColor(.red)
                                    .position(x: 220, y: 50)
                                
                                HStack {
                                    Image(systemName: "bolt.fill")
                                        .foregroundColor(.blue)
                                    Text("Novo")
                                        .font(.headline)
                                        .bold()
                                        .foregroundColor(.blue)
                                }
                                .position(x: 80, y: 160)
                            }
                            .frame(height: 180)
                            
                            HStack {
                                Text("Month 1")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Spacer()
                                Text("Month 6")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding()
                    )
                
                Text("82% of new GLP-1 users with Novo reported better outcomes compared to traditional methods.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal)
            
            Spacer()
            
            Button {
                onContinue()
            } label: {
                Text("Continue")
                    .font(.headline)
                    .bold()
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.black)
                    .foregroundColor(.white)
                    .cornerRadius(16)
            }
            .padding([.horizontal, .bottom])
        }
        .navigationBarBackButtonHidden()
    }
}

private struct BirthdayView: View {
    @EnvironmentObject var viewModel: OnboardingViewModel
    let onContinue: () -> Void
    
    @State private var selectedMonth = Calendar.current.component(.month, from: Date())
    @State private var selectedDay = Calendar.current.component(.day, from: Date())
    @State private var selectedYear = Calendar.current.component(.year, from: Date()) - 25
    
    private let months = Calendar.current.monthSymbols
    private let days = Array(1...31)
    private let years = Array(1920...Calendar.current.component(.year, from: Date()))
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            OnboardingHeaderView(progress: 0.8)
            
            VStack(alignment: .leading, spacing: 16) {
                Text("When's your birthday?")
                    .font(.largeTitle)
                    .bold()
                    .padding(.top)
                
                Text("Your age helps us fine-tune your nutrition goals to keep them accurate and realistic.")
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal)
            
            Spacer()
            
            // Custom wheel-style date picker
            HStack(spacing: 0) {
                // Month picker
                Picker("Month", selection: $selectedMonth) {
                    ForEach(1...12, id: \.self) { month in
                        Text(months[month - 1])
                            .tag(month)
                    }
                }
                .pickerStyle(.wheel)
                .frame(maxWidth: .infinity)
                
                // Day picker  
                Picker("Day", selection: $selectedDay) {
                    ForEach(days, id: \.self) { day in
                        Text("\(day)")
                            .tag(day)
                    }
                }
                .pickerStyle(.wheel)
                .frame(maxWidth: .infinity)
                
                // Year picker
                Picker("Year", selection: $selectedYear) {
                    ForEach(years.reversed(), id: \.self) { year in
                        Text(String(year))
                            .tag(year)
                    }
                }
                .pickerStyle(.wheel)
                .frame(maxWidth: .infinity)
            }
            .padding(.horizontal)
            
            Spacer()
            
            Button {
                // Update the view model with the selected date
                if let date = Calendar.current.date(from: DateComponents(year: selectedYear, month: selectedMonth, day: selectedDay)) {
                    viewModel.dateOfBirth = date
                }
                onContinue()
            } label: {
                Text("Continue")
                    .font(.headline)
                    .bold()
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.black)
                    .foregroundColor(.white)
                    .cornerRadius(16)
            }
            .padding([.horizontal, .bottom])
        }
        .navigationBarBackButtonHidden()
        .onAppear {
            // Initialize picker values from existing date
            let components = Calendar.current.dateComponents([.year, .month, .day], from: viewModel.dateOfBirth)
            selectedYear = components.year ?? selectedYear
            selectedMonth = components.month ?? selectedMonth
            selectedDay = components.day ?? selectedDay
        }
    }
}

private struct DreamWeightView: View {
    @EnvironmentObject var viewModel: OnboardingViewModel
    let onContinue: () -> Void
    
    @State private var selectedWeight: Double = 70.0 // Default in kg
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            OnboardingHeaderView(progress: 0.88)
            
            VStack(alignment: .leading, spacing: 16) {
                Text("What's Your Dream Weight?")
                    .font(.largeTitle)
                    .bold()
                    .padding(.top)
                
                Text("Share your goal weight so we can map out your transformation.")
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal)
            
            Spacer()
            
            VStack(spacing: 24) {
                Text("Dream Weight")
                    .font(.headline)
                
                // Display current selected weight
                Text(formatWeight(selectedWeight, isMetric: viewModel.useMetric))
                    .font(.system(size: 48, weight: .bold, design: .default))
                
                // Simple stepper controls
                HStack(spacing: 20) {
                    Button(action: {
                        let increment = viewModel.useMetric ? 1.0 : 2.0 // 1kg or 2lbs
                        selectedWeight = max(getWeightRange().lowerBound, selectedWeight - increment)
                    }) {
                        Image(systemName: "minus.circle.fill")
                            .font(.system(size: 44))
                            .foregroundColor(.black)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        let increment = viewModel.useMetric ? 1.0 : 2.0 // 1kg or 2lbs
                        selectedWeight = min(getWeightRange().upperBound, selectedWeight + increment)
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 44))
                            .foregroundColor(.black)
                    }
                }
                .padding(.horizontal, 40)
                
                // Simple slider as alternative
                VStack(spacing: 8) {
                    Slider(value: $selectedWeight, in: getWeightRange(), step: viewModel.useMetric ? 0.5 : 1.0)
                        .accentColor(.black)
                        .padding(.horizontal)
                    
                    HStack {
                        Text(formatWeight(getWeightRange().lowerBound, isMetric: viewModel.useMetric))
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(formatWeight(getWeightRange().upperBound, isMetric: viewModel.useMetric))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                }
            }
            .frame(maxWidth: .infinity)
            
            Spacer()
            
            // Imperial/Metric toggle
            HStack(spacing: 16) {
                Text("imperial")
                    .foregroundStyle(viewModel.useMetric ? .secondary : .primary)
                    .font(.system(size: 16, weight: .medium))
                
                Toggle("", isOn: $viewModel.useMetric)
                    .toggleStyle(BlackWhiteToggleStyle())
                    .labelsHidden()
                    .scaleEffect(0.8)
                
                Text("metric")
                    .foregroundStyle(viewModel.useMetric ? .primary : .secondary)
                    .font(.system(size: 16, weight: .medium))
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal)
            .padding(.bottom, 30) // Add spacing between toggle and button
            
            Button {
                // Convert to kg for storage if needed
                viewModel.dreamWeight = viewModel.useMetric ? selectedWeight : selectedWeight * 0.453592 // lbs to kg
                onContinue()
            } label: {
                Text("Continue")
                    .font(.headline)
                    .bold()
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.black)
                    .foregroundColor(.white)
                    .cornerRadius(16)
            }
            .padding([.horizontal, .bottom])
        }
        .navigationBarBackButtonHidden()
        .onAppear {
            // Initialize with existing dream weight if available
            if let existingWeight = viewModel.dreamWeight {
                selectedWeight = viewModel.useMetric ? existingWeight : existingWeight * 2.20462 // kg to lbs
            } else {
                // Set default based on unit system
                selectedWeight = viewModel.useMetric ? 70.0 : 154.0 // 70kg ≈ 154lbs
            }
        }
        .onChange(of: viewModel.useMetric) { _, newValue in
            // Convert weight when unit changes
            if newValue {
                // Imperial to Metric (lbs to kg)
                selectedWeight = selectedWeight * 0.453592
            } else {
                // Metric to Imperial (kg to lbs)
                selectedWeight = selectedWeight * 2.20462
            }
        }
    }
    
    private func formatWeight(_ weight: Double, isMetric: Bool) -> String {
        if isMetric {
            return String(format: "%.1f kg", weight)
        } else {
            return String(format: "%.1f lbs", weight)
        }
    }
    
    private func getWeightRange() -> ClosedRange<Double> {
        if viewModel.useMetric {
            return 30.0...200.0 // kg
        } else {
            return 66.0...440.0 // lbs
        }
    }
}

private struct HeightWeightView: View {
    @EnvironmentObject var viewModel: OnboardingViewModel
    let onContinue: () -> Void
    
    @State private var selectedHeight: Double = 170.0 // Default in cm
    @State private var selectedWeight: Double = 70.0 // Default in kg
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            OnboardingHeaderView(progress: 0.85)
            
            VStack(alignment: .leading, spacing: 16) {
                Text("Your Height & Weight")
                    .font(.largeTitle)
                    .bold()
                    .padding(.top)
                
                Text("Your current height and weight help us calculate your BMI and personalize your daily nutrition and activity goals.")
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal)
            
            Spacer()
            
            // Height and Weight pickers
            HStack(spacing: 40) {
                VStack(spacing: 16) {
                    Text("Height")
                        .font(.headline)
                    
                    Picker("Height", selection: $selectedHeight) {
                        ForEach(getHeightValues(), id: \.self) { height in
                            Text(formatHeight(height, isMetric: viewModel.useMetric))
                                .tag(height)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(height: 150)
                    .clipped()
                }
                
                VStack(spacing: 16) {
                    Text("Weight")
                        .font(.headline)
                    
                    Picker("Weight", selection: $selectedWeight) {
                        ForEach(getWeightValues(), id: \.self) { weight in
                            Text(formatWeight(weight, isMetric: viewModel.useMetric))
                                .tag(weight)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(height: 150)
                    .clipped()
                }
            }
            .padding(.horizontal)
            
            Spacer()
            
            // Imperial/Metric toggle
            HStack(spacing: 16) {
                Text("imperial")
                    .foregroundStyle(viewModel.useMetric ? .secondary : .primary)
                    .font(.system(size: 16, weight: .medium))
                
                Toggle("", isOn: $viewModel.useMetric)
                    .toggleStyle(BlackWhiteToggleStyle())
                    .labelsHidden()
                    .scaleEffect(0.8)
                
                Text("metric")
                    .foregroundStyle(viewModel.useMetric ? .primary : .secondary)
                    .font(.system(size: 16, weight: .medium))
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal)
            .padding(.bottom, 30) // Add spacing between toggle and button to match DreamWeightView
            
            Button {
                // Convert and save values in metric
                viewModel.height = viewModel.useMetric ? selectedHeight : selectedHeight * 2.54 // inches to cm
                viewModel.currentWeight = viewModel.useMetric ? selectedWeight : selectedWeight * 0.453592 // lbs to kg
                onContinue()
            } label: {
                Text("Continue")
                    .font(.headline)
                    .bold()
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.black)
                    .foregroundColor(.white)
                    .cornerRadius(16)
            }
            .padding([.horizontal, .bottom])
        }
        .navigationBarBackButtonHidden()
        .onAppear {
            // Initialize with existing values if available
            if let existingHeight = viewModel.height {
                selectedHeight = viewModel.useMetric ? existingHeight : existingHeight / 2.54 // cm to inches
            } else {
                selectedHeight = viewModel.useMetric ? 170.0 : 67.0 // 170cm ≈ 67 inches
            }
            
            if let existingWeight = viewModel.currentWeight {
                selectedWeight = viewModel.useMetric ? existingWeight : existingWeight * 2.20462 // kg to lbs
            } else {
                selectedWeight = viewModel.useMetric ? 70.0 : 154.0 // 70kg ≈ 154lbs
            }
        }
        .onChange(of: viewModel.useMetric) { _, newValue in
            if newValue {
                // Imperial to Metric
                selectedHeight = selectedHeight * 2.54 // inches to cm
                selectedWeight = selectedWeight * 0.453592 // lbs to kg
            } else {
                // Metric to Imperial
                selectedHeight = selectedHeight / 2.54 // cm to inches
                selectedWeight = selectedWeight * 2.20462 // kg to lbs
            }
        }
    }
    
    private func formatHeight(_ height: Double, isMetric: Bool) -> String {
        if isMetric {
            return String(format: "%.0fcm", height)
        } else {
            let feet = Int(height / 12)
            let inches = Int(height.truncatingRemainder(dividingBy: 12))
            return "\(feet)'\(inches)\""
        }
    }
    
    private func formatWeight(_ weight: Double, isMetric: Bool) -> String {
        if isMetric {
            return String(format: "%.1fkg", weight)
        } else {
            return String(format: "%.1flbs", weight)
        }
    }
    
    private func getHeightValues() -> [Double] {
        if viewModel.useMetric {
            return Array(stride(from: 120.0, through: 220.0, by: 1.0)) // cm
        } else {
            return Array(stride(from: 48.0, through: 84.0, by: 1.0)) // inches
        }
    }
    
    private func getWeightValues() -> [Double] {
        if viewModel.useMetric {
            return Array(stride(from: 30.0, through: 200.0, by: 0.1)) // kg
        } else {
            return Array(stride(from: 66.0, through: 440.0, by: 0.1)) // lbs
        }
    }
}

// MARK: - Start Weight Date View

private struct StartWeightDateView: View {
    @EnvironmentObject var viewModel: OnboardingViewModel
    let onContinue: () -> Void
    
    @State private var startWeight: Double = 70.0 // Default in kg
    @State private var startDate = Date()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            OnboardingHeaderView(progress: 0.86)
            
            VStack(alignment: .leading, spacing: 16) {
                Text("Tell us where you started.")
                    .font(.largeTitle)
                    .bold()
                    .padding(.top)
                
                Text("Add the weight you were at when you began GLP-1, along with your start date.")
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal)
            
            Spacer()
            
            VStack(spacing: 32) {
                // Start Weight Section with interactive stepper
                VStack(spacing: 20) {
                    HStack {
                        Image(systemName: "scalemass")
                            .font(.title2)
                            .foregroundColor(.primary)
                        Text("Start Weight")
                            .font(.headline)
                        Spacer()
                    }
                    
                    // Weight display and controls
                    VStack(spacing: 16) {
                        Text(formatWeight(startWeight, isMetric: viewModel.useMetric))
                            .font(.system(size: 36, weight: .bold))
                        
                        // Stepper controls
                        HStack(spacing: 20) {
                            Button(action: {
                                let increment = viewModel.useMetric ? 1.0 : 2.0
                                startWeight = max(getWeightRange().lowerBound, startWeight - increment)
                            }) {
                                Image(systemName: "minus.circle.fill")
                                    .font(.system(size: 44))
                                    .foregroundColor(.black)
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                let increment = viewModel.useMetric ? 1.0 : 2.0
                                startWeight = min(getWeightRange().upperBound, startWeight + increment)
                            }) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 44))
                                    .foregroundColor(.black)
                            }
                        }
                        .padding(.horizontal, 40)
                        
                        // Slider for fine control
                        Slider(value: $startWeight, in: getWeightRange(), step: viewModel.useMetric ? 0.5 : 1.0)
                            .accentColor(.black)
                            .padding(.horizontal)
                    }
                }
                .padding()
                .background(Color(uiColor: .systemGray6))
                .cornerRadius(16)
                .padding(.horizontal)
                
                // Start Date Section with date picker
                HStack {
                    Image(systemName: "calendar")
                        .font(.title2)
                        .foregroundColor(.primary)
                    Text("Start Date")
                        .font(.headline)
                    
                    Spacer()
                    
                    // Inline date picker on the right
                    DatePicker("", selection: $startDate, displayedComponents: .date)
                        .datePickerStyle(.compact)
                        .labelsHidden()
                        .preferredColorScheme(.light)
                }
                .padding()
                .background(Color(uiColor: .systemGray6))
                .cornerRadius(16)
                .padding(.horizontal)
            }
            
            Spacer()
            
            // Imperial/Metric toggle
            HStack(spacing: 16) {
                    Text("imperial")
                        .foregroundStyle(viewModel.useMetric ? .secondary : .primary)
                        .font(.system(size: 16, weight: .medium))
                    
                    Toggle("", isOn: $viewModel.useMetric)
                        .toggleStyle(BlackWhiteToggleStyle())
                        .labelsHidden()
                        .scaleEffect(0.8)
                    
                    Text("metric")
                        .foregroundStyle(viewModel.useMetric ? .primary : .secondary)
                        .font(.system(size: 16, weight: .medium))
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal)
                .padding(.bottom, 30) // Add spacing between toggle and button to match DreamWeightView
            
            Button {
                // Save the values
                viewModel.startWeight = viewModel.useMetric ? startWeight : startWeight * 0.453592 // Convert to kg if needed
                viewModel.startDate = startDate
                onContinue()
            } label: {
                Text("Continue")
                    .font(.headline)
                    .bold()
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.black)
                    .foregroundColor(.white)
                    .cornerRadius(16)
            }
            .padding([.horizontal, .bottom])
        }
        .navigationBarBackButtonHidden()
        .onAppear {
            // Initialize with current weight if available
            if let existingStartWeight = viewModel.startWeight {
                startWeight = viewModel.useMetric ? existingStartWeight : existingStartWeight * 2.20462 // kg to lbs
            } else if let currentWeight = viewModel.currentWeight {
                startWeight = viewModel.useMetric ? currentWeight : currentWeight * 2.20462 // Default to current weight
            } else {
                startWeight = viewModel.useMetric ? 70.0 : 154.0 // 70kg ≈ 154lbs
            }
            
            // Initialize start date
            if let existingStartDate = viewModel.startDate {
                startDate = existingStartDate
            }
        }
        .onChange(of: viewModel.useMetric) { _, newValue in
            // Convert weight when unit changes
            if newValue {
                // Imperial to Metric (lbs to kg)
                startWeight = startWeight * 0.453592
            } else {
                // Metric to Imperial (kg to lbs)
                startWeight = startWeight * 2.20462
            }
        }
    }
    
    private func formatWeight(_ weight: Double, isMetric: Bool) -> String {
        if isMetric {
            return String(format: "%.1f kg", weight)
        } else {
            return String(format: "%.1f lbs", weight)
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    private func getWeightRange() -> ClosedRange<Double> {
        if viewModel.useMetric {
            return 30.0...200.0 // kg
        } else {
            return 66.0...440.0 // lbs
        }
    }
}

// MARK: - Shot Frequency View

private struct ShotFrequencyView: View {
    @EnvironmentObject var viewModel: OnboardingViewModel
    let onContinue: () -> Void
    
    @State private var selectedFrequency: Int? = nil
    @State private var lastShotDate = Date()
    @State private var showingCustomFrequency = false
    
    private let frequencyOptions = [
        (title: "Every day", value: 1),
        (title: "Every 7 days (most common)", value: 7),
        (title: "Every 14 days", value: 14),
        (title: "Custom", value: 0)
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            OnboardingHeaderView(progress: 0.5)
            
            VStack(alignment: .leading, spacing: 16) {
                Text("How often do you take your shots?")
                    .font(.largeTitle)
                    .bold()
                    .padding(.top)
            }
            .padding(.horizontal)
            
            Spacer()
            
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(frequencyOptions, id: \.value) { option in
                        OnboardingSelectionButton(
                            title: option.title,
                            isSelected: selectedFrequency == option.value
                        ) {
                            if option.value == 0 {
                                // Custom option
                                showingCustomFrequency = true
                            } else {
                                selectedFrequency = option.value
                            }
                        }
                    }
                    
                    // Last shot taken section with inline date picker
                    HStack {
                        Image(systemName: "calendar")
                            .font(.title2)
                            .foregroundColor(.primary)
                        Text("Last shot taken")
                            .font(.headline)
                        
                        Spacer()
                        
                        // Inline date picker on the right
                        DatePicker("", selection: $lastShotDate, displayedComponents: .date)
                            .datePickerStyle(.compact)
                            .labelsHidden()
                            .preferredColorScheme(.light)
                    }
                    .padding()
                    .background(Color(uiColor: .systemGray6))
                    .cornerRadius(16)
                    .padding(.top, 20)
                }
                .padding(.horizontal)
            }
            
            Spacer()
            
            Button {
                // Save the values
                viewModel.shotFrequency = selectedFrequency
                viewModel.lastShotDate = lastShotDate
                onContinue()
            } label: {
                Text("Continue")
                    .font(.headline)
                    .bold()
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(selectedFrequency == nil ? Color(uiColor: .systemGray3) : Color.black)
                    .foregroundColor(.white)
                    .cornerRadius(16)
            }
            .disabled(selectedFrequency == nil)
            .padding([.horizontal, .bottom])
        }
        .navigationBarBackButtonHidden()
        .onAppear {
            // Initialize with existing values
            selectedFrequency = viewModel.shotFrequency
            if let existingLastShotDate = viewModel.lastShotDate {
                lastShotDate = existingLastShotDate
            }
        }
        .sheet(isPresented: $showingCustomFrequency) {
            CustomValueInputView(
                title: "Days between",
                placeholder: "Enter number of days",
                keyboardType: .numberPad,
                additionalOptions: []
            ) { customValue in
                if let frequency = Int(customValue) {
                    selectedFrequency = frequency
                }
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy"
        return formatter.string(from: date)
    }
}

// MARK: - Goal Pace View

private struct GoalPaceView: View {
    @EnvironmentObject var viewModel: OnboardingViewModel
    let onContinue: () -> Void
    
    @State private var weeklyChange: Double = 1.5 // Default to moderate pace (in lbs)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            OnboardingHeaderView(progress: 0.93)
            
            VStack(alignment: .leading, spacing: 16) {
                Text("How quickly do you want to reach your goal?")
                    .font(.largeTitle)
                    .bold()
                    .padding(.top)
                
                Text("(Don't worry - we'll help you stay healthy whatever pace you choose.)")
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal)
            
            Spacer()
            
            VStack(spacing: 30) {
                // Estimated goal date
                HStack {
                    Image(systemName: "flag.checkered")
                        .foregroundColor(.secondary)
                    Text("Est. Goal Date")
                        .foregroundColor(.secondary)
                    Text(calculateGoalDate())
                        .bold()
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                
                // Weekly change display
                VStack(spacing: 8) {
                    Text("Weekly Change:")
                        .font(.headline)
                    
                    HStack(alignment: .bottom, spacing: 0) {
                        Text(String(format: "%.1f", weeklyChange))
                            .font(.system(size: 60, weight: .bold))
                        Text("lbs")
                            .font(.title2)
                            .padding(.bottom, 10)
                    }
                }
                
                // Slider with icons
                VStack(spacing: 20) {
                    HStack {
                        Image(systemName: "figure.walk")
                            .font(.title2)
                        
                        Slider(value: $weeklyChange, in: 0.2...3.0, step: 0.1)
                            .accentColor(sliderColor)
                        
                        Image(systemName: "rocket")
                            .font(.title2)
                    }
                    .padding(.horizontal)
                    
                    HStack {
                        Text("0.2 lbs")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("1.5 lbs")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("3 lbs")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                }
                
                // Dynamic message based on pace
                Text(paceMessage)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                    .padding(.top, 20)
            }
            
            Spacer()
            
            Button {
                // Save the goal pace
                viewModel.weeklyWeightGoal = weeklyChange * 0.453592 // Convert to kg for storage
                onContinue()
            } label: {
                Text("Continue")
                    .font(.headline)
                    .bold()
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.black)
                    .foregroundColor(.white)
                    .cornerRadius(16)
            }
            .padding([.horizontal, .bottom])
        }
        .navigationBarBackButtonHidden()
    }
    
    private var sliderColor: Color {
        if weeklyChange < 0.8 {
            return .green
        } else if weeklyChange < 2.0 {
            return .blue
        } else {
            return .purple
        }
    }
    
    private var paceMessage: String {
        if weeklyChange < 0.5 {
            return "This slower pace is gentle and sustainable for your journey."
        } else if weeklyChange < 1.0 {
            return "This steady pace balances progress with sustainability."
        } else if weeklyChange < 2.0 {
            return "This pace is ideal for long-term success."
        } else {
            return "This ambitious pace will require dedication but can deliver faster results."
        }
    }
    
    private func calculateGoalDate() -> String {
        guard let currentWeight = viewModel.currentWeight,
              let dreamWeight = viewModel.dreamWeight else {
            return "Not set"
        }
        
        let weightToLose = abs(currentWeight - dreamWeight) * 2.20462 // Convert kg difference to lbs
        let weeksNeeded = weightToLose / weeklyChange
        let goalDate = Calendar.current.date(byAdding: .weekOfYear, value: Int(weeksNeeded), to: Date()) ?? Date()
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: goalDate)
    }
}

// MARK: - Goal Summary View

private struct GoalSummaryView: View {
    @EnvironmentObject var viewModel: OnboardingViewModel
    let onContinue: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            OnboardingHeaderView(progress: 0.90)
            
            Spacer()
            
            VStack(spacing: 40) {
                // App logo
                HStack(spacing: 8) {
                    Image(systemName: "bolt.fill")
                        .foregroundColor(.blue)
                        .font(.largeTitle)
                    Text("Novo")
                        .font(.largeTitle)
                        .bold()
                }
                
                // Weight loss message  
                Group {
                    Text("Losing ")
                        .foregroundColor(.primary) +
                    Text(String(format: "%.0f lbs", calculateWeightLoss()))
                        .foregroundColor(.blue)
                        .bold() +
                    Text(" might feel overwhelming—but it's very realistic. Let's tackle it together.")
                        .foregroundColor(.primary)
                }
                .font(.title2)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
                
                // Success message
                Text("Over 80% of Novo members see tangible progress in their first month—without the scary side effects they feared.")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 30)
                    .padding(.top, 20)
            }
            
            Spacer()
            Spacer()
            
            Button {
                onContinue()
            } label: {
                Text("Continue")
                    .font(.headline)
                    .bold()
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.black)
                    .foregroundColor(.white)
                    .cornerRadius(16)
            }
            .padding([.horizontal, .bottom])
        }
        .navigationBarBackButtonHidden()
    }
    
    private func calculateWeightLoss() -> Double {
        guard let currentWeight = viewModel.currentWeight,
              let dreamWeight = viewModel.dreamWeight else {
            return 0
        }
        
        return abs(currentWeight - dreamWeight) * 2.20462 // Convert kg to lbs
    }
}

// MARK: - GLP Effectiveness View

private struct GLPEffectivenessView: View {
    let onContinue: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            OnboardingHeaderView(progress: 0.94)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Text("Make GLP-1 Work for You—3x More Effectively")
                        .font(.largeTitle)
                        .bold()
                        .padding(.top)
                        .padding(.horizontal)
                    
                    Spacer(minLength: 40)
                    
                    // Bar chart comparison
                    VStack(spacing: 20) {
                        HStack(spacing: 40) {
                            VStack(spacing: 8) {
                                Text("Without")
                                    .font(.headline)
                                
                                ZStack(alignment: .bottom) {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.gray.opacity(0.2))
                                        .frame(width: 120, height: 200)
                                    
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.gray.opacity(0.3))
                                        .frame(width: 120, height: 36) // 18% of 200
                                }
                                
                                Text("18%")
                                    .font(.title2)
                                    .bold()
                            }
                            
                            VStack(spacing: 8) {
                                HStack(spacing: 4) {
                                    Image(systemName: "bolt.fill")
                                        .foregroundColor(.blue)
                                    Text("Novo")
                                        .font(.headline)
                                }
                                
                                ZStack(alignment: .bottom) {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.blue.opacity(0.2))
                                        .frame(width: 120, height: 200)
                                    
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.blue)
                                        .frame(width: 120, height: 120) // 3x = 60% visual representation
                                }
                                
                                Text("3X")
                                    .font(.title)
                                    .bold()
                                    .foregroundColor(.white)
                                    .padding(.vertical, 20)
                            }
                        }
                        .padding(.horizontal, 40)
                        
                        Text("Enjoy a smoother experience, from managing side effects to hitting your weight-loss goals more effectively.")
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 30)
                            .padding(.top, 20)
                    }
                    
                    Spacer(minLength: 60)
                }
            }
            
            Button {
                onContinue()
            } label: {
                Text("Continue")
                    .font(.headline)
                    .bold()
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.black)
                    .foregroundColor(.white)
                    .cornerRadius(16)
            }
            .padding([.horizontal, .bottom])
        }
        .navigationBarBackButtonHidden()
    }
}


// MARK: - Toughest Day View

private struct ToughestDayView: View {
    let onContinue: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            OnboardingHeaderView(progress: 0.96)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Conquer your toughest day.")
                            .font(.largeTitle)
                            .bold()
                        
                        Text("Novo will time your \(Text("Wegovy®").bold()) dose so it peaks when your cravings hit hardest – making it easier to stay on track and in control on those challenging days.")
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    
                    // Weekly effectiveness graph
                    VStack(spacing: 16) {
                        HStack {
                            Text("Your Week")
                                .font(.headline)
                            Spacer()
                            HStack(spacing: 4) {
                                Image(systemName: "bolt.fill")
                                    .foregroundColor(.blue)
                                Text("Novo")
                                    .italic()
                            }
                        }
                        .padding(.horizontal)
                        
                        // Graph visualization
                        ZStack {
                            // Background
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.blue.opacity(0.1))
                                .frame(height: 200)
                            
                            // Curve path
                            GeometryReader { geometry in
                                Path { path in
                                    let width = geometry.size.width
                                    let height = geometry.size.height
                                    
                                    path.move(to: CGPoint(x: 0, y: height * 0.8))
                                    path.addCurve(
                                        to: CGPoint(x: width * 0.2, y: height * 0.2),
                                        control1: CGPoint(x: width * 0.05, y: height * 0.6),
                                        control2: CGPoint(x: width * 0.15, y: height * 0.3)
                                    )
                                    path.addCurve(
                                        to: CGPoint(x: width, y: height * 0.7),
                                        control1: CGPoint(x: width * 0.3, y: height * 0.25),
                                        control2: CGPoint(x: width * 0.7, y: height * 0.6)
                                    )
                                }
                                .stroke(Color.blue, lineWidth: 3)
                                
                                // Peak indicator
                                VStack {
                                    Text("Perfect Shot day")
                                        .font(.caption)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Color.white)
                                        .cornerRadius(8)
                                        .shadow(radius: 2)
                                    
                                    Text("Fri 8:15pm")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                                .position(x: geometry.size.width * 0.2, y: geometry.size.height * 0.3)
                            }
                            .frame(height: 200)
                        }
                        .padding(.horizontal)
                        
                        // Day labels
                        HStack {
                            ForEach(["Thu", "Fri", "Sat", "Sun", "Mon", "Tue", "Wed"], id: \.self) { day in
                                Text(day)
                                    .font(.caption)
                                    .foregroundColor(day == "Fri" ? .blue : .secondary)
                                    .frame(maxWidth: .infinity)
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    Text("By picking the perfect injection day, you can boost your long-term GLP-1 effectiveness by as much as 3x.")
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 30)
                        .padding(.top, 20)
                    
                    Spacer(minLength: 40)
                }
            }
            
            Button {
                onContinue()
            } label: {
                Text("Continue")
                    .font(.headline)
                    .bold()
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.black)
                    .foregroundColor(.white)
                    .cornerRadius(16)
            }
            .padding([.horizontal, .bottom])
        }
        .navigationBarBackButtonHidden()
    }
}




// MARK: - Rating View

private struct RatingView: View {
    let onContinue: () -> Void
    
    @State private var hasRequestedRating = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            OnboardingHeaderView(progress: 0.99)
            
            VStack(spacing: 30) {
                Text("Give us a rating")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.white)
                    .padding(.top, 40)
                
                // 5 star rating display
                HStack(spacing: 8) {
                    ForEach(0..<5) { _ in
                        Image(systemName: "star.fill")
                            .foregroundColor(.purple)
                            .font(.title)
                    }
                }
                
                Spacer()
                
                // Testimonials section
                VStack(spacing: 16) {
                    TestimonialCard(
                        name: "Olivia, 34",
                        text: "I was nervous about starting GLP-1, but MeAgain made it so much easier. I've lost 10lbs in 2 months and I feel so much better."
                    )
                    
                    TestimonialCard(
                        name: "Taylor, 25", 
                        text: "After 3 months on GLP-1 I hit a plateau. MeAgain helped me break through it. thx"
                    )
                    
                    TestimonialCard(
                        name: "Jordan, 31",
                        text: "Even on bad days, MeAgain reminds me why I started and keeps me going. I finally believe I can do this."
                    )
                }
                
                Spacer()
                
                // Bottom message
                HStack {
                    Image(systemName: "leaf")
                        .foregroundColor(.white)
                    VStack {
                        Text("We are a small team trying to")
                        Text("build the best GLP-1 app, so a")
                        Text("rating goes a really long way!")
                    }
                    .font(.subheadline)
                    .foregroundColor(.white)
                    Image(systemName: "leaf")
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                // Button that changes from "Give us a rating" to "Continue"
                Button {
                    if hasRequestedRating {
                        onContinue()
                    } else {
                        requestAppStoreRating()
                    }
                } label: {
                    Text(hasRequestedRating ? "Continue" : "Give us a rating")
                        .font(.headline)
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            hasRequestedRating ? 
                            LinearGradient(
                                gradient: Gradient(colors: [.white, .white]),
                                startPoint: .leading,
                                endPoint: .trailing
                            ) :
                            LinearGradient(
                                gradient: Gradient(colors: [.purple, .pink]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .foregroundColor(hasRequestedRating ? .black : .white)
                        .cornerRadius(16)
                }
                .padding([.horizontal, .bottom])
            }
        }
        .background(Color.black)
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(.white)
                }
            }
        }
    }
    
    private func requestAppStoreRating() {
        if #available(iOS 18.0, *) {
            // Use newer API for iOS 18+
            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                // Note: AppStore.requestReview(in:) would be used here when available
                SKStoreReviewController.requestReview(in: scene)
            }
        } else {
            // Use legacy API for earlier iOS versions
            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                SKStoreReviewController.requestReview(in: scene)
            }
        }
        
        // Update state to show Continue button
        hasRequestedRating = true
    }
}

private struct TestimonialCard: View {
    let name: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            // Placeholder for profile picture
            Circle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 50, height: 50)
                .overlay(
                    Image(systemName: "person.fill")
                        .foregroundColor(.gray)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(name)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    // 5 star rating
                    HStack(spacing: 2) {
                        ForEach(0..<5) { _ in
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                                .font(.caption)
                        }
                    }
                }
                
                Text("\"\(text)\"")
                    .font(.body)
                    .foregroundColor(.white.opacity(0.9))
            }
            
            Spacer()
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

// MARK: - Motivation View

private struct MotivationView: View {
    @EnvironmentObject var viewModel: OnboardingViewModel
    let onContinue: () -> Void
    
    @State private var selectedMotivation: String? = nil
    @State private var showingCustomInput = false
    
    private let motivationOptions = [
        "I want to feel more confident in my own skin.",
        "I'm just ready for a fresh start.",
        "I want to boost my energy and strength.",
        "To improve my health and manage PCOS.",
        "I want to show up for the people I love.",
        "I have a special event or milestone coming up.",
        "To feel good wearing the clothes I love again."
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            OnboardingHeaderView(progress: 0.985)
            
            VStack(alignment: .leading, spacing: 16) {
                Text("What's driving you to reach your goal?")
                    .font(.largeTitle)
                    .bold()
                    .padding(.top)
                
                Text("I want to do this because...")
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal)
            
            Spacer()
            
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(motivationOptions, id: \.self) { option in
                        OnboardingSelectionButton(
                            title: option,
                            isSelected: selectedMotivation == option
                        ) {
                            selectedMotivation = option
                        }
                    }
                    
                    // Other option
                    OnboardingSelectionButton(
                        title: "Other",
                        isSelected: selectedMotivation != nil && !motivationOptions.contains(selectedMotivation!)
                    ) {
                        showingCustomInput = true
                    }
                }
                .padding(.horizontal)
            }
            
            Spacer()
            
            Button {
                // Save the motivation
                viewModel.motivation = selectedMotivation
                onContinue()
            } label: {
                Text("Continue")
                    .font(.headline)
                    .bold()
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(selectedMotivation == nil ? Color(uiColor: .systemGray3) : Color.black)
                    .foregroundColor(.white)
                    .cornerRadius(16)
            }
            .disabled(selectedMotivation == nil)
            .padding([.horizontal, .bottom])
        }
        .navigationBarBackButtonHidden()
        .sheet(isPresented: $showingCustomInput) {
            CustomValueInputView(
                title: "What motivates you?",
                placeholder: "Enter your motivation",
                keyboardType: .default,
                additionalOptions: [
                    "I want to be a role model for my family.",
                    "To regain control over my eating habits.",
                    "I want to improve my mental health.",
                    "To feel comfortable in social situations again.",
                    "I want to live a longer, healthier life."
                ]
            ) { customMotivation in
                selectedMotivation = customMotivation
            }
        }
    }
}

// MARK: - Notification Permission View

private struct NotificationPermissionView: View {
    let onContinue: () -> Void
    
    @State private var animateElements = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            // Black background like rating slide
            Color.black
                .ignoresSafeArea()
            
            
            VStack(alignment: .leading, spacing: 0) {
                OnboardingHeaderView(progress: 0.995)
                
                VStack(alignment: .center, spacing: 32) {
                    // Hero section
                    VStack(spacing: 20) {
                        // Large notification bell icon
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [.purple, .pink]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 100, height: 100)
                                .shadow(color: Color.purple.opacity(0.4), radius: 25, x: 0, y: 12)
                            
                            Image(systemName: "bell.badge.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.white)
                        }
                        .opacity(animateElements ? 1.0 : 0.0)
                        
                        VStack(spacing: 12) {
                            Text("Stay on track with smart reminders")
                                .font(.largeTitle)
                                .bold()
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                            
                            Text("Get personalized notifications to help you reach your goals faster.")
                                .font(.body)
                                .foregroundColor(.white.opacity(0.7))
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)
                    
                    Spacer()
                    
                    // Benefits with staggered animation
                    VStack(spacing: 16) {
                        NotificationBenefitRow(
                            icon: "bell.badge",
                            title: "Daily Check-ins",
                            description: "Gentle reminders to log your meals and progress",
                            color: .purple,
                            delay: 0.2
                        )
                        
                        NotificationBenefitRow(
                            icon: "target",
                            title: "Goal Tracking", 
                            description: "Celebrate milestones and stay motivated",
                            color: .purple,
                            delay: 0.4
                        )
                        
                        NotificationBenefitRow(
                            icon: "lightbulb",
                            title: "Personalized Tips",
                            description: "Custom advice based on your GLP-1 journey",
                            color: .purple,
                            delay: 0.6
                        )
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    // Buttons with animation
                    VStack(spacing: 16) {
                        Button {
                            requestNotificationPermission()
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "bell.fill")
                                Text("Enable Notifications")
                                    .fontWeight(.semibold)
                            }
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [.purple, .pink]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .foregroundColor(.white)
                            .cornerRadius(16)
                            .shadow(color: Color.purple.opacity(0.3), radius: 12, x: 0, y: 6)
                        }
                        
                        Button {
                            onContinue()
                        } label: {
                            Text("Maybe Later")
                                .font(.body)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                                .padding(.vertical, 8)
                        }
                    }
                    .padding([.horizontal, .bottom])
                }
            }
        }
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(.white)
                }
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.2)) {
                animateElements = true
            }
        }
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                onContinue()
            }
        }
    }
}

private struct NotificationBenefitRow: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    let delay: Double
    
    @State private var isVisible = false
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 44, height: 44)
                
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.body)
                    .foregroundColor(.white.opacity(0.7))
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.1))
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
        .opacity(isVisible ? 1.0 : 0.0)
        .onAppear {
            withAnimation(.easeOut(duration: 0.3).delay(delay * 0.5)) {
                isVisible = true
            }
        }
    }
}

// MARK: - Completion View

private struct CompletionView: View {
    let onContinue: () -> Void
    
    @State private var animateContent = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            // Black background like rating slide
            Color.black
                .ignoresSafeArea()
            
            
            VStack(spacing: 0) {
                // Custom progress bar at 100%
                VStack(spacing: 0) {
                    HStack {
                        Spacer()
                    }
                    .frame(height: 4)
                    .background(Color.white)
                    .padding(.horizontal)
                    .padding(.top, 8)
                    .scaleEffect(x: animateContent ? 1.0 : 0.0, anchor: .leading)
                }
                
                VStack(spacing: 40) {
                    Spacer()
                    
                    // Success animation area
                    VStack(spacing: 32) {
                        // Animated checkmark with rings
                        ZStack {
                            // Single ring - purple
                            Circle()
                                .stroke(Color.purple.opacity(0.4), lineWidth: 3)
                                .frame(width: 110, height: 110)
                                .opacity(animateContent ? 1.0 : 0.0)
                            
                            // Main circle with purple gradient
                            Circle()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [.purple, .pink]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 85, height: 85)
                                .shadow(color: Color.purple.opacity(0.5), radius: 25, x: 0, y: 10)
                                .scaleEffect(animateContent ? 1.0 : 0.8)
                            
                            // Checkmark with animation
                            Image(systemName: "checkmark")
                                .font(.system(size: 38, weight: .bold))
                                .foregroundColor(.white)
                                .scaleEffect(animateContent ? 1.0 : 0.0)
                        }
                        
                        // Text with staggered animation
                        VStack(spacing: 12) {
                            HStack(spacing: 8) {
                                Text("All done!")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .opacity(animateContent ? 1.0 : 0.0)
                                
                                Text("🎉")
                                    .font(.title)
                                    .opacity(animateContent ? 1.0 : 0.0)
                            }
                            
                            Text("Thank you for trusting us")
                                .font(.largeTitle)
                                .bold()
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .opacity(animateContent ? 1.0 : 0.0)
                        }
                    }
                    
                    // Subtitle with delay
                    Text("Let's create the perfect Plan for you.")
                        .font(.title3)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .opacity(animateContent ? 1.0 : 0.0)
                    
                    // Animated feature highlights
                    VStack(spacing: 20) {
                        FeatureHighlight(
                            icon: "target",
                            text: "Personalized GLP-1 guidance",
                            color: .white,
                            delay: 0.0
                        )
                        
                        FeatureHighlight(
                            icon: "chart.line.uptrend.xyaxis",
                            text: "Track your progress daily",
                            color: .white,
                            delay: 0.2
                        )
                        
                        FeatureHighlight(
                            icon: "heart.fill",
                            text: "Reach your dream weight",
                            color: .white,
                            delay: 0.4
                        )
                    }
                    .padding(.horizontal, 30)
                    .opacity(animateContent ? 1.0 : 0.0)
                    
                    Spacer()
                    
                    // Animated button
                    Button {
                        onContinue()
                    } label: {
                        HStack(spacing: 12) {
                            Text("Create My Plan")
                                .font(.headline)
                                .fontWeight(.bold)
                            
                            Image(systemName: "arrow.right.circle.fill")
                                .font(.title3)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [.purple, .pink]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .foregroundColor(.white)
                        .cornerRadius(20)
                        .shadow(color: Color.purple.opacity(0.4), radius: 15, x: 0, y: 8)
                    }
                    .opacity(animateContent ? 1.0 : 0.0)
                    .padding([.horizontal, .bottom])
                }
            }
        }
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(.white)
                }
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                animateContent = true
            }
        }
    }
}

private struct FeatureHighlight: View {
    let icon: String
    let text: String
    let color: Color
    let delay: Double
    
    @State private var isVisible = false
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
            }
            
            Text(text)
                .font(.body)
                .fontWeight(.medium)
                .foregroundColor(.white)
            
            Spacer()
            
            Image(systemName: "checkmark.circle.fill")
                .font(.title3)
                .foregroundColor(.white.opacity(0.8))
                .scaleEffect(isVisible ? 1.0 : 0.0)
        }
        .padding(.vertical, 8)
        .opacity(isVisible ? 1.0 : 0.0)
        .onAppear {
            withAnimation(.easeOut(duration: 0.4).delay(delay + 0.8)) {
                isVisible = true
            }
        }
    }
}

// MARK: - Personal Plan View
private struct PersonalPlanView: View {
    let viewModel: OnboardingViewModel
    let onContinue: () -> Void
    
    @State private var animateContent = false
    @State private var selectedWeek = 0
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            // Gradient background matching app theme
            LinearGradient(
                gradient: Gradient(colors: [Color.black, Color.purple.opacity(0.3)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 12) {
                    Text("Your Personal Plan")
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(.white)
                    
                    Text("Based on your goals and preferences")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(.top, 60)
                .opacity(animateContent ? 1.0 : 0.0)
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Weight Goal Card
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: "target")
                                    .font(.title2)
                                    .foregroundColor(.purple)
                                
                                Text("Weight Goal")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                Spacer()
                            }
                            
                            HStack(alignment: .bottom, spacing: 20) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Current")
                                    	.font(.caption)
                                        .foregroundColor(.white.opacity(0.6))
                                    Text(formatWeight(viewModel.currentWeight ?? 0))
                                        .font(.title2)
                                        .bold()
                                        .foregroundColor(.white)
                                }
                                
                                Image(systemName: "arrow.right")
                                    .foregroundColor(.purple)
                                    .font(.title3)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Goal")
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.6))
                                    Text(formatWeight(viewModel.dreamWeight ?? 0))
                                        .font(.title2)
                                        .bold()
                                        .foregroundColor(.green)
                                }
                                
                                Spacer()
                                
                                VStack(alignment: .trailing, spacing: 4) {
                                    Text("Total Loss")
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.6))
                                    let totalLoss = (viewModel.currentWeight ?? 0) - (viewModel.dreamWeight ?? 0)
                                    Text(formatWeight(totalLoss))
                                        .font(.title3)
                                        .bold()
                                        .foregroundColor(.pink)
                                }
                            }
                            
                            // Estimated timeline
                            HStack {
                                Image(systemName: "calendar")
                                    .font(.caption)
                                    .foregroundColor(.purple.opacity(0.8))
                                Text("Estimated: \(estimatedWeeks()) weeks")
                                    .font(.footnote)
                                    .foregroundColor(.white.opacity(0.7))
                            }
                            .padding(.top, 4)
                        }
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(16)
                        .opacity(animateContent ? 1.0 : 0.0)
                        
                        // Medication Schedule Card
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: "syringe")
                                    .font(.title2)
                                    .foregroundColor(.blue)
                                
                                Text("Medication Schedule")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                Spacer()
                            }
                            
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text("Medication:")
                                        .font(.subheadline)
                                        .foregroundColor(.white.opacity(0.7))
                                    Text(viewModel.medication ?? "Not selected")
                                        .font(.subheadline)
                                        .bold()
                                        .foregroundColor(.white)
                                }
                                
                                if let dose = viewModel.dose, dose > 0 {
                                    HStack {
                                        Text("Current Dose:")
                                            .font(.subheadline)
                                            .foregroundColor(.white.opacity(0.7))
                                        Text("\(String(format: "%.2f", dose)) mg")
                                            .font(.subheadline)
                                            .bold()
                                            .foregroundColor(.white)
                                    }
                                }
                                
                                HStack {
                                    Text("Frequency:")
                                        .font(.subheadline)
                                        .foregroundColor(.white.opacity(0.7))
                                    Text(frequencyText())
                                        .font(.subheadline)
                                        .bold()
                                        .foregroundColor(.white)
                                }
                                
                                if let lastShot = viewModel.lastShotDate {
                                    HStack {
                                        Text("Next Shot:")
                                            .font(.subheadline)
                                            .foregroundColor(.white.opacity(0.7))
                                        Text(nextShotDate(from: lastShot))
                                            .font(.subheadline)
                                            .bold()
                                            .foregroundColor(.green)
                                    }
                                }
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(16)
                        .opacity(animateContent ? 1.0 : 0.0)
                        .animation(.easeOut(duration: 0.5).delay(0.2), value: animateContent)
                        
                        // Weekly Progress Preview
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: "chart.line.uptrend.xyaxis")
                                    .font(.title2)
                                    .foregroundColor(.green)
                                
                                Text("Your Progress Path")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                Spacer()
                            }
                            
                            // Week selector
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(0..<8) { week in
                                        Button {
                                            withAnimation(.easeOut(duration: 0.2)) {
                                                selectedWeek = week
                                            }
                                        } label: {
                                            VStack(spacing: 4) {
                                                Text("Week")
                                                    .font(.caption2)
                                                Text("\(week + 1)")
                                                    .font(.headline)
                                            }
                                            .foregroundColor(selectedWeek == week ? .black : .white)
                                            .frame(width: 60, height: 50)
                                            .background(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .fill(selectedWeek == week ? Color.white : Color.white.opacity(0.2))
                                            )
                                        }
                                    }
                                }
                            }
                            
                            // Expected progress for selected week
                            VStack(alignment: .leading, spacing: 8) {
                                let expectedWeight = calculateExpectedWeight(week: selectedWeek)
                                HStack {
                                    Text("Expected Weight:")
                                        .font(.subheadline)
                                        .foregroundColor(.white.opacity(0.7))
                                    Text(formatWeight(expectedWeight))
                                        .font(.subheadline)
                                        .bold()
                                        .foregroundColor(.white)
                                }
                                
                                let progressPercent = calculateProgressPercent(week: selectedWeek)
                                HStack {
                                    Text("Progress:")
                                        .font(.subheadline)
                                        .foregroundColor(.white.opacity(0.7))
                                    Text("\(Int(progressPercent))% to goal")
                                        .font(.subheadline)
                                        .bold()
                                        .foregroundColor(.green)
                                }
                                
                                // Progress bar
                                GeometryReader { geometry in
                                    ZStack(alignment: .leading) {
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(Color.white.opacity(0.2))
                                            .frame(height: 8)
                                        
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(
                                                LinearGradient(
                                                    gradient: Gradient(colors: [.green, .blue]),
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                )
                                            )
                                            .frame(width: geometry.size.width * progressPercent / 100, height: 8)
                                    }
                                }
                                .frame(height: 8)
                                .padding(.top, 4)
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(16)
                        .opacity(animateContent ? 1.0 : 0.0)
                        .animation(.easeOut(duration: 0.5).delay(0.4), value: animateContent)
                        
                        // Personalized Tips
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: "lightbulb.fill")
                                    .font(.title2)
                                    .foregroundColor(.yellow)
                                
                                Text("Your Personalized Tips")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                Spacer()
                            }
                            
                            VStack(alignment: .leading, spacing: 12) {
                                ForEach(getPersonalizedTips(), id: \.self) { tip in
                                    HStack(alignment: .top, spacing: 12) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.caption)
                                            .foregroundColor(.green)
                                            .padding(.top, 2)
                                        
                                        Text(tip)
                                            .font(.subheadline)
                                            .foregroundColor(.white.opacity(0.9))
                                            .fixedSize(horizontal: false, vertical: true)
                                        
                                        Spacer()
                                    }
                                }
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(16)
                        .opacity(animateContent ? 1.0 : 0.0)
                        .animation(.easeOut(duration: 0.5).delay(0.6), value: animateContent)
                    }
                    .padding()
                }
                
                // CTA Button
                Button {
                    onContinue()
                } label: {
                    HStack {
                        Text("Unlock My Full Plan")
                            .font(.headline)
                            .bold()
                        
                        Image(systemName: "lock.open.fill")
                            .font(.title3)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [.purple, .pink]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .foregroundColor(.white)
                    .cornerRadius(16)
                    .shadow(color: .purple.opacity(0.3), radius: 10, y: 5)
                }
                .padding()
                .opacity(animateContent ? 1.0 : 0.0)
                .animation(.easeOut(duration: 0.5).delay(0.8), value: animateContent)
            }
        }
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(.white)
                }
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                animateContent = true
            }
        }
    }
    
    // Helper functions
    private func formatWeight(_ weight: Double) -> String {
        if viewModel.useMetric {
            return String(format: "%.1f kg", weight)
        } else {
            let lbs = weight * 2.20462
            return String(format: "%.0f lbs", lbs)
        }
    }
    
    private func estimatedWeeks() -> Int {
        guard let current = viewModel.currentWeight,
              let goal = viewModel.dreamWeight else { return 12 }
        
        let totalToLose = current - goal
        let weeklyLoss = viewModel.useMetric ? 0.5 : 1.1 // kg or lbs per week
        return max(4, Int(totalToLose / weeklyLoss))
    }
    
    private func frequencyText() -> String {
        guard let frequency = viewModel.shotFrequency else {
            return "Not set"
        }
        
        switch frequency {
        case 7:
            return "Weekly"
        case 14:
            return "Bi-weekly"
        case 30:
            return "Monthly"
        default:
            return "Every \(frequency) days"
        }
    }
    
    private func nextShotDate(from lastShot: Date) -> String {
        guard let frequency = viewModel.shotFrequency else {
            return "Not set"
        }
        
        let nextDate = Calendar.current.date(byAdding: .day, value: frequency, to: lastShot) ?? Date()
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: nextDate)
    }
    
    private func calculateExpectedWeight(week: Int) -> Double {
        guard let current = viewModel.currentWeight else { return 0 }
        
        let weeklyLoss = viewModel.useMetric ? 0.5 : 1.1
        return max(viewModel.dreamWeight ?? 0, current - (weeklyLoss * Double(week + 1)))
    }
    
    private func calculateProgressPercent(week: Int) -> Double {
        guard let current = viewModel.currentWeight,
              let goal = viewModel.dreamWeight else { return 0 }
        
        let totalToLose = current - goal
        let expectedLoss = (viewModel.useMetric ? 0.5 : 1.1) * Double(week + 1)
        let actualProgress = min(expectedLoss, totalToLose)
        
        return totalToLose > 0 ? (actualProgress / totalToLose) * 100 : 0
    }
    
    private func getPersonalizedTips() -> [String] {
        var tips: [String] = []
        
        // Activity-based tips
        if let activity = viewModel.activityLevelString {
            if activity.contains("Sedentary") {
                tips.append("Start with 10-minute walks after meals to boost your metabolism")
            } else if activity.contains("Very Active") {
                tips.append("Maintain your exercise routine but listen to your body as you adjust to the medication")
            }
        }
        
        // Medication-based tips
        if let med = viewModel.medication {
            if med.contains("Ozempic") || med.contains("Wegovy") {
                tips.append("Take your weekly shot on the same day for best results")
            }
        }
        
        // Goal-based tips
        if viewModel.fitnessGoal == .loseWeight {
            tips.append("Focus on protein intake to preserve muscle mass during weight loss")
        }
        
        // Generic helpful tips
        tips.append("Stay hydrated - aim for 8 glasses of water daily")
        tips.append("Track your progress with weekly photos and measurements")
        
        return Array(tips.prefix(4))
    }
}

extension Color {
    static var random: Color {
        Color(
            red: Double.random(in: 0.3...1),
            green: Double.random(in: 0.3...1),
            blue: Double.random(in: 0.3...1)
        )
    }
}

// MARK: - Custom Toggle Style

struct BlackWhiteToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.black)
                .frame(width: 50, height: 30)
                .overlay(
                    Circle()
                        .fill(Color.white)
                        .frame(width: 26, height: 26)
                        .offset(x: configuration.isOn ? 10 : -10)
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isOn)
                )
                .onTapGesture {
                    configuration.isOn.toggle()
                }
        }
    }
}
