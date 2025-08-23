// In CustomValueInputView.swift

import SwiftUI

/// A generalized, reusable popup sheet for entering a custom text value.
/// It can be configured with a title, placeholder, keyboard type, and additional options.
struct CustomValueInputView: View {
    // --- Configuration Properties (passed from parent) ---
    let title: String
    let placeholder: String
    let keyboardType: UIKeyboardType
    let additionalOptions: [String]
    let onSave: (String) -> Void
    
    // --- Internal State ---
    @State private var customText = ""
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 0) {
                // Custom Text Input Section
                HStack {
                    TextField(placeholder, text: $customText)
                        .keyboardType(keyboardType)
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

                // List of Additional Options
                List(additionalOptions, id: \.self) { option in
                    Button(action: {
                        saveAndDismiss(value: option)
                    }) {
                        Text(option)
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
                }
                .listStyle(.plain)
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if !customText.isEmpty {
                            saveAndDismiss(value: customText)
                        }
                    }
                    .disabled(customText.isEmpty)
                }
            }
            .onAppear {
                isTextFieldFocused = true
            }
        }
    }
    
    private func saveAndDismiss(value: String) {
        onSave(value)
        dismiss()
    }
}
