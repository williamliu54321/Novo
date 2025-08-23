import SwiftUI

// This is the content of our popup sheet.
struct CustomValueInputView: View {
    let title: String
    @Binding var text: String
    let onSave: () -> Void
    
    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                TextField("Enter value", text: $text)
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
                        .background(text.isEmpty ? Color.gray : Color.black)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .disabled(text.isEmpty)
                
                Spacer()
            }
            .padding()
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .onAppear { isTextFieldFocused = true }
        }
    }
}
