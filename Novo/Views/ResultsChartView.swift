import SwiftUI
import Charts

struct ResultsChartView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var dataManager = AppDataManager.shared
    @State private var selectedTimeRange = 1
    @State private var showingAddShot = false
    
    let timeRanges = ["1W", "1M", "3M", "6M", "1Y"]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Time Range Selector
                    HStack(spacing: 12) {
                        ForEach(0..<timeRanges.count, id: \.self) { index in
                            Button {
                                selectedTimeRange = index
                            } label: {
                                Text(timeRanges[index])
                                    .font(.caption)
                                    .fontWeight(selectedTimeRange == index ? .bold : .regular)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(selectedTimeRange == index ? Color.purple : Color.gray.opacity(0.2))
                                    .foregroundColor(selectedTimeRange == index ? .white : .primary)
                                    .cornerRadius(8)
                            }
                        }
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    // Weight Progress Chart
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Weight Progress")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        WeightProgressChart()
                            .frame(height: 250)
                            .padding(.horizontal)
                        
                        // Statistics
                        HStack(spacing: 20) {
                            StatisticCard(
                                title: "Starting",
                                value: "70.0kg",
                                subtitle: "Jan 1, 2025"
                            )
                            
                            Divider()
                                .frame(height: 40)
                            
                            StatisticCard(
                                title: "Current",
                                value: "90.0kg",
                                subtitle: "Aug 30, 2025"
                            )
                            
                            Divider()
                                .frame(height: 40)
                            
                            StatisticCard(
                                title: "Change",
                                value: "+20.0kg",
                                subtitle: "8 months",
                                isPositive: false
                            )
                        }
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }
                    
                    // Additional Metrics
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Progress Metrics")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                            ProgressMetricCard(
                                title: "BMI",
                                currentValue: "27.8",
                                change: "-2.1",
                                isPositiveGood: false
                            )
                            
                            ProgressMetricCard(
                                title: "Body Fat %",
                                currentValue: "22.5%",
                                change: "-5.2%",
                                isPositiveGood: false
                            )
                            
                            ProgressMetricCard(
                                title: "Muscle Mass",
                                currentValue: "45.2kg",
                                change: "+2.1kg",
                                isPositiveGood: true
                            )
                            
                            ProgressMetricCard(
                                title: "Weekly Avg",
                                currentValue: "+3.6kg",
                                change: "+0.8kg",
                                isPositiveGood: false
                            )
                        }
                        .padding(.horizontal)
                    }
                    
                    // Goal Progress
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Goal Progress")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        GoalProgressCard()
                            .padding(.horizontal)
                    }
                    
                    // Milestones
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Milestones")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        VStack(spacing: 12) {
                            MilestoneRow(
                                title: "First Shot",
                                date: "Jan 15, 2025",
                                isCompleted: true
                            )
                            
                            MilestoneRow(
                                title: "10kg Gained",
                                date: "May 20, 2025",
                                isCompleted: true
                            )
                            
                            MilestoneRow(
                                title: "20kg Gained",
                                date: "Aug 30, 2025",
                                isCompleted: true
                            )
                            
                            MilestoneRow(
                                title: "Goal Weight (120kg)",
                                date: "Est. Feb 2026",
                                isCompleted: false
                            )
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
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.gray)
                    }
                }
                
                ToolbarItem(placement: .principal) {
                    Text("Results")
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
    }
}

// MARK: - Weight Progress Chart
struct WeightProgressChart: View {
    let weightData = [
        (Date().addingTimeInterval(-240*24*3600), 70.0),
        (Date().addingTimeInterval(-210*24*3600), 72.5),
        (Date().addingTimeInterval(-180*24*3600), 75.0),
        (Date().addingTimeInterval(-150*24*3600), 78.2),
        (Date().addingTimeInterval(-120*24*3600), 81.5),
        (Date().addingTimeInterval(-90*24*3600), 84.1),
        (Date().addingTimeInterval(-60*24*3600), 86.8),
        (Date().addingTimeInterval(-30*24*3600), 88.5),
        (Date(), 90.0)
    ]
    
    var body: some View {
        Chart {
            ForEach(Array(weightData.enumerated()), id: \.offset) { index, data in
                AreaMark(
                    x: .value("Date", data.0),
                    y: .value("Weight", data.1)
                )
                .foregroundStyle(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.purple.opacity(0.3), Color.purple.opacity(0.05)]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                
                LineMark(
                    x: .value("Date", data.0),
                    y: .value("Weight", data.1)
                )
                .foregroundStyle(Color.purple)
                .lineStyle(StrokeStyle(lineWidth: 3))
                
                PointMark(
                    x: .value("Date", data.0),
                    y: .value("Weight", data.1)
                )
                .foregroundStyle(Color.purple)
                .symbolSize(30)
            }
        }
        .chartYAxisLabel("Weight (kg)")
        .chartXAxis {
            AxisMarks(values: .automatic(desiredCount: 5)) { _ in
                AxisGridLine()
                AxisValueLabel(format: .dateTime.month(.abbreviated).day())
            }
        }
        .chartYAxis {
            AxisMarks { _ in
                AxisGridLine()
                AxisValueLabel()
            }
        }
    }
}

// MARK: - Statistic Card
struct StatisticCard: View {
    let title: String
    let value: String
    let subtitle: String
    var isPositive: Bool = true
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            HStack(spacing: 4) {
                if !isPositive && value.hasPrefix("+") {
                    Image(systemName: "arrow.up")
                        .font(.caption)
                        .foregroundColor(.red)
                }
                
                Text(value)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(isPositive ? .primary : (value.hasPrefix("+") ? .red : .green))
            }
            
            Text(subtitle)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Progress Metric Card
struct ProgressMetricCard: View {
    let title: String
    let currentValue: String
    let change: String
    let isPositiveGood: Bool
    
    var changeColor: Color {
        let isPositive = change.hasPrefix("+")
        return (isPositive == isPositiveGood) ? .green : .red
    }
    
    var changeIcon: String {
        let isPositive = change.hasPrefix("+")
        return isPositive ? "arrow.up" : "arrow.down"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(currentValue)
                    .font(.title2)
                    .fontWeight(.bold)
                
                HStack(spacing: 4) {
                    Image(systemName: changeIcon)
                        .font(.caption)
                        .foregroundColor(changeColor)
                    Text(change)
                        .font(.caption)
                        .foregroundColor(changeColor)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
    }
}

// MARK: - Goal Progress Card
struct GoalProgressCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Target Weight")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text("120.0 kg")
                        .font(.title2)
                        .fontWeight(.bold)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("66.7% Complete")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Text("30.0 kg to go")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(LinearGradient(
                            gradient: Gradient(colors: [.purple, .blue]),
                            startPoint: .leading,
                            endPoint: .trailing
                        ))
                        .frame(width: geometry.size.width * 0.667, height: 8)
                }
            }
            .frame(height: 8)
            
            HStack {
                Text("Starting: 70kg")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Text("Goal: 120kg")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
    }
}

// MARK: - Milestone Row
struct MilestoneRow: View {
    let title: String
    let date: String
    let isCompleted: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                .foregroundColor(isCompleted ? .green : .gray)
                .font(.title3)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(isCompleted ? .primary : .secondary)
                
                Text(date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if isCompleted {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                    .font(.caption)
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
    }
}