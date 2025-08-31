import SwiftUI
import Charts

// MARK: - New Summary View
struct NewSummaryView: View {
    @StateObject private var dataManager = AppDataManager.shared
    @State private var showingAddShot = false
    @State private var showingShotHistory = false
    @State private var showingResultsChart = false
    @State private var selectedTimeRange = 0
    
    let timeRanges = ["Week", "Month", "90 days", "All time"]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Shot History Section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Shot History")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Spacer()
                            
                            Button {
                                showingShotHistory = true
                            } label: {
                                HStack(spacing: 4) {
                                    Text("See all")
                                        .foregroundColor(.blue)
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.blue)
                                        .font(.caption)
                                }
                            }
                        }
                        
                        HStack(spacing: 12) {
                            // Shots taken card
                            ShotStatsCard(
                                icon: "syringe",
                                title: "Shots taken",
                                value: "\(dataManager.currentStreak)"
                            )
                            
                            // Last dose card
                            ShotStatsCard(
                                icon: "medical.thermometer",
                                title: "Last dose",
                                value: "2.5mg"
                            )
                            
                            // Est. level card
                            ShotStatsCard(
                                icon: "chart.line.uptrend.xyaxis",
                                title: "Est. level",
                                value: "2.52mg"
                            )
                        }
                    }
                    .padding(.horizontal)
                    
                    // Estimated Medication Levels Chart
                    VStack(alignment: .leading, spacing: 16) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Estimated Medication Levels")
                                .font(.title2)
                                .fontWeight(.bold)
                                .padding(.horizontal)
                            
                            // Time range selector
                            HStack(spacing: 0) {
                                ForEach(0..<timeRanges.count, id: \.self) { index in
                                    Button {
                                        selectedTimeRange = index
                                    } label: {
                                        Text(timeRanges[index])
                                            .font(.subheadline)
                                            .fontWeight(selectedTimeRange == index ? .semibold : .regular)
                                            .foregroundColor(selectedTimeRange == index ? .primary : .secondary)
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 8)
                                            .background(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .fill(selectedTimeRange == index ? Color.gray.opacity(0.15) : Color.clear)
                                            )
                                    }
                                }
                                Spacer()
                            }
                            .padding(.horizontal)
                        }
                        
                        // Medication Level Chart
                        MedicationLevelChart()
                            .frame(height: 200)
                            .padding(.horizontal)
                    }
                    
                    // Next Shot Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Next Shot")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        NextShotCard(daysUntilNext: dataManager.currentUserProfile?.daysUntilNextShot ?? 2)
                            .padding(.horizontal)
                    }
                    
                    // Today's Data (Second Page)
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Today, \(Date().formatted(date: .complete, time: .omitted))")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        HStack(spacing: 12) {
                            TodayStatsCard(
                                icon: "scalemass",
                                iconColor: .blue,
                                title: "Weight",
                                value: dataManager.todayWeight != nil ? "\(String(format: "%.1f", dataManager.todayWeight!))kg" : "—"
                            )
                            
                            TodayStatsCard(
                                icon: "flame.fill",
                                iconColor: .orange,
                                title: "Calories",
                                value: dataManager.todayCalories > 0 ? "\(dataManager.todayCalories)" : "—"
                            )
                            
                            TodayStatsCard(
                                icon: "chart.bar.fill",
                                iconColor: .red,
                                title: "Protein",
                                value: dataManager.todayProtein > 0 ? "\(dataManager.todayProtein)g" : "—"
                            )
                        }
                        .padding(.horizontal)
                        
                        // Side Effects Section
                        SideEffectsCard()
                            .padding(.horizontal)
                        
                        // Notes Section
                        NotesCard()
                            .padding(.horizontal)
                    }
                    
                    // Results Section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Results")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Spacer()
                            
                            Button {
                                showingResultsChart = true
                            } label: {
                                HStack(spacing: 4) {
                                    Text("See chart")
                                        .foregroundColor(.blue)
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.blue)
                                        .font(.caption)
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                            ResultsCard(title: "Total change", value: "+20kg", color: .yellow)
                            ResultsCard(title: "Current BMI", value: "27.8", color: .gray)
                            ResultsCard(title: "Weight", value: "90.0kg", color: .gray)
                            ResultsCard(title: "Percent", value: "0%", color: .gray)
                            ResultsCard(title: "Weekly avg", value: "+3.6kg/wk", color: .gray)
                            ResultsCard(title: "To goal", value: "30.0kg (100%)", color: .gray)
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
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
                    Text("Summary")
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
        .sheet(isPresented: $showingShotHistory) {
            ShotHistoryView()
        }
        .sheet(isPresented: $showingResultsChart) {
            ResultsChartView()
        }
    }
}

// MARK: - Shot Stats Card
struct ShotStatsCard: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .foregroundColor(.blue)
                    .font(.caption)
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
            
            Spacer(minLength: 0)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 80)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
}

// MARK: - Medication Level Chart
struct MedicationLevelChart: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Current level indicator
            HStack {
                Spacer()
                VStack(spacing: 4) {
                    Text("2.52mg")
                        .font(.headline)
                        .fontWeight(.semibold)
                    Text("Aug 30, 2025 at 8 PM")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
            
            // Chart area
            ZStack {
                // Background chart area
                Rectangle()
                    .fill(LinearGradient(
                        gradient: Gradient(colors: [
                            Color.blue.opacity(0.3),
                            Color.blue.opacity(0.1),
                            Color.blue.opacity(0.05)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    ))
                    .frame(height: 120)
                
                // Chart line (simplified)
                Path { path in
                    path.move(to: CGPoint(x: 20, y: 80))
                    path.addCurve(
                        to: CGPoint(x: 300, y: 100),
                        control1: CGPoint(x: 100, y: 60),
                        control2: CGPoint(x: 200, y: 85)
                    )
                }
                .stroke(Color.blue, lineWidth: 3)
                
                // Dotted future line
                Path { path in
                    path.move(to: CGPoint(x: 300, y: 100))
                    path.addLine(to: CGPoint(x: 350, y: 110))
                }
                .stroke(Color.blue, style: StrokeStyle(lineWidth: 2, dash: [5, 5]))
                
                // Current point indicator
                Circle()
                    .fill(Color.blue)
                    .frame(width: 8, height: 8)
                    .position(x: 300, y: 100)
            }
            
            // Date labels
            HStack {
                ForEach(["8/27", "8/28", "8/29", "8/30", "8/31", "9/1", "9/2"], id: \.self) { date in
                    Text(date)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    if date != "9/2" { Spacer() }
                }
            }
            .padding(.horizontal, 20)
        }
    }
}

// MARK: - Next Shot Card
struct NextShotCard: View {
    let daysUntilNext: Int
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.3), lineWidth: 20)
                .frame(width: 200, height: 200)
            
            Circle()
                .trim(from: 0, to: 0.7) // Adjust based on days remaining
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: [.red, .orange, .yellow, .green]),
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: 20, lineCap: .round)
                )
                .frame(width: 200, height: 200)
                .rotationEffect(.degrees(-90))
            
            VStack(spacing: 4) {
                Text("\(daysUntilNext) days")
                    .font(.system(size: 32, weight: .bold))
                
                Text("to next shot")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text("Mon, Sep 1 at 6:33pm")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
    }
}

// MARK: - Today Stats Card
struct TodayStatsCard: View {
    let icon: String
    let iconColor: Color
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .foregroundColor(iconColor)
                    .font(.caption)
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
            
            Spacer(minLength: 0)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 80)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
}

// MARK: - Side Effects Card
struct SideEffectsCard: View {
    let sideEffects = [
        ("Nausea", 4),
        ("Heartburn", 2),
        ("Food Noise", 5),
        ("Migraine", 4),
        ("Suppressed Appetite", 4)
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "waveform.path.ecg")
                    .foregroundColor(.green)
                Text("Side effects")
                    .font(.headline)
                    .fontWeight(.medium)
            }
            
            VStack(spacing: 12) {
                ForEach(sideEffects, id: \.0) { effect, level in
                    HStack {
                        Text(effect)
                            .font(.subheadline)
                        
                        Spacer()
                        
                        // Progress bar
                        HStack(spacing: 2) {
                            ForEach(0..<10) { index in
                                Rectangle()
                                    .fill(index < level ? Color.primary : Color.gray.opacity(0.3))
                                    .frame(width: 8, height: 8)
                            }
                        }
                        
                        Text("\(level)/10")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .frame(width: 35, alignment: .trailing)
                    }
                }
            }
        }
        .padding(16)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
}

// MARK: - Notes Card
struct NotesCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "note.text")
                    .foregroundColor(.orange)
                Text("Notes for day")
                    .font(.headline)
                    .fontWeight(.medium)
            }
            
            Text("Tap to add notes")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(12)
        .onTapGesture {
            // Add notes functionality
        }
    }
}

// MARK: - Results Card
struct ResultsCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 4) {
                Image(systemName: iconForTitle(title))
                    .foregroundColor(color == .yellow ? .black : .secondary)
                    .font(.caption)
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(color == .yellow ? .black : .primary)
            
            Spacer(minLength: 0)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 70)
        .background(color == .yellow ? Color.yellow : Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
    
    func iconForTitle(_ title: String) -> String {
        switch title {
        case "Total change": return "scalemass"
        case "Current BMI": return "figure.walk"
        case "Weight": return "timer"
        case "Percent": return "percent"
        case "Weekly avg": return "clock"
        case "To goal": return "flag.fill"
        default: return "circle"
        }
    }
}