import SwiftUI
import CoreData

struct WeightTrackingView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var dataManager = DataManager.shared
    
    @State private var weight: String = ""
    @State private var selectedDate = Date()
    @State private var showingHistory = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Log Weight")) {
                    HStack {
                        TextField("Weight", text: $weight)
                            .keyboardType(.decimalPad)
                        
                        Text(dataManager.currentUserProfile?.useMetric == true ? "kg" : "lbs")
                            .foregroundColor(.secondary)
                    }
                    
                    DatePicker("Date", selection: $selectedDate, displayedComponents: .date)
                }
                
                if let currentWeight = dataManager.currentUserProfile?.currentWeight?.doubleValue {
                    Section(header: Text("Current Stats")) {
                        HStack {
                            Text("Current Weight")
                            Spacer()
                            Text(String(format: "%.1f %@", currentWeight, dataManager.currentUserProfile?.useMetric == true ? "kg" : "lbs"))
                                .foregroundColor(.secondary)
                        }
                        
                        if dataManager.totalWeightChange != 0 {
                            HStack {
                                Text("Total Change")
                                Spacer()
                                HStack(spacing: 4) {
                                    Image(systemName: dataManager.totalWeightChange < 0 ? "arrow.down" : "arrow.up")
                                        .font(.caption)
                                        .foregroundColor(dataManager.totalWeightChange < 0 ? .green : .red)
                                    Text(String(format: "%.1f %@", abs(dataManager.totalWeightChange), dataManager.currentUserProfile?.useMetric == true ? "kg" : "lbs"))
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        
                        if let bmi = dataManager.currentUserProfile?.calculateBMI() {
                            HStack {
                                Text("BMI")
                                Spacer()
                                Text(String(format: "%.1f", bmi))
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                
                Section {
                    Button {
                        showingHistory = true
                    } label: {
                        HStack {
                            Text("View History")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Weight Tracking")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveWeight()
                    }
                    .fontWeight(.bold)
                    .disabled(weight.isEmpty)
                }
            }
            .sheet(isPresented: $showingHistory) {
                WeightHistoryView()
            }
        }
    }
    
    private func saveWeight() {
        guard let weightValue = Double(weight) else { return }
        dataManager.logWeight(weightValue)
        dismiss()
    }
}

struct WeightHistoryView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var dataManager = DataManager.shared
    @State private var weightHistory: [WeightEntry] = []
    
    var body: some View {
        NavigationView {
            List {
                ForEach(weightHistory, id: \.id) { entry in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(entry.date, style: .date)
                                .font(.subheadline)
                            Text(entry.date, style: .time)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Text(String(format: "%.1f %@", entry.weight, dataManager.currentUserProfile?.useMetric == true ? "kg" : "lbs"))
                            .font(.headline)
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Weight History")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                weightHistory = dataManager.getWeightHistory()
            }
        }
    }
}