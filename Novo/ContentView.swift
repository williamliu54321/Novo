import SwiftUI

// MARK: - 1. Root View (App Entry Point)

struct ContentView: View {
    var body: some View {
        ZStack {
            Color(UIColor.systemGroupedBackground).edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                // The SummaryView manages all its own content and state.
                SummaryView()
                
                // The tab bar is part of the main app shell.
                CustomTabBarView()
            }
        }
    }
}

// MARK: - 2. "Smart" Summary View (Manages State)

struct SummaryView: View {
    // This state determines which summary content to show.
    @State private var hasLoggedShot = false
    
    // This state controls the presentation of the "Add Shot" modal sheet.
    @State private var isShowingAddShotSheet = false
    
    var body: some View {
        VStack(spacing: 0) {
            // The header's button will trigger the sheet.
            SummaryHeaderView(onAddShot: {
                isShowingAddShotSheet = true
            })
            .padding([.top, .horizontal])
            .padding(.bottom, 8)
            
            // The ScrollView contains the logic to switch between content views.
            ScrollView {
                if hasLoggedShot {
                    SummaryAfterShotContent()
                } else {
                    SummaryBeforeShotContent(onAddShot: {
                        isShowingAddShotSheet = true
                    })
                }
            }
        }
        // This modifier presents the AddShotView when `isShowingAddShotSheet` is true.
        .sheet(isPresented: $isShowingAddShotSheet) {
            AddShotView(
                onSave: {
                    // When the user saves, update the state and dismiss the sheet.
                    hasLoggedShot = true
                    isShowingAddShotSheet = false
                },
                onCancel: {
                    // On cancel, just dismiss the sheet.
                    isShowingAddShotSheet = false
                }
            )
        }
    }
}

// MARK: - 3. Add Shot View (Modal Sheet)

struct AddShotView: View {
    // Callbacks to the parent view (SummaryView).
    var onSave: () -> Void
    var onCancel: () -> Void
    
    // State for the form data.
    @State private var selectedDate = Date()
    @State private var timeTaken = Date()
    @State private var medicationName = "Tirzepatide"
    @State private var dosageStrength = "2.5mg"
    @State private var injectionSite = "Stomach - Upper Left"
    @State private var painLevel: Double = 0
    @State private var notes = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("DATE")) { DateSelectionView(selectedDate: $selectedDate) }
                Section(header: Text("TIME")) { TimeSelectionView(timeTaken: $timeTaken) }
                Section(header: Text("DETAILS")) {
                    DetailRow(label: "Medication Name", value: medicationName, hasCapsule: false)
                    DetailRow(label: "Dosage Strength", value: dosageStrength, hasCapsule: true)
                    DetailRow(label: "Injection Site", value: injectionSite, hasCapsule: false)
                    PainLevelRow(painLevel: $painLevel)
                }
                Section(header: Text("SHOT NOTES")) { NotesSectionView(notes: $notes) }
            }
            .navigationTitle("Add Shot")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) { Button("Cancel", action: onCancel) }
                ToolbarItem(placement: .navigationBarTrailing) { Button("Save", action: onSave).fontWeight(.bold) }
            }
        }
    }
}


// MARK: - 4. Reusable Components (Defined Only Once)

// MARK: Content Containers
private struct SummaryBeforeShotContent: View {
    var onAddShot: () -> Void
    var body: some View {
        VStack(alignment: .leading, spacing: 30) {
            ShotHistoryView()
            NextShotView()
            AddShotSectionView(onAddShot: onAddShot)
        }.padding()
    }
}

private struct SummaryAfterShotContent: View {
    var body: some View {
        VStack(spacing: 30) {
            ShotConfirmationView()
            DailyMetricsSectionView()
            ResultsSectionView()
        }.padding(.horizontal).padding(.top, 10).padding(.bottom, 30)
    }
}

// MARK: Global UI
struct SummaryHeaderView: View {
    var onAddShot: () -> Void
    var body: some View {
        HStack {
            Text("Summary").font(.largeTitle).fontWeight(.bold)
            Spacer()
            Button(action: onAddShot) { HStack(spacing: 4) { Image(systemName: "plus"); Text("Add shot") }.font(.headline.weight(.semibold)) }.foregroundColor(.blue)
        }
    }
}

struct CustomTabBarView: View {
    var body: some View {
        VStack(spacing: 0) {
            Divider()
            HStack {
                TabBarItem(iconName: "list.bullet.clipboard", title: "Summary", isSelected: true)
                TabBarItem(iconName: "syringe.fill", title: "Shots", isSelected: false)
                TabBarItem(iconName: "chart.bar.xaxis", title: "Results", isSelected: false)
                TabBarItem(iconName: "calendar", title: "Calendar", isSelected: false)
                TabBarItem(iconName: "gearshape.fill", title: "Settings", isSelected: false)
            }.padding(.top, 8).padding(.bottom, 25).background(Color(UIColor.systemGroupedBackground).edgesIgnoringSafeArea(.bottom))
        }
    }
}

struct TabBarItem: View {
    let iconName: String, title: String, isSelected: Bool
    var body: some View { VStack(spacing: 4) { Image(systemName: iconName).font(.system(size: 22)); Text(title).font(.caption) }.foregroundColor(isSelected ? .blue : .gray).frame(maxWidth: .infinity) }
}

// MARK: "Before Shot" Components
struct ShotHistoryView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Shot History").font(.title2).fontWeight(.bold)
            HStack(spacing: 12) {
                HistoryCard(iconName: "syringe", title: "Shots taken", value: "0")
                HistoryCard(iconName: "doc.viewfinder", title: "Last dose", value: "-")
                HistoryCard(iconName: "chart.line.uptrend.xyaxis", title: "Est. level", value: "-")
            }
        }
    }
}

struct HistoryCard: View {
    let iconName: String, title: String, value: String
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 4) { Image(systemName: iconName).foregroundColor(.blue); Text(title).font(.caption).foregroundColor(.secondary) }
            Text(value).font(.title3).fontWeight(value == "0" ? .bold : .regular); Spacer(minLength: 0)
        }.padding(12).frame(maxWidth: .infinity, alignment: .leading).background(Color(UIColor.secondarySystemGroupedBackground)).cornerRadius(12)
    }
}

struct NextShotView: View {
    let gradient = AngularGradient(gradient: Gradient(colors: [.red, .orange, .yellow, .green, .blue]), center: .center, startAngle: .degrees(135), endAngle: .degrees(135 + 270))
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Next Shot").font(.title2).fontWeight(.bold)
            ZStack {
                Circle().trim(from: 0.0, to: 0.75).stroke(Color(UIColor.systemGray5), style: StrokeStyle(lineWidth: 30, lineCap: .round)).rotationEffect(.degrees(135))
                Circle().trim(from: 0.0, to: 0.75).stroke(gradient, style: StrokeStyle(lineWidth: 30, lineCap: .round)).rotationEffect(.degrees(135))
                VStack(spacing: 4) {
                    Text("Welcome!").font(.title3).fontWeight(.semibold)
                    Text("Add your first shot to\nget started.").font(.subheadline).foregroundColor(.secondary).multilineTextAlignment(.center)
                }
            }.frame(height: 200).frame(maxWidth: .infinity).padding(.vertical)
        }
    }
}

struct AddShotSectionView: View {
    var onAddShot: () -> Void
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Add Shot").font(.title2).fontWeight(.bold)
            Button(action: onAddShot) { HStack { Image(systemName: "plus"); Text("Add Shot") }.fontWeight(.bold).foregroundColor(.white).padding().frame(maxWidth: .infinity).background(Color.blue).cornerRadius(12) }
        }
    }
}

// MARK: "After Shot" Components
struct ShotConfirmationView: View {
    let gradient = AngularGradient(gradient: Gradient(colors: [.red, .orange, .yellow, .green, .blue]), center: .center, startAngle: .degrees(135), endAngle: .degrees(135 + 270))
    
    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                // 1. The Gauge
                Circle()
                    .trim(from: 0.0, to: 0.75)
                    .stroke(Color(UIColor.systemGray5), style: StrokeStyle(lineWidth: 30, lineCap: .round))
                    .rotationEffect(.degrees(135))
                
                Circle()
                    .trim(from: 0.0, to: 0.70)
                    .stroke(gradient, style: StrokeStyle(lineWidth: 30, lineCap: .round))
                    .rotationEffect(.degrees(135))

                // 2. The Text Content
                VStack(spacing: 4) {
                    Text("You did it!")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Shot taken today\nat 12:00am")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                // --- THE FIX IS HERE ---
                // We've further reduced the bottom padding to lower the text.
                .padding(.bottom, 25)
                // --- END OF FIX ---
            }
            .frame(height: 200)

            // 3. The Button
            Button(action: {}) {
                Text("Edit shot")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 40)
                    .background(Color.blue)
                    .cornerRadius(20)
            }
        }
    }
}

struct DailyMetricsSectionView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Today, August 13").font(.title2).fontWeight(.bold)
            HStack(spacing: 12) {
                MetricCard(icon: "scalemass", title: "Weight", value: "—", iconColor: .blue)
                MetricCard(icon: "flame.fill", title: "Calories", value: "—", iconColor: .orange)
                MetricCard(icon: "chart.bar.fill", title: "Protein", value: "—", iconColor: .red)
            }
            TapToAddCard(icon: "waveform.path.ecg", title: "Side effects", subtitle: "Tap to add side effects")
            TapToAddCard(icon: "note.text", title: "Notes for day", subtitle: "Tap to add notes")
        }
    }
}

struct ResultsSectionView: View {
    private let columns = [GridItem(.adaptive(minimum: 110))]
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack { Text("Results").font(.title2).fontWeight(.bold); Spacer(); Button(action: {}) { HStack(spacing: 4) { Text("See chart"); Image(systemName: "chevron.right") }.font(.callout) } }
            LazyVGrid(columns: columns, spacing: 12) {
                MetricCard(icon: "arrow.up.arrow.down", title: "Total change", value: "—", iconColor: .blue)
                MetricCard(icon: "figure.walk", title: "Current BMI", value: "—", iconColor: .green)
                MetricCard(icon: "stopwatch", title: "Weight", value: "—", iconColor: .cyan)
                MetricCard(icon: "percent", title: "Percent", value: "—", iconColor: .purple)
                MetricCard(icon: "calendar", title: "Weekly avg", value: "—", iconColor: .orange)
                MetricCard(icon: "flag.fill", title: "To goal", value: "—", iconColor: .red)
            }
        }
    }
}

struct MetricCard: View {
    let icon: String, title: String, value: String, iconColor: Color
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 4) { Image(systemName: icon).font(.subheadline).foregroundColor(iconColor); Text(title).font(.caption).foregroundColor(.secondary) }
            Text(value).font(.title3).fontWeight(.medium)
        }.padding(12).frame(maxWidth: .infinity, alignment: .leading).background(Color(UIColor.secondarySystemGroupedBackground)).cornerRadius(12)
    }
}

struct TapToAddCard: View {
    let icon: String, title: String, subtitle: String
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon).font(.title3).foregroundColor(.green);
            VStack(alignment: .leading) { Text(title).fontWeight(.medium); Text(subtitle).font(.caption).foregroundColor(.secondary) }; Spacer()
        }.padding().background(Color(UIColor.secondarySystemGroupedBackground)).cornerRadius(12)
    }
}

// MARK: "Add Shot" Form Components
private struct DateSelectionView: View {
    @Binding var selectedDate: Date
    var body: some View { HStack { Button(action: {}) { Image(systemName: "chevron.left") }; Spacer(); Menu { DatePicker("", selection: $selectedDate, displayedComponents: .date) } label: { Text("Today"); Image(systemName: "arrowtriangle.down.fill").font(.caption) }; Spacer(); Button(action: {}) { Image(systemName: "chevron.right") } }.foregroundColor(.primary) }
}

private struct TimeSelectionView: View {
    @Binding var timeTaken: Date
    var body: some View { DatePicker("Time Taken", selection: $timeTaken, displayedComponents: .hourAndMinute) }
}

private struct DetailRow: View {
    let label: String, value: String, hasCapsule: Bool
    var body: some View {
        HStack {
            Text(label); Spacer()
            HStack(spacing: 6) {
                if hasCapsule { Text(value).font(.subheadline).padding(.horizontal, 8).padding(.vertical, 4).background(Color.gray.opacity(0.3)).clipShape(Capsule()) } else { Text(value).foregroundColor(.blue) }
                Image(systemName: "chevron.up.chevron.down").foregroundColor(hasCapsule ? .primary : .blue).font(.caption.weight(.bold))
            }
        }.padding(.vertical, 2)
    }
}

private struct PainLevelRow: View {
    @Binding var painLevel: Double
    var body: some View { HStack { Text("Pain Level"); Slider(value: $painLevel, in: 0...10, step: 1); Text("\(Int(painLevel))").frame(width: 20, alignment: .trailing) } }
}

private struct NotesSectionView: View {
    @Binding var notes: String
    var body: some View { ZStack(alignment: .topLeading) { TextEditor(text: $notes).frame(minHeight: 80); if notes.isEmpty { Text("Add notes").foregroundColor(.secondary.opacity(0.7)).padding(.horizontal, 5).padding(.top, 8).allowsHitTesting(false) } } }
}

// MARK: - Preview Provider
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
