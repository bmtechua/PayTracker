//
//  PayTrackerApp.swift
//  PayTracker
//
//  Created by user on 01.01.2026.
//

import SwiftUI

@main
struct PayTrackerApp: App {
    let persistenceController = PersistenceController.shared

       var body: some Scene {
           WindowGroup {
               MainTabView()
                   .environment(
                       \.managedObjectContext,
                       persistenceController.context
                   )
           }
       }
    }

