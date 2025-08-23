// In CustomDosageInputView.swift

import SwiftUI

/// A popup sheet that matches the design for entering a custom dosage.
struct CustomDosageInputView: View {
    // A list of extra, less common options to show in the sheet.
    let additionalOptions: [String]
    
    // The callback to send the final selected value back to the parent.
    let onSave: (String) -> Void
    
    // Local state for the text field.
    @State private var customText = ""
    
    // For programmatic dismissal.
    @Environment(\.dismiss) private var dismiss
    
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 0) {
                // --- 1. Custom Text Input Section ---
                HStack {
                    TextField("Enter Custom Dosage", text: $customText)
                        .keyboardType(.decimalPad)
                        .submitLabel(.done)
                    
                    Button("Add") {
                        if !customText.isEmpty {
                            saveAndDismiss(value: customText)
                        }
                    }
                    .fontWeight(.semibold)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color(.systemGray5))
                    .foregroundColor(.primary)
                    .cornerRadius(8)
                }
                .padding(.leading, 16)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding()

                // --- 2. List of Additional Options ---
                List(additionalOptions, id: \.self) { option in
                    Button(action: {
                        saveAndDismiss(value: option)
                    }) {
                        Text(option)
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
                }
                .listStyle(.plain)
            }
            .navigationTitle("Dosage")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // The "Save" button in the top right.
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if !customText.isEmpty {
                            saveAndDismiss(value: customText)
                        }
                    }
                    // The Save button is only active if the user has typed something.
                    .disabled(customText.isEmpty)
                }
            }
            .onAppear {
                isTextFieldFocused = true
            }
        }
    }
    
    /// A helper function to centralize the action of saving and dismissing.
    private func saveAndDismiss(value: String) {
        onSave(value) // Call the parent's callback
        dismiss()     // Dismiss the sheet
    }
}
