import SwiftUI
import UIKit // Needed for styling the page dots
import Foundation

enum OnboardingStep: Hashable {
    case journeyStatus
    case medication, dose, shotFrequency, benefits, gender
    case name, goal, dateOfBirth, dreamWeight, heightWeight, activity, terms
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
                    // Shot frequency selection with custom input
                    OnboardingSingleSelectionView(
                        title: "How often will you take your shots?",
                        subtitle: "Pick not sure, if you don't know yet, you'll be able to edit this later.",
                        selection: $viewModel.shotFrequency,
                        nextStep: .benefits,
                        progress: 0.5,
                        options: [
                            (title: "Every day", value: 1),
                            (title: "Every 7 days (most common)", value: 7),
                            (title: "Every 14 days", value: 14),
                            (title: "Not sure, still figuring it out", value: -1)
                        ],
                        customModalTitle: "Days between",
                        customModalPlaceholder: "Enter number of days",
                        customModalOptions: [],
                        valueToString: { frequency in // How to display an Int
                            if frequency == -1 { return "Not sure, still figuring it out" }
                            if frequency == 1 { return "Every day" }
                            return "Every \(frequency) days"
                        },
                        stringToValue: { text in // How to parse user text
                            return Int(text)
                        }
                    )

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
                        navigationPath.append(.dreamWeight)
                    }

                case .dreamWeight:
                    // Dream weight selection with interactive picker
                    DreamWeightView {
                        navigationPath.append(.heightWeight)
                    }

                case .heightWeight:
                    // Height and current weight selection
                    HeightWeightView {
                        navigationPath.append(.activity)
                    }

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
            OnboardingHeaderView(progress: 0.85)
            
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
            OnboardingHeaderView(progress: 0.9)
            
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
                    
                    VStack(spacing: 8) {
                        Text(formatHeight(selectedHeight, isMetric: viewModel.useMetric))
                            .font(.title2)
                            .bold()
                        
                        Picker("Height", selection: $selectedHeight) {
                            ForEach(getHeightValues(), id: \.self) { height in
                                Text(formatHeight(height, isMetric: viewModel.useMetric))
                                    .tag(height)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(height: 120)
                    }
                }
                
                VStack(spacing: 16) {
                    Text("Weight")
                        .font(.headline)
                    
                    VStack(spacing: 8) {
                        Text(formatWeight(selectedWeight, isMetric: viewModel.useMetric))
                            .font(.title2)
                            .bold()
                        
                        Picker("Weight", selection: $selectedWeight) {
                            ForEach(getWeightValues(), id: \.self) { weight in
                                Text(formatWeight(weight, isMetric: viewModel.useMetric))
                                    .tag(weight)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(height: 120)
                    }
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
