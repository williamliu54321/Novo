//
//  OnboardingPageInfo.swift
//  Novo
//
//  Created by William Liu on 2025-08-20.
//


//
//  OnboardingIntroView.swift
//  YourAppName
//
//  This file contains the complete, swipeable onboarding experience
//  with a fix to ensure the page indicator dots are always visible.
//

import SwiftUI
import UIKit // We need to import UIKit to access UIPageControl

// MARK: - Data Model for a Single Onboarding Page
struct OnboardingPageInfo: Identifiable {
    let id = UUID()
    let sfSymbolName: String
    let title: String
    let description: String
}

// MARK: - Main Onboarding Container View
struct OnboardingIntroView: View {
    
    var onComplete: () -> Void
    
    private let pages: [OnboardingPageInfo] = [
        .init(sfSymbolName: "camera.viewfinder",
              title: "Snack, Snap & Track in Seconds",
              description: "Just snap a photo of your meal—and instantly log protein, fiber, and more."),
        .init(sfSymbolName: "pawprint.fill",
              title: "Virtual Capybara, Real Motivation",
              description: "Get gentle nudges and good vibes as you log your protein, fiber, water, and steps."),
        .init(sfSymbolName: "chart.line.uptrend.xyaxis",
              title: "Watch Your Weight Transform",
              description: "Clear trends and milestones. With MeAgain, you'll see your progress day by day."),
        .init(sfSymbolName: "list.bullet.clipboard.fill",
              title: "Stay on top of your GLP-1 journey",
              description: "See your current dose, progress metrics, and daily goals—all in one place.")
    ]
    
    @State private var currentPageIndex = 0

    // --- THIS IS THE FIX ---
    // We add an initializer to the view. This code runs only once when
    // the view is first created.
    init(onComplete: @escaping () -> Void) {
        self.onComplete = onComplete
        
        // This targets the underlying UIPageControl that SwiftUI uses.
        // We set the color for the currently selected dot (black).
        UIPageControl.appearance().currentPageIndicatorTintColor = .black
        // We set the color for the inactive dots (a light, transparent black).
        UIPageControl.appearance().pageIndicatorTintColor = UIColor.black.withAlphaComponent(0.2)
    }

    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $currentPageIndex) {
                ForEach(pages.indices, id: \.self) { index in
                     OnboardingPageView(page: pages[index])
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always)) // This line creates the dots
            
            Button(action: onComplete) {
                Text("Get Started")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.black)
                    .cornerRadius(16)
            }
            .padding(20)
        }
    }
}


// MARK: - Reusable View for a Single Onboarding Page's Content
private struct OnboardingPageView: View {
    let page: OnboardingPageInfo
    
    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                RoundedRectangle(cornerRadius: 30)
                    .fill(Color(uiColor: .systemGray6))
                    .shadow(color: .black.opacity(0.1), radius: 10, y: 5)

                Image(systemName: page.sfSymbolName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.secondary)
            }
            .frame(height: 350)
            .padding(40)
            
            Text(page.title)
                .font(.title).fontWeight(.bold).multilineTextAlignment(.center).padding(.horizontal)

            Text(page.description)
                .font(.body).foregroundStyle(.secondary).multilineTextAlignment(.center).padding(.horizontal, 30)
            
            Spacer()
        }
    }
}

// MARK: - SwiftUI Preview
struct OnboardingIntroView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingIntroView(onComplete: {})
    }
}
