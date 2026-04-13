//
//  ExpenseService.swift
//  PayTracker
//
//  Created by bmtech on 13.04.2026.
//

import Foundation

struct ExpenseService {

    private let coreData = CoreDataService.shared

    func fetchExpenses() -> [ExpenseEntity] {
        coreData.fetchExpenses()
    }

    func groupByDay(_ expenses: [ExpenseEntity]) -> [DayGroup] {

        let grouped = Dictionary(grouping: expenses) {
            Calendar.current.startOfDay(for: $0.date ?? Date())
        }

        return grouped.map { (date, expenses) in
            DayGroup(date: date, expenses: expenses)
        }
        .sorted { $0.date > $1.date }
    }
}
