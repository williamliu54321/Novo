import SwiftUI

struct CustomValueInputView: View {
    // A binding to the text the user is typing.
    @Binding var customValue: String
    
    // A function to call when the user taps "Save".
    let onSave: () -> Void
    
    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                TextField("Enter custom value", text: $customValue)
                    .keyboardType(.decimalPad) // Good for dose numbers
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .focused($isTextFieldFocused)

                Button(action: onSave) {
                    Text("Save")
                        .font(.headline).bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(customValue.isEmpty ? Color.gray : Color.black)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .disabled(customValue.isEmpty)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Enter Custom Dose")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                isTextFieldFocused = true
            }
        }
    }
}
