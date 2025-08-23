// In OnboardingSingleSelectionView.swift

import SwiftUI

struct OnboardingSingleSelectionView: View {
    // Environment Dependencies
    @EnvironmentObject var viewModel: OnboardingViewModel
    @Environment(\.dismiss) private var dismiss

    // Internal Properties
    private let title: String
    private let subtitle: String?
    private let options: [(title: String, iconName: String?)]
    @Binding private var selection: String?
    private let nextStep: OnboardingStep
    private let progress: Double
    
    // --- NEW: Generalized properties to configure the custom popup ---
    private let customSheetTitle: String
    private let customSheetPlaceholder: String
    private let customSheetKeyboardType: UIKeyboardType
    private let customSheetOptions: [String]

    @State private var showCustomInputSheet = false
    
    // Updated Initializer for simple [String] options
    init(
        title: String,
        subtitle: String? = nil,
        selection: Binding<String?>,
        nextStep: OnboardingStep,
        progress: Double,
        options: [String],
        customSheetTitle: String = "Enter Custom Value",
        customSheetPlaceholder: String = "Type here...",
        customSheetKeyboardType: UIKeyboardType = .default,
        customSheetOptions: [String] = []
    ) {
        self.title = title
        self.subtitle = subtitle
        self._selection = selection
        self.nextStep = nextStep
        self.progress = progress
        self.options = options.map { (title: $0, iconName: nil) }
        self.customSheetTitle = customSheetTitle
        self.customSheetPlaceholder = customSheetPlaceholder
        self.customSheetKeyboardType = customSheetKeyboardType
        self.customSheetOptions = customSheetOptions
    }

    // Updated Initializer for options with icons
    init(
        title: String,
        subtitle: String? = nil,
        selection: Binding<String?>,
        nextStep: OnboardingStep,
        progress: Double,
        options: [(title: String, iconName: String?)],
        customSheetTitle: String = "Enter Custom Value",
        customSheetPlaceholder: String = "Type here...",
        customSheetKeyboardType: UIKeyboardType = .default,
        customSheetOptions: [String] = []
    ) {
        self.title = title
        self.subtitle = subtitle
        self._selection = selection
        self.nextStep = nextStep
        self.progress = progress
        self.options = options
        self.customSheetTitle = customSheetTitle
        self.customSheetPlaceholder = customSheetPlaceholder
        self.customSheetKeyboardType = customSheetKeyboardType
        self.customSheetOptions = customSheetOptions
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
                    if let selection = selection, !isPredefined(option: selection) {
                        OnboardingSelectionButton(
                            iconName: nil,
                            title: selection,
                            isSelected: true
                        ) {
                            showCustomInputSheet = true
                        }
                    }
                    
                    ForEach(options, id: \.title) { option in
                        OnboardingSelectionButton(
                            iconName: option.iconName,
                            title: option.title,
                            isSelected: selection == option.title
                        ) {
                            handleSelection(for: option.title)
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
            // Present the new, generic custom input view.
            CustomValueInputView(
                title: customSheetTitle,
                placeholder: customSheetPlaceholder,
                keyboardType: customSheetKeyboardType,
                additionalOptions: customSheetOptions,
                onSave: { selectedValue in
                    self.selection = selectedValue
                }
            )
        }
    }

    private func handleSelection(for optionTitle: String) {
        let customKeywords: Set<String> = ["custom", "other"]
        
        if customKeywords.contains(optionTitle.lowercased()) {
            showCustomInputSheet = true
        } else {
            selection = optionTitle
        }
    }
    
    private func isPredefined(option: String) -> Bool {
        return options.map(\.title).contains(option)
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var selection: String? = nil

        var body: some View {
            NavigationStack {
                // --- EXAMPLE: Configuring for a Dosage Question ---
                OnboardingSingleSelectionView(
                    title: "What's your current dose?",
                    subtitle: "Select one of the options below.",
                    selection: $selection,
                    nextStep: .activity,
                    progress: 0.4,
                    // Main options shown on the screen
                    options: ["0.25mg", "0.5mg", "1.0mg", "2.5mg", "5.0mg", "Other"],
                    // Configuration for the generic popup sheet
                    customSheetTitle: "Dosage",
                    customSheetPlaceholder: "Enter Custom Dosage",
                    customSheetKeyboardType: .decimalPad,
                    customSheetOptions: ["0.125mg", "0.7mg", "1.7mg", "2.0mg", "2.4mg"]
                )
                .environmentObject(OnboardingViewModel())
            }
        }
    }
    
    return PreviewWrapper()
}
