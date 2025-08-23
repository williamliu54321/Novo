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
    private let customInputTitle: String

    // State for managing the custom input popup
    @State private var showCustomInputSheet = false
    @State private var customValueText = ""
    
    // Initializer for simple [String] options
    init(
        title: String,
        subtitle: String? = nil,
        selection: Binding<String?>,
        nextStep: OnboardingStep,
        progress: Double,
        options: [String],
        customInputTitle: String = "Enter Custom Value"
    ) {
        self.title = title
        self.subtitle = subtitle
        self._selection = selection
        self.nextStep = nextStep
        self.progress = progress
        self.options = options.map { (title: $0, iconName: nil) }
        self.customInputTitle = customInputTitle
    }

    // Initializer for options with icons
    init(
        title: String,
        subtitle: String? = nil,
        selection: Binding<String?>,
        nextStep: OnboardingStep,
        progress: Double,
        options: [(title: String, iconName: String?)],
        customInputTitle: String = "Enter Custom Value"
    ) {
        self.title = title
        self.subtitle = subtitle
        self._selection = selection
        self.nextStep = nextStep
        self.progress = progress
        self.options = options
        self.customInputTitle = customInputTitle
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
                    // This special button appears ONLY if a custom value has been entered.
                    // It shows the user's custom choice and allows them to edit it.
                    if let selection = selection, !isPredefined(option: selection) {
                        OnboardingSelectionButton(
                            iconName: nil, // Custom values don't have icons
                            title: selection,
                            isSelected: true // It's always selected when it's visible
                        ) {
                            // Tapping the custom value button re-opens the popup to edit.
                            self.customValueText = selection
                            self.showCustomInputSheet = true
                        }
                    }
                    
                    // Loop through the predefined, hardcoded options.
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
            CustomValueInputView(
                title: customInputTitle,
                text: $customValueText,
                onSave: {
                    // When the user saves, update the main selection and dismiss the sheet.
                    self.selection = customValueText
                    self.showCustomInputSheet = false
                }
            )
        }
    }

    /// Handles the logic for tapping any button.
    private func handleSelection(for optionTitle: String) {
        if optionTitle.lowercased() == "custom" {
            // If the user taps "Custom", prepare the sheet and show it.
            // If a custom value was already entered, pre-fill the text field.
            customValueText = (selection != nil && !isPredefined(option: selection!)) ? selection! : ""
            showCustomInputSheet = true
        } else {
            // For any normal option, just update the selection.
            selection = optionTitle
        }
    }
    
    /// Checks if the selected value is one of the predefined options (excluding "Custom").
    private func isPredefined(option: String) -> Bool {
        return options.map(\.title).contains(option)
    }
}

#Preview {
    // A simple wrapper view is the best practice for previewing components with bindings.
    struct PreviewWrapper: View {
        // This @State variable will be passed as a Binding to the component,
        // allowing for interactive previews. We start with `nil` for no selection.
        @State private var selection: String? = nil

        var body: some View {
            // The component must be inside a NavigationStack for its NavigationLink to work.
            NavigationStack {
                OnboardingSingleSelectionView(
                    title: "What's your current dose?",
                    subtitle: "Select one of the options below to continue.",
                    selection: $selection,
                    nextStep: .activity, // A dummy value for the preview
                    progress: 0.4,
                    options: ["0.25 mg", "0.5 mg", "1.0 mg", "1.7 mg", "2.4 mg", "Custom"],
                    customInputTitle: "Enter Custom Dose"
                )
                // Provide a dummy viewModel, as the view expects one in its environment.
                .environmentObject(OnboardingViewModel())
            }
        }
    }
    
    // Return the wrapper view to be displayed in the Xcode canvas.
    return PreviewWrapper()
}
