import SwiftUI
import Charts

struct WeightChartView: View {
    @StateObject private var dataManager = DataManager.shared
    @State private var weightHistory: [WeightEntry] = []
    @State private var selectedTimeRange = 30
    
    let timeRanges = [
        (7, "1W"),
        (30, "1M"),
        (90, "3M"),
        (180, "6M"),
        (365, "1Y")
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Time range selector
                HStack(spacing: 12) {
                    ForEach(timeRanges, id: \.0) { days, label in
                        Button {
                            selectedTimeRange = days
                            loadWeightHistory()
                        } label: {
                            Text(label)
                                .font(.caption)
                                .fontWeight(selectedTimeRange == days ? .bold : .regular)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(selectedTimeRange == days ? Color.purple : Color.gray.opacity(0.2))
                                .foregroundColor(selectedTimeRange == days ? .white : .primary)
                                .cornerRadius(8)
                        }
                    }
                    
                    Spacer()
                }
                .padding(.horizontal)
                
                if !weightHistory.isEmpty {
                    Chart(weightHistory, id: \.id) { entry in
                        LineMark(
                            x: .value("Date", entry.date),
                            y: .value("Weight", entry.weight)
                        )
                        .foregroundStyle(Color.purple)
                        .lineStyle(StrokeStyle(lineWidth: 2))
                        
                        AreaMark(
                            x: .value("Date", entry.date),
                            y: .value("Weight", entry.weight)
                        )
                        .foregroundStyle(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.purple.opacity(0.3), Color.purple.opacity(0.05)]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        
                        PointMark(
                            x: .value("Date", entry.date),
                            y: .value("Weight", entry.weight)
                        )
                        .foregroundStyle(Color.purple)
                        .symbolSize(30)
                    }
                    .frame(height: 250)
                    .padding(.horizontal)
                    .chartYAxisLabel(dataManager.currentUserProfile?.useMetric == true ? "Weight (kg)" : "Weight (lbs)")
                    .chartXAxis {
                        AxisMarks(values: .automatic(desiredCount: 5)) { _ in
                            AxisGridLine()
                            AxisValueLabel(format: .dateTime.month().day())
                        }
                    }
                } else {
                    VStack(spacing: 20) {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("No weight data yet")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text("Start logging your weight to see your progress")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(height: 250)
                    .frame(maxWidth: .infinity)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(16)
                    .padding(.horizontal)
                }
                
                // Statistics
                if !weightHistory.isEmpty {
                    VStack(spacing: 16) {
                        HStack(spacing: 20) {
                            StatisticView(
                                title: "Starting",
                                value: String(format: "%.1f", weightHistory.first?.weight ?? 0),
                                unit: dataManager.currentUserProfile?.useMetric == true ? "kg" : "lbs"
                            )
                            
                            Divider()
                                .frame(height: 40)
                            
                            StatisticView(
                                title: "Current",
                                value: String(format: "%.1f", weightHistory.last?.weight ?? 0),
                                unit: dataManager.currentUserProfile?.useMetric == true ? "kg" : "lbs"
                            )
                            
                            Divider()
                                .frame(height: 40)
                            
                            StatisticView(
                                title: "Change",
                                value: String(format: "%.1f", abs((weightHistory.last?.weight ?? 0) - (weightHistory.first?.weight ?? 0))),
                                unit: dataManager.currentUserProfile?.useMetric == true ? "kg" : "lbs",
                                trend: (weightHistory.last?.weight ?? 0) < (weightHistory.first?.weight ?? 0) ? .down : .up
                            )
                        }
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                }
                
                Spacer()
            }
            .navigationTitle("Weight Progress")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                loadWeightHistory()
            }
        }
    }
    
    private func loadWeightHistory() {
        weightHistory = dataManager.getWeightHistory(days: selectedTimeRange)
    }
}

struct StatisticView: View {
    enum Trend {
        case up, down, neutral
    }
    
    let title: String
    let value: String
    let unit: String
    var trend: Trend = .neutral
    
    var trendColor: Color {
        switch trend {
        case .up: return .red
        case .down: return .green
        case .neutral: return .primary
        }
    }
    
    var trendIcon: String {
        switch trend {
        case .up: return "arrow.up"
        case .down: return "arrow.down"
        case .neutral: return ""
        }
    }
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            HStack(spacing: 4) {
                if trend != .neutral {
                    Image(systemName: trendIcon)
                        .font(.caption)
                        .foregroundColor(trendColor)
                }
                
                Text(value)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(trend == .neutral ? .primary : trendColor)
            }
            
            Text(unit)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
}