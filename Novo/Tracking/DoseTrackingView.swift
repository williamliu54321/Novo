import SwiftUI
import CoreData

struct DoseTrackingView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var dataManager = DataManager.shared
    
    @State private var selectedDate = Date()
    @State private var dose: String = ""
    @State private var injectionSite = "Stomach - Upper Left"
    @State private var painLevel: Double = 0
    @State private var notes = ""
    
    let injectionSites = [
        "Stomach - Upper Left",
        "Stomach - Upper Right",
        "Stomach - Lower Left",
        "Stomach - Lower Right",
        "Thigh - Left",
        "Thigh - Right",
        "Upper Arm - Left",
        "Upper Arm - Right"
    ]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Dose Information")) {
                    DatePicker("Date", selection: $selectedDate, displayedComponents: [.date, .hourAndMinute])
                    
                    HStack {
                        Text("Medication")
                        Spacer()
                        Text(dataManager.currentUserProfile?.medication ?? "GLP-1")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        TextField("Dose", text: $dose)
                            .keyboardType(.decimalPad)
                        Text("mg")
                            .foregroundColor(.secondary)
                    }
                    .onAppear {
                        if let currentDose = dataManager.currentUserProfile?.dose?.doubleValue {
                            dose = String(format: "%.2f", currentDose)
                        }
                    }
                }
                
                Section(header: Text("Injection Details")) {
                    Picker("Injection Site", selection: $injectionSite) {
                        ForEach(injectionSites, id: \.self) { site in
                            Text(site).tag(site)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Pain Level")
                            Spacer()
                            Text("\(Int(painLevel))")
                                .foregroundColor(.secondary)
                        }
                        
                        Slider(value: $painLevel, in: 0...10, step: 1)
                            .tint(painLevelColor)
                    }
                }
                
                Section(header: Text("Notes")) {
                    ZStack(alignment: .topLeading) {
                        TextEditor(text: $notes)
                            .frame(minHeight: 80)
                        
                        if notes.isEmpty {
                            Text("Add any notes about this dose...")
                                .foregroundColor(.secondary.opacity(0.7))
                                .padding(.horizontal, 5)
                                .padding(.top, 8)
                                .allowsHitTesting(false)
                        }
                    }
                }
                
                if let lastDose = dataManager.getDoseHistory(limit: 1).first {
                    Section(header: Text("Last Dose")) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(lastDose.date, style: .date)
                                    .font(.subheadline)
                                Text("\(String(format: "%.2f", lastDose.dose)) mg")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Text(lastDose.injectionSite)
                                .font(.caption)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 4)
                                .background(Color.purple.opacity(0.1))
                                .cornerRadius(12)
                        }
                    }
                }
            }
            .navigationTitle("Log Dose")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveDose()
                    }
                    .fontWeight(.bold)
                    .disabled(dose.isEmpty)
                }
            }
        }
    }
    
    private var painLevelColor: Color {
        if painLevel < 3 {
            return .green
        } else if painLevel < 7 {
            return .orange
        } else {
            return .red
        }
    }
    
    private func saveDose() {
        guard let doseValue = Double(dose) else { return }
        dataManager.logDose(dose: doseValue, site: injectionSite, painLevel: Int(painLevel), notes: notes.isEmpty ? nil : notes)
        dismiss()
    }
}