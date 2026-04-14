//
//  ExpenseService.swift
//  PayTracker
//
//  Created by bmtech on 13.04.2026.
//

import Foundation

import CoreData

struct ExpenseService {

    private let context = PersistenceController.shared.container.viewContext

    // MARK: - FETCH
    func fetchExpenses() -> [ExpenseEntity] {
        let request: NSFetchRequest<ExpenseEntity> = ExpenseEntity.fetchRequest()

        request.sortDescriptors = [
            NSSortDescriptor(key: "date", ascending: false)
        ]

        return (try? context.fetch(request)) ?? []
    }

    // MARK: - DELETE (рекомендую додати)
    func delete(_ expense: ExpenseEntity) {
        context.delete(expense)
        save()
    }

    // MARK: - SAVE
    private func save() {
        if context.hasChanges {
            try? context.save()
        }
    }

    // MARK: - GROUPING (у тебе вже добре)
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
/*
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
*/
