//
//  PayTrackerApp.swift
//  PayTracker
//
//  Created by user on 01.01.2026.
//

import SwiftUI

@main
struct PayTrackerApp: App {
    
    @AppStorage("currency") private var currency: AppCurrency = .systemDefault()
    @AppStorage("theme") private var theme: AppTheme = .system
    
    @StateObject var userManager = UserManager()
    @StateObject var toastManager = ToastManager()
    
    let persistenceController = PersistenceController.shared
    
    init() {
            persistenceController.preloadBaseCategories()
        }


       var body: some Scene {
           WindowGroup {
               ToastContainer {
                   MainTabView()
                       .environment(
                        \.managedObjectContext,
                         persistenceController.context
                       )
                       
                       .preferredColorScheme(theme.colorScheme)
               }
               .environmentObject(toastManager)
               .onAppear {
                                       CategoryBootstrap
                                           .addBaseCategoriesIfNeeded(
                                               context: persistenceController.context
                                           )
                                   }
               
           }
       }
    }

