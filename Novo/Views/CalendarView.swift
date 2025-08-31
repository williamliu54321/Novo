import SwiftUI

struct CalendarView: View {
    @StateObject private var dataManager = AppDataManager.shared
    @State private var selectedDate = Date()
    @State private var currentMonth = Date()
    @State private var showingAddShot = false
    @State private var showingDayDetail = false
    
    private let calendar = Calendar.current
    private let dateFormatter = DateFormatter()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Month Navigation
                HStack {
                    Button {
                        withAnimation {
                            currentMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
                        }
                    } label: {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.blue)
                            .font(.title2)
                    }
                    
                    Spacer()
                    
                    Text(currentMonth.formatted(.dateTime.month(.wide).year()))
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    Button {
                        withAnimation {
                            currentMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
                        }
                    } label: {
                        Image(systemName: "chevron.right")
                            .foregroundColor(.blue)
                            .font(.title2)
                    }
                }
                .padding()
                
                // Calendar Grid
                VStack(spacing: 0) {
                    // Day headers
                    HStack(spacing: 0) {
                        ForEach(["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"], id: \.self) { day in
                            Text(day)
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                    
                    // Calendar days
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 2) {
                        ForEach(calendarDays, id: \.self) { date in
                            CalendarDayView(
                                date: date,
                                isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                                isCurrentMonth: calendar.isDate(date, equalTo: currentMonth, toGranularity: .month),
                                hasShot: hasShot(for: date),
                                hasData: hasData(for: date),
                                shotData: getShotData(for: date)
                            )
                            .onTapGesture {
                                selectedDate = date
                                if hasData(for: date) {
                                    showingDayDetail = true
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                Spacer()
                
                // Selected Date Details
                if calendar.isDate(selectedDate, inSameDayAs: Date()) || hasData(for: selectedDate) {
                    SelectedDateDetailView(
                        date: selectedDate,
                        shotData: getShotData(for: selectedDate)
                    )
                    .transition(.slide)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        // Menu action
                    } label: {
                        Image(systemName: "line.3.horizontal")
                            .foregroundColor(.blue)
                    }
                }
                
                ToolbarItem(placement: .principal) {
                    Text("Calendar")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddShot = true
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "plus")
                            Text("Add shot")
                        }
                        .foregroundColor(.blue)
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddShot) {
            SimpleDoseTrackingView()
        }
        .sheet(isPresented: $showingDayDetail) {
            DayDetailView(date: selectedDate, shotData: getShotData(for: selectedDate))
        }
    }
    
    // MARK: - Calendar Logic
    
    private var calendarDays: [Date] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: currentMonth) else {
            return []
        }
        
        let firstOfMonth = monthInterval.start
        let lastOfMonth = calendar.date(byAdding: DateComponents(day: -1), to: monthInterval.end)!
        
        let firstWeekday = calendar.component(.weekday, from: firstOfMonth)
        let daysInPreviousMonth = firstWeekday - 1
        
        var dates: [Date] = []
        
        // Previous month days
        if daysInPreviousMonth > 0 {
            let previousMonth = calendar.date(byAdding: .month, value: -1, to: firstOfMonth)!
            let daysInPrevMonth = calendar.range(of: .day, in: .month, for: previousMonth)!.count
            let startPrevMonth = daysInPrevMonth - daysInPreviousMonth + 1
            
            for day in startPrevMonth...daysInPrevMonth {
                if let date = calendar.date(byAdding: .day, value: day - 1, to: calendar.date(from: calendar.dateComponents([.year, .month], from: previousMonth))!) {
                    dates.append(date)
                }
            }
        }
        
        // Current month days
        let daysInCurrentMonth = calendar.range(of: .day, in: .month, for: currentMonth)!.count
        for day in 1...daysInCurrentMonth {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstOfMonth) {
                dates.append(date)
            }
        }
        
        // Next month days to fill the grid
        let remainingDays = 42 - dates.count
        let nextMonth = calendar.date(byAdding: .month, value: 1, to: firstOfMonth)!
        for day in 1...remainingDays {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: nextMonth) {
                dates.append(date)
            }
        }
        
        return dates
    }
    
    private func hasShot(for date: Date) -> Bool {
        // Mock data - in real app, check dataManager
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd"
        let dateString = formatter.string(from: date)
        
        let shotDates = ["08-13", "08-20", "08-25", "08-30"]
        return shotDates.contains(dateString)
    }
    
    private func hasData(for date: Date) -> Bool {
        return hasShot(for: date) || calendar.isDate(date, inSameDayAs: Date())
    }
    
    private func getShotData(for date: Date) -> ShotData? {
        guard hasShot(for: date) else { return nil }
        
        // Mock data
        return ShotData(
            medication: "Tirzepatide",
            dose: "2.5mg",
            site: "Stomach - Upper Left",
            painLevel: 2,
            weight: 89.5,
            calories: 1850,
            protein: 95,
            sideEffects: ["Nausea": 3, "Fatigue": 2],
            notes: "Feeling good today"
        )
    }
}

// MARK: - Calendar Day View
struct CalendarDayView: View {
    let date: Date
    let isSelected: Bool
    let isCurrentMonth: Bool
    let hasShot: Bool
    let hasData: Bool
    let shotData: ShotData?
    
    private let calendar = Calendar.current
    
    var body: some View {
        VStack(spacing: 2) {
            Text("\(calendar.component(.day, from: date))")
                .font(.system(size: 16, weight: isSelected ? .bold : .medium))
                .foregroundColor(textColor)
            
            // Indicators
            HStack(spacing: 2) {
                if hasShot {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 6, height: 6)
                }
                
                if hasData && !hasShot {
                    Circle()
                        .fill(Color.orange)
                        .frame(width: 6, height: 6)
                }
            }
            .frame(height: 8)
        }
        .frame(width: 40, height: 50)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isSelected ? Color.blue.opacity(0.2) : Color.clear)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 1)
        )
    }
    
    private var textColor: Color {
        if !isCurrentMonth {
            return .gray.opacity(0.5)
        } else if isSelected {
            return .blue
        } else if calendar.isDate(date, inSameDayAs: Date()) {
            return .blue
        } else {
            return .primary
        }
    }
}

// MARK: - Selected Date Detail View
struct SelectedDateDetailView: View {
    let date: Date
    let shotData: ShotData?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(date.formatted(date: .complete, time: .omitted))
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }
            
            if let shotData = shotData {
                VStack(alignment: .leading, spacing: 12) {
                    // Shot info
                    HStack {
                        Image(systemName: "syringe")
                            .foregroundColor(.blue)
                        Text("\(shotData.medication) \(shotData.dose)")
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                    
                    // Stats
                    HStack(spacing: 20) {
                        if shotData.weight > 0 {
                            StatBadge(icon: "scalemass", value: "\(String(format: "%.1f", shotData.weight))kg", color: .blue)
                        }
                        
                        if shotData.calories > 0 {
                            StatBadge(icon: "flame.fill", value: "\(shotData.calories)", color: .orange)
                        }
                        
                        if shotData.protein > 0 {
                            StatBadge(icon: "chart.bar.fill", value: "\(shotData.protein)g", color: .red)
                        }
                    }
                    
                    // Side effects
                    if !shotData.sideEffects.isEmpty {
                        HStack {
                            Image(systemName: "waveform.path.ecg")
                                .foregroundColor(.green)
                            Text("Side effects recorded")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            } else if Calendar.current.isDate(date, inSameDayAs: Date()) {
                Text("Today - Tap to add data")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
        .padding()
    }
}

// MARK: - Day Detail View (Modal)
struct DayDetailView: View {
    @Environment(\.dismiss) var dismiss
    let date: Date
    let shotData: ShotData?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    if let shotData = shotData {
                        // Shot details
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Shot Details")
                                .font(.headline)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                DetailRow(label: "Medication", value: shotData.medication)
                                DetailRow(label: "Dose", value: shotData.dose)
                                DetailRow(label: "Injection Site", value: shotData.site)
                                DetailRow(label: "Pain Level", value: "\(shotData.painLevel)/10")
                            }
                        }
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(12)
                        
                        // Health metrics
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Health Metrics")
                                .font(.headline)
                            
                            HStack(spacing: 20) {
                                MetricCard(title: "Weight", value: "\(String(format: "%.1f", shotData.weight))kg", icon: "scalemass", color: .blue)
                                MetricCard(title: "Calories", value: "\(shotData.calories)", icon: "flame.fill", color: .orange)
                                MetricCard(title: "Protein", value: "\(shotData.protein)g", icon: "chart.bar.fill", color: .red)
                            }
                        }
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(12)
                        
                        // Side effects
                        if !shotData.sideEffects.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Side Effects")
                                    .font(.headline)
                                
                                VStack(spacing: 8) {
                                    ForEach(Array(shotData.sideEffects.keys), id: \.self) { effect in
                                        HStack {
                                            Text(effect)
                                            Spacer()
                                            Text("\(shotData.sideEffects[effect]!)/10")
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                }
                            }
                            .padding()
                            .background(Color(UIColor.secondarySystemBackground))
                            .cornerRadius(12)
                        }
                        
                        // Notes
                        if !shotData.notes.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Notes")
                                    .font(.headline)
                                
                                Text(shotData.notes)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(Color(UIColor.secondarySystemBackground))
                            .cornerRadius(12)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle(date.formatted(date: .abbreviated, time: .omitted))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Supporting Views

struct StatBadge: View {
    let icon: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.caption)
            Text(value)
                .font(.caption)
                .fontWeight(.medium)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(color.opacity(0.1))
        .cornerRadius(8)
    }
}

struct DetailRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
    }
}

struct MetricCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.title2)
            
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}

// MARK: - Data Models

struct ShotData {
    let medication: String
    let dose: String
    let site: String
    let painLevel: Int
    let weight: Double
    let calories: Int
    let protein: Int
    let sideEffects: [String: Int]
    let notes: String
}