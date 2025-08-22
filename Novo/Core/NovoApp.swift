//
//  TestingApp.swift
//  Testing
//
//  Created by William Liu on 2025-08-13.
//

import SwiftUI

@main
struct NovoApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

