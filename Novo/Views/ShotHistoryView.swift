import SwiftUI
import Charts

struct ShotHistoryView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var dataManager = AppDataManager.shared
    @State private var showingAddShot = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Next Shot Card
                    NextShotCardDetailed()
                        .padding(.horizontal)
                    
                    // History Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("History")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        VStack(spacing: 0) {
                            // Month Header
                            HStack {
                                Text("AUGUST 2025")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .fontWeight(.medium)
                                Spacer()
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                            .background(Color(UIColor.systemGroupedBackground))
                            
                            // Shot entries
                            VStack(spacing: 0) {
                                ShotHistoryEntry(
                                    shotNumber: 6,
                                    date: "Mon, Aug 25 at 6:33pm",
                                    medication: "Tirzepatide",
                                    dose: "2.5mg",
                                    site: "Stomach - Upper Left",
                                    painLevel: 4,
                                    hasChart: true,
                                    chartData: [80.0, 90.0, 85.0, 88.0, 92.0],
                                    totalChange: "+20.0kg",
                                    avgCalories: "500kcal",
                                    avgProtein: "45g",
                                    notes: ""
                                )
                                
                                Divider()
                                    .padding(.leading)
                                
                                ShotHistoryEntry(
                                    shotNumber: 5,
                                    date: "Wed, Aug 13 at 1:18pm",
                                    medication: "Tirzepatide",
                                    dose: "2.5mg",
                                    site: "Stomach - Upper Left",
                                    painLevel: 0,
                                    hasChart: true,
                                    chartData: [85.0, 82.0, 80.0, 78.0, 76.0],
                                    totalChange: "—",
                                    avgCalories: "—",
                                    avgProtein: "—",
                                    notes: ""
                                )
                                
                                Divider()
                                    .padding(.leading)
                                
                                ShotHistoryEntry(
                                    shotNumber: 4,
                                    date: "Wed, Aug 13 at 10:42am",
                                    medication: "Tirzepatide",
                                    dose: "2.5mg",
                                    site: "Stomach - Upper Mid",
                                    painLevel: 0,
                                    hasChart: false,
                                    chartData: [],
                                    totalChange: "—",
                                    avgCalories: "—",
                                    avgProtein: "—",
                                    notes: ""
                                )
                            }
                            .background(Color(UIColor.secondarySystemBackground))
                        }
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
                    Text("Shots")
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

// MARK: - Next Shot Card Detailed
struct NextShotCardDetailed: View {
    var body: some View {
        VStack(spacing: 16) {
            // Dashed border container
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Shot 7")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    Text("Take Mon, Sep 1 at 6:33pm")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                HStack(spacing: 12) {
                    Text("Tirzepatide")
                        .font(.title3)
                        .fontWeight(.medium)
                    
                    Text("2.5mg")
                        .font(.subheadline)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.gray.opacity(0.3))
                        .cornerRadius(8)
                    
                    Button {
                        // Edit action
                    } label: {
                        Image(systemName: "pencil")
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                }
                
                Text("Stomach - Upper Left")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(16)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(style: StrokeStyle(lineWidth: 2, dash: [8, 4]))
                    .foregroundColor(.gray.opacity(0.5))
            )
        }
    }
}

// MARK: - Shot History Entry
struct ShotHistoryEntry: View {
    let shotNumber: Int
    let date: String
    let medication: String
    let dose: String
    let site: String
    let painLevel: Int
    let hasChart: Bool
    let chartData: [Double]
    let totalChange: String
    let avgCalories: String
    let avgProtein: String
    let notes: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Shot header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Shot \(shotNumber)")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text(date)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button {
                    // Delete action
                } label: {
                    Image(systemName: "trash")
                        .foregroundColor(.gray)
                }
            }
            
            // Medication info
            HStack(spacing: 12) {
                Text(medication)
                    .font(.title3)
                    .fontWeight(.medium)
                
                Text(dose)
                    .font(.subheadline)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.gray.opacity(0.3))
                    .cornerRadius(8)
                
                Button {
                    // Edit action
                } label: {
                    Image(systemName: "pencil")
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                if painLevel > 0 {
                    Text("Pain: \(painLevel)/10")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Text(site)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            // Chart if available
            if hasChart && !chartData.isEmpty {
                VStack(spacing: 12) {
                    Chart {
                        ForEach(Array(chartData.enumerated()), id: \.offset) { index, value in
                            AreaMark(
                                x: .value("Day", index),
                                y: .value("Weight", value)
                            )
                            .foregroundStyle(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.yellow.opacity(0.6), Color.yellow.opacity(0.1)]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            
                            LineMark(
                                x: .value("Day", index),
                                y: .value("Weight", value)
                            )
                            .foregroundStyle(Color.yellow)
                            .lineStyle(StrokeStyle(lineWidth: 2))
                        }
                    }
                    .frame(height: 100)
                    .chartYScale(domain: 70...100)
                    .chartXAxis(.hidden)
                    .chartYAxis {
                        AxisMarks(position: .trailing) { _ in
                            AxisGridLine()
                            AxisValueLabel()
                        }
                    }
                    
                    // Stats cards
                    HStack(spacing: 12) {
                        ShotStatsSmallCard(
                            icon: "scalemass",
                            title: "Total change",
                            value: totalChange,
                            backgroundColor: totalChange != "—" ? .yellow : .gray.opacity(0.1)
                        )
                        
                        ShotStatsSmallCard(
                            icon: "flame.fill",
                            title: "Avg Calories",
                            value: avgCalories,
                            backgroundColor: .gray.opacity(0.1)
                        )
                        
                        ShotStatsSmallCard(
                            icon: "chart.bar.fill",
                            title: "Avg Protein",
                            value: avgProtein,
                            backgroundColor: .gray.opacity(0.1)
                        )
                    }
                }
            }
            
            // Shot notes
            VStack(alignment: .leading, spacing: 8) {
                Text("Shot notes")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                if notes.isEmpty {
                    Rectangle()
                        .fill(Color.gray.opacity(0.1))
                        .frame(height: 1)
                } else {
                    Text(notes)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
    }
}

// MARK: - Shot Stats Small Card
struct ShotStatsSmallCard: View {
    let icon: String
    let title: String
    let value: String
    let backgroundColor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .foregroundColor(.primary)
                    .font(.caption)
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
            
            Spacer(minLength: 0)
        }
        .padding(8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 60)
        .background(backgroundColor)
        .cornerRadius(8)
    }
}