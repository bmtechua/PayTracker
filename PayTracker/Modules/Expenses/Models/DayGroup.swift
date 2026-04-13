//
//  DayGroup.swift
//  PayTracker
//
//  Created by bmtech on 13.04.2026.
//
import SwiftUI
import CoreData


// MARK: - Day Group Model

struct DayGroup: Identifiable {
    let id = UUID()
    let date: Date
    let expenses: [ExpenseEntity]

    var total: Double {
        expenses.reduce(0) { $0 + $1.amount }
    }
}
