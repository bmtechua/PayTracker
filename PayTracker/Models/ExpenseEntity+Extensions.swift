//
//  ExpenseEntity+Extensions.swift
//  PayTracker
//
//  Created by user on 01.01.2026.
//

import CoreData

extension ExpenseEntity {
    var wrappedTitle: String { title ?? "Без назви" }
    var wrappedCategory: String { categoryRel?.name ?? "Без категорії" }
}

