//
//  Untitled.swift
//  PayTracker
//
//  Created by user on 01.01.2026.
//

import CoreData

extension CategoryEntity {
    var wrappedName: String { name ?? "Без назви" }
    var wrappedExpenses: [ExpenseEntity] {
        (expenses?.allObjects as? [ExpenseEntity]) ?? []
    }
}
