//
//  AppLoger.swift
//  PayTracker
//
//  Created by bmtech on 14.04.2026.
//

import Foundation
import os

struct AppLogger {
    
    static let expense = Logger(subsystem: "com.paytracker.app", category: "Expense")
    static let category = Logger(subsystem: "com.paytracker.app", category: "Category")
    static let coredata = Logger(subsystem: "com.paytracker.app", category: "CoreData")
}
