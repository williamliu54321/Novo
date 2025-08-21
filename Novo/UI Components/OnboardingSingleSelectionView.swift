import SwiftUIll

struct OnboardingSingleSelectionView: View {
    @EnvironmentObject var viewModel: OnboardingViewModel
    
    let title: String
    let subtitle: String?
    let options: [String]
    @Binding var selection: String?
    let nextStep: OnboardingStep
    let progress: Double

    init(title: String, subtitle: String? = nil, options: [String], selection: Binding<String?>, nextStep: OnboardingStep, progress: Double) {
        self.title = title
        self.subtitle = subtitle
        self.options = options
        self._selection = selection
        self.nextStep = nextStep
        self.progress = progress
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) { // Using the correct layout
            OnboardingHeaderView(progress: progress)
            
            VStack(alignment: .leading, spacing: 16) {
                Text(title).font(.largeTitle).bold().padding(.top)
                if let subtitle = subtitle { Text(subtitle).foregroundStyle(.secondary) }
            }.padding(.horizontal)

            Spacer()
            
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(options, id: \.self) { option in
                        // --- THIS IS THE CHANGE ---
                        // We are now using the new unified button.
                        // Since we don't provide an `iconName`, it will just show the text.
                        OnboardingSelectionButton(
                            title: option,
                            isSelected: selection == option
                        ) {
                            selection = option
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
    }
}
