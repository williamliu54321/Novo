import SwiftUI

// This view is now self-contained and much smarter.
struct OnboardingSingleSelectionView: View {
    @EnvironmentObject var viewModel: OnboardingViewModel
    
    // Internal properties
    private let title: String
    private let subtitle: String?
    private let options: [(title: String, iconName: String?)]
    @Binding private var selection: String?
    private let nextStep: OnboardingStep
    private let progress: Double
    
    // Initializer for simple [String] options
    init(
        title: String,
        subtitle: String? = nil,
        selection: Binding<String?>,
        nextStep: OnboardingStep,
        progress: Double,
        options: [String]
    ) {
        self.title = title
        self.subtitle = subtitle
        self._selection = selection
        self.nextStep = nextStep
        self.progress = progress
        self.options = options.map { (title: $0, iconName: nil) }
    }
    
    // Initializer for options with icons
    init(
        title: String,
        subtitle: String? = nil,
        selection: Binding<String?>,
        nextStep: OnboardingStep,
        progress: Double,
        options: [(title: String, iconName: String?)]
    ) {
        self.title = title
        self.subtitle = subtitle
        self._selection = selection
        self.nextStep = nextStep
        self.progress = progress
        self.options = options
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            OnboardingHeaderView(progress: progress)
            
            // Title block stays at the top
            VStack(alignment: .leading, spacing: 16) {
                Text(title).font(.largeTitle).bold().padding(.top)
                if let subtitle = subtitle { Text(subtitle).foregroundStyle(.secondary) }
            }.padding(.horizontal)

            // Spacers push the options into the vertical center
            Spacer()
            
            VStack(spacing: 12) {
                ForEach(options, id: \.title) { option in
                    OnboardingSelectionButton(
                        iconName: option.iconName,
                        title: option.title,
                        isSelected: selection == option.title
                    ) {
                        selection = option.title
                    }
                }
            }
            .padding(.horizontal)
            
            Spacer()

            // "Continue" button stays at the bottom
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
