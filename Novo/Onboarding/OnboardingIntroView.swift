////
////  OnboardingPageInfo 2.swift
////  Novo
////
////  Created by William Liu on 2025-08-21.
////
//
//
//// MARK: - OnboardingIntroView.swift
//
//import SwiftUI
//import UIKit // Needed for styling the page dots
//
//// A blueprint for a single swipeable intro page
//struct OnboardingPageInfo: Identifiable {
//    let id = UUID()
//    let sfSymbolName: String
//    let title: String
//    let description: String
//}
//
//// A private helper view to display one intro page
//private struct OnboardingPageView: View {
//    let page: OnboardingPageInfo
//    var body: some View {
//        VStack(spacing: 20) {
//            ZStack {
//                RoundedRectangle(cornerRadius: 30).fill(Color(uiColor: .systemGray6))
//                    .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
//                Image(systemName: page.sfSymbolName).resizable().scaledToFit().frame(width: 100, height: 100).foregroundColor(.secondary)
//            }.frame(height: 350).padding(40)
//            Text(page.title).font(.title).fontWeight(.bold).multilineTextAlignment(.center).padding(.horizontal)
//            Text(page.description).font(.body).foregroundStyle(.secondary).multilineTextAlignment(.center).padding(.horizontal, 30)
//            Spacer()
//        }
//    }
//}
//
//
//// MARK: - The Main Intro View
//struct OnboardingIntroView: View {
//    // This is a "callback". It's a function the parent view will provide
//    // so this view can tell the parent when the "Get Started" button was tapped.
//    let onGetStarted: () -> Void
//    
//    // The state and data for the intro pages now live here.
//    @State private var currentPageIndex = 0
//    private let introPages: [OnboardingPageInfo] = [
//        .init(sfSymbolName: "camera.viewfinder", title: "Snack, Snap & Track in Seconds", description: "Just snap a photo of your meal—and instantly log protein, fiber, and more."),
//        .init(sfSymbolName: "pawprint.fill", title: "Virtual Capybara, Real Motivation", description: "Get gentle nudges and good vibes as you log your protein, fiber, water, and steps."),
//        .init(sfSymbolName: "chart.line.uptrend.xyaxis", title: "Watch Your Weight Transform", description: "Clear trends and milestones. With MeAgain, you'll see your progress day by day."),
//        .init(sfSymbolName: "list.bullet.clipboard.fill", title: "Stay on top of your GLP-1 journey", description: "See your current dose, progress metrics, and daily goals—all in one place.")
//    ]
//    
//    init(onGetStarted: @escaping () -> Void) {
//        self.onGetStarted = onGetStarted
//        // Style the page dots for this specific view
//        UIPageControl.appearance().currentPageIndicatorTintColor = .black
//        UIPageControl.appearance().pageIndicatorTintColor = UIColor.black.withAlphaComponent(0.2)
//    }
//
//    var body: some View {
//        VStack(spacing: 0) {
//            // The TabView for swiping through pages
//            TabView(selection: $currentPageIndex) {
//                ForEach(introPages.indices, id: \.self) { index in
//                     OnboardingPageView(page: introPages[index]).tag(index)
//                }
//            }
//            .tabViewStyle(.page(indexDisplayMode: .always))
//            
//            // The "Get Started" button
//            Button {
//                // When tapped, we call the `onGetStarted` function
//                // that was passed in from the parent view.
//                onGetStarted()
//            } label: {
//                Text("Get Started")
//                    .font(.headline).fontWeight(.bold).foregroundColor(.white)
//                    .frame(maxWidth: .infinity).padding().background(Color.black).cornerRadius(16)
//            }
//            .padding(20)
//        }
//    }
//}
