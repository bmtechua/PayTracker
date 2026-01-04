//
//  PayTrackerApp.swift
//  PayTracker
//
//  Created by user on 01.01.2026.
//

import SwiftUI

@main
struct PayTrackerApp: App {
    let persistence = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environment(\.managedObjectContext, persistence.context) // <- дуже важливо
        }
    }
}
