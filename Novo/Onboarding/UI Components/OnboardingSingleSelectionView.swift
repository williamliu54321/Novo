// In OnboardingSingleSelectionView.swift
import SwiftUI

// --- The Generic, Reusable Component ---
struct OnboardingSingleSelectionView<SelectionValue: Hashable>: View {
    // Environment Dependencies
    @EnvironmentObject var viewModel: OnboardingViewModel
    @Environment(\.dismiss) private var dismiss

    // --- Generic Properties ---
    private let title: String
    private let subtitle: String?
    private let options: [(title: String, value: SelectionValue)] // Connects display text to data
    @Binding private var selection: SelectionValue?               // Binds to ANY hashable type
    private let nextStep: OnboardingStep
    private let progress: Double
    
    // --- Closures for Customization and Conversion ---
    private let customButtonTitle: String?
    private let valueToString: (SelectionValue) -> String     // Formats a value for display (e.g., 0.25 -> "0.25mg")
    private let stringToValue: ((String) -> SelectionValue?)? // Converts popup text to a value (e.g., "0.25" -> 0.25)
    
    // State for managing the popup
    @State private var showCustomInputSheet = false

    init(
        title: String,
        subtitle: String? = nil,
        selection: Binding<SelectionValue?>,
        nextStep: OnboardingStep,
        progress: Double,
        options: [(title: String, value: SelectionValue)],
        customButtonTitle: String? = "Custom",
        valueToString: @escaping (SelectionValue) -> String,
        stringToValue: ((String) -> SelectionValue?)? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self._selection = selection
        self.nextStep = nextStep
        self.progress = progress
        self.options = options
        self.customButtonTitle = customButtonTitle
        self.valueToString = valueToString
        self.stringToValue = stringToValue
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            OnboardingHeaderView(progress: progress)
            
            VStack(alignment: .leading, spacing: 16) {
                Text(title).font(.largeTitle).bold().padding(.top)
                if let subtitle = subtitle { Text(subtitle).foregroundStyle(.secondary) }
            }.padding(.horizontal)

            Spacer()
            
            ScrollView {
                VStack(spacing: 12) {
                    // Display a button for a custom-entered value if it exists.
                    if let selection = selection, !isPredefined(value: selection) {
                        OnboardingSelectionButton(
                            title: valueToString(selection), // Use the formatting closure
                            isSelected: true
                        ) {
                            showCustomInputSheet = true
                        }
                    }
                    
                    // Loop through the predefined options.
                    ForEach(options, id: \.value) { option in
                        OnboardingSelectionButton(
                            title: option.title,
                            isSelected: selection == option.value
                        ) {
                            self.selection = option.value
                        }
                    }
                    
                    // Show the "Custom" button only if a conversion closure was provided.
                    if let customButtonTitle = customButtonTitle, stringToValue != nil {
                        OnboardingSelectionButton(
                            title: customButtonTitle,
                            isSelected: false // The "Custom" button is never the selected state
                        ) {
                            showCustomInputSheet = true
                        }
                    }
                }
            }
            .padding(.horizontal)
            
            Spacer()

            NavigationLink(value: nextStep) {
                Text("Continue")
                    .font(.headline).fontWeight(.bold)
                    .frame(maxWidth: .infinity, minHeight: 44)
                    .padding()
                    .background(selection == nil ? Color(uiColor: .systemGray3) : Color.black)
                    .foregroundColor(.white)
                    .cornerRadius(16)
            }
            .disabled(selection == nil)
            .padding([.horizontal, .bottom])
        }
        .navigationBarBackButtonHidden()
        .sheet(isPresented: $showCustomInputSheet) {
            // The popup view itself remains simple.
            CustomValueInputView(
                title: "Enter Custom Value",
                placeholder: "Enter value",
                keyboardType: .default,
                additionalOptions: [],
                onSave: { textInput in
                    // Use the conversion closure to turn the String into our SelectionValue.
                    if let value = stringToValue?(textInput) {
                        self.selection = value
                    }
                }
            )
        }
    }
    
    /// Checks if the selected value is one of the predefined options.
    private func isPredefined(value: SelectionValue) -> Bool {
        return options.map(\.value).contains(value)
    }
}

// --- Convenience Initializer for simple String selections ---
// This makes using the component for simple text much easier.
extension OnboardingSingleSelectionView where SelectionValue == String {
    init(
        title: String,
        subtitle: String? = nil,
        selection: Binding<String?>,
        nextStep: OnboardingStep,
        progress: Double,
        options: [String],
        customInputEnabled: Bool = false
    ) {
        self.init(
            title: title,
            subtitle: subtitle,
            selection: selection,
            nextStep: nextStep,
            progress: progress,
            options: options.map { (title: $0, value: $0) }, // Title and value are the same
            customButtonTitle: customInputEnabled ? "Custom" : nil,
            valueToString: { $0 },      // A String is already a string
            stringToValue: { $0 }       // A String is already a string
        )
    }
}


#Preview {
    struct PreviewWrapper: View {
        @State private var selectedDose: Double? = 1.0
        @State private var selectedMedication: String? = "Zepbound®"

        var body: some View {
            NavigationStack {
                VStack(spacing: 40) {
                    
                    // --- EXAMPLE 1: Using the component for the Double `dose` ---
                    OnboardingSingleSelectionView(
                        title: "What's your current dose?",
                        selection: $selectedDose,
                        nextStep: .activity,
                        progress: 0.4,
                        options: [
                            (title: "0.25mg", value: 0.25),
                            (title: "0.5mg", value: 0.5),
                            (title: "1.0mg", value: 1.0)
                        ],
                        valueToString: { doseValue in
                            // Formatter for clean display (e.g., "1mg" not "1.0mg")
                            let formatter = NumberFormatter()
                            formatter.minimumFractionDigits = 0
                            formatter.maximumFractionDigits = 3
                            let numString = formatter.string(from: NSNumber(value: doseValue)) ?? "\(doseValue)"
                            return "\(numString)mg"
                        },
                        stringToValue: { textInput in
                            // Tries to convert "0.25" into the Double 0.25
                            return Double(textInput)
                        }
                    )
                    
                    Divider()
                    
                    // --- EXAMPLE 2: Using the convenience init for a simple String selection ---
                    OnboardingSingleSelectionView(
                        title: "Which medication?",
                        selection: $selectedMedication,
                        nextStep: .dose,
                        progress: 0.2,
                        options: ["Zepbound®", "Wegovy®"]
                        // No custom option needed here, so we don't pass `customInputEnabled`
                    )
                }
                .environmentObject(OnboardingViewModel())
            }
        }
    }
    
    return PreviewWrapper()
}
