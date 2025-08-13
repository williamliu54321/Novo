//
//  NovoApp.swift
//  Novo
//
//  Created by William Liu on 2025-08-12.
//

import SwiftUI

@main
struct NovoApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
