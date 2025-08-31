//
//  MainAppView.swift
//  Novo
//
//  Created by William Liu on 2025-08-30.
//

import SwiftUI

// MARK: - Main App View with Tab Bar
struct MainAppView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Summary Tab
            Text("Summary Content")
                .font(.title2)
                .tabItem {
                    Image(systemName: selectedTab == 0 ? "list.bullet.clipboard.fill" : "list.bullet.clipboard")
                    Text("Summary")
                }
                .tag(0)
            
            // Shots Tab
            Text("Shots Content")
                .font(.title2)
                .tabItem {
                    Image(systemName: selectedTab == 1 ? "syringe.fill" : "syringe")
                    Text("Shots")
                }
                .tag(1)
            
            // Results Tab
            Text("Results Content")
                .font(.title2)
                .tabItem {
                    Image(systemName: selectedTab == 2 ? "chart.bar.xaxis" : "chart.bar")
                    Text("Results")
                }
                .tag(2)
            
            // Calendar Tab
            Text("Calendar Content")
                .font(.title2)
                .tabItem {
                    Image(systemName: selectedTab == 3 ? "calendar" : "calendar")
                    Text("Calendar")
                }
                .tag(3)
            
            // Settings Tab
            Text("Settings Content")
                .font(.title2)
                .tabItem {
                    Image(systemName: selectedTab == 4 ? "gearshape.fill" : "gearshape")
                    Text("Settings")
                }
                .tag(4)
        }
        .accentColor(.blue)
    }
}