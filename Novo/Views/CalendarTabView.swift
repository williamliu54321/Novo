import SwiftUI
import CoreData

struct CalendarTabView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var selectedDate = Date()
    @State private var currentMonth = Date()
    @State private var showingEditSheet = false
    @State private var editingField: EditableField?
    
    private let calendar = Calendar.current
    
    enum EditableField: String {
        case shot = "Shot"
        case weight = "Weight"
        case calories = "Calories"
        case protein = "Protein"
        case sideEffects = "Side Effects"
        case notes = "Notes"
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Calendar Grid
                    calendarView
                    
                    // Selected Day Details
                    dayDetailsView
                }
                .padding(.horizontal)
            }
            .navigationTitle("Calendar")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Today") {
                        withAnimation {
                            selectedDate = Date()
                            currentMonth = Date()
                        }
                    }
                    .foregroundColor(.blue)
                }
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            EditFieldSheet(
                field: editingField ?? .notes,
                date: selectedDate,
                onDismiss: { showingEditSheet = false }
            )
        }
    }
    
    // MARK: - Calendar View
    private var calendarView: some View {
        VStack(spacing: 10) {
            // Month Navigation
            HStack {
                Button(action: previousMonth) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Text(monthYearString(from: currentMonth))
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button(action: nextMonth) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }
            }
            .padding(.vertical, 10)
            
            // Days of Week
            HStack {
                ForEach(["S", "M", "T", "W", "T", "F", "S"], id: \.self) { day in
                    Text(day)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity)
                }
            }
            
            // Calendar Grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 15) {
                ForEach(calendarDays(), id: \.self) { date in
                    DayCell(
                        date: date,
                        isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                        isToday: calendar.isDateInToday(date),
                        isCurrentMonth: calendar.isDate(date, equalTo: currentMonth, toGranularity: .month),
                        hasShot: hasShot(for: date)
                    )
                    .onTapGesture {
                        withAnimation {
                            selectedDate = date
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGroupedBackground))
        .cornerRadius(15)
    }
    
    // MARK: - Day Details View
    private var dayDetailsView: some View {
        VStack(alignment: .leading, spacing: 15) {
            // Date Header
            Text("Today, \(formattedDate(selectedDate))")
                .font(.title2)
                .fontWeight(.bold)
            
            // Shot Card
            EditableCard(
                icon: "syringe",
                iconColor: .blue,
                title: "Shot",
                value: getShotValue(),
                placeholder: "Tap to add shot",
                showEstLevel: true,
                estLevel: "0.61 mg",
                estStatus: "Decreasing ↘"
            ) {
                editingField = .shot
                showingEditSheet = true
            }
            
            // Metrics Row
            HStack(spacing: 12) {
                MetricCard(
                    icon: "scalemass",
                    iconColor: .blue,
                    title: "Weight",
                    value: getWeightValue(),
                    placeholder: "—"
                ) {
                    editingField = .weight
                    showingEditSheet = true
                }
                
                MetricCard(
                    icon: "flame.fill",
                    iconColor: .orange,
                    title: "Calories",
                    value: getCaloriesValue(),
                    placeholder: "—"
                ) {
                    editingField = .calories
                    showingEditSheet = true
                }
                
                MetricCard(
                    icon: "chart.bar.fill",
                    iconColor: .red,
                    title: "Protein",
                    value: getProteinValue(),
                    placeholder: "—"
                ) {
                    editingField = .protein
                    showingEditSheet = true
                }
            }
            
            // Side Effects Card
            SideEffectsCard {
                editingField = .sideEffects
                showingEditSheet = true
            }
            
            // Notes Card
            NotesCard(notes: getNotesValue()) {
                editingField = .notes
                showingEditSheet = true
            }
        }
    }
    
    // MARK: - Helper Functions
    private func calendarDays() -> [Date] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: currentMonth) else {
            return []
        }
        
        let firstOfMonth = monthInterval.start
        let firstWeekday = calendar.component(.weekday, from: firstOfMonth) - 1
        
        var days: [Date] = []
        
        // Add days from previous month
        for offset in (0..<firstWeekday).reversed() {
            if let date = calendar.date(byAdding: .day, value: -(offset + 1), to: firstOfMonth) {
                days.append(date)
            }
        }
        
        // Add days of current month
        let numberOfDays = calendar.range(of: .day, in: .month, for: currentMonth)?.count ?? 0
        for day in 0..<numberOfDays {
            if let date = calendar.date(byAdding: .day, value: day, to: firstOfMonth) {
                days.append(date)
            }
        }
        
        // Add days from next month to complete the grid
        while days.count % 7 != 0 {
            if let lastDay = days.last,
               let nextDay = calendar.date(byAdding: .day, value: 1, to: lastDay) {
                days.append(nextDay)
            }
        }
        
        return days
    }
    
    private func previousMonth() {
        withAnimation {
            currentMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
        }
    }
    
    private func nextMonth() {
        withAnimation {
            currentMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
        }
    }
    
    private func monthYearString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d"
        return formatter.string(from: date)
    }
    
    private func hasShot(for date: Date) -> Bool {
        // Check if there's an injection for this date in Core Data
        return false // Placeholder
    }
    
    private func getShotValue() -> String? {
        // Get shot data from Core Data for selected date
        return nil
    }
    
    private func getWeightValue() -> String? {
        // Get weight from Core Data for selected date
        return "90.0kg" // Placeholder
    }
    
    private func getCaloriesValue() -> String? {
        // Get calories from Core Data for selected date
        return nil
    }
    
    private func getProteinValue() -> String? {
        // Get protein from Core Data for selected date
        return nil
    }
    
    private func getNotesValue() -> String? {
        // Get notes from Core Data for selected date
        return nil
    }
}

// MARK: - Day Cell Component
struct DayCell: View {
    let date: Date
    let isSelected: Bool
    let isToday: Bool
    let isCurrentMonth: Bool
    let hasShot: Bool
    
    private var dayNumber: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
    
    var body: some View {
        ZStack {
            if isSelected {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 40, height: 40)
            }
            
            if isToday {
                Circle()
                    .stroke(Color.blue, lineWidth: 2)
                    .frame(width: 40, height: 40)
            }
            
            VStack(spacing: 2) {
                Text(dayNumber)
                    .font(.system(size: 16))
                    .foregroundColor(isCurrentMonth ? .primary : .gray)
                
                if hasShot {
                    Circle()
                        .fill(Color.yellow)
                        .frame(width: 6, height: 6)
                }
            }
        }
        .frame(width: 40, height: 40)
    }
}

// MARK: - Editable Card Component
struct EditableCard: View {
    let icon: String
    let iconColor: Color
    let title: String
    let value: String?
    let placeholder: String
    var showEstLevel: Bool = false
    var estLevel: String = ""
    var estStatus: String = ""
    let onTap: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: icon)
                        .foregroundColor(iconColor)
                    Text(title)
                        .font(.headline)
                }
                
                if let value = value {
                    Text(value)
                        .font(.body)
                } else {
                    Text(placeholder)
                        .font(.body)
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            if showEstLevel {
                VStack(alignment: .trailing, spacing: 4) {
                    HStack {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .foregroundColor(.blue)
                            .font(.caption)
                        Text("Est. level")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    Text(estLevel)
                        .font(.title3)
                        .fontWeight(.semibold)
                    Text(estStatus)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
        .onTapGesture(perform: onTap)
    }
}

// MARK: - Metric Card Component
struct MetricCard: View {
    let icon: String
    let iconColor: Color
    let title: String
    let value: String?
    let placeholder: String
    let onTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .foregroundColor(iconColor)
                    .font(.caption)
                Text(title)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Text(value ?? placeholder)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(value != nil ? .primary : .gray)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
        .onTapGesture(perform: onTap)
    }
}

// MARK: - Side Effects Card
struct SideEffectsCard: View {
    let onTap: () -> Void
    
    let sideEffects = [
        ("Nausea", 4),
        ("Heartburn", 2),
        ("Food Noise", 5),
        ("Migraine", 4),
        ("Suppressed Appetite", 4)
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "waveform.path.ecg")
                    .foregroundColor(.green)
                Text("Side effects")
                    .font(.headline)
            }
            
            ForEach(sideEffects, id: \.0) { effect, level in
                HStack {
                    Text(effect)
                        .font(.body)
                    
                    Spacer()
                    
                    // Progress bar
                    HStack(spacing: 2) {
                        ForEach(0..<10) { index in
                            Rectangle()
                                .fill(index < level ? Color.primary : Color.gray.opacity(0.3))
                                .frame(width: 20, height: 6)
                        }
                    }
                    
                    Text("\(level)/10")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
        .onTapGesture(perform: onTap)
    }
}

// MARK: - Notes Card
struct NotesCard: View {
    let notes: String?
    let onTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "note.text")
                    .foregroundColor(.orange)
                Text("Notes for day")
                    .font(.headline)
            }
            
            Text(notes ?? "Tap to add notes")
                .font(.body)
                .foregroundColor(notes != nil ? .primary : .gray)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
        .onTapGesture(perform: onTap)
    }
}

// MARK: - Edit Field Sheet
struct EditFieldSheet: View {
    let field: CalendarTabView.EditableField
    let date: Date
    let onDismiss: () -> Void
    
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var textValue = ""
    @State private var numberValue = 0.0
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Edit \(field.rawValue)")) {
                    switch field {
                    case .shot:
                        TextField("Medication", text: $textValue)
                        TextField("Dose", value: $numberValue, format: .number)
                    case .weight:
                        TextField("Weight (kg)", value: $numberValue, format: .number)
                    case .calories:
                        TextField("Calories", value: $numberValue, format: .number)
                    case .protein:
                        TextField("Protein (g)", value: $numberValue, format: .number)
                    case .sideEffects:
                        Text("Side effects editor coming soon")
                    case .notes:
                        TextEditor(text: $textValue)
                            .frame(minHeight: 100)
                    }
                }
            }
            .navigationTitle("Edit \(field.rawValue)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                        onDismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveData()
                        dismiss()
                        onDismiss()
                    }
                    .fontWeight(.bold)
                }
            }
        }
    }
    
    private func saveData() {
        // Save to Core Data based on field type
        // Implementation depends on your Core Data setup
    }
}