//
//  CoreDataService.swift
//  PayTracker
//
//  Created by bmtech on 13.04.2026.
//

import CoreData

class CoreDataService {

    static let shared = CoreDataService()

    private let context = PersistenceController.shared.container.viewContext

    func fetchExpenses() -> [ExpenseEntity] {
        let request: NSFetchRequest<ExpenseEntity> = ExpenseEntity.fetchRequest()

        do {
            return try context.fetch(request)
        } catch {
            print("Fetch error:", error)
            return []
        }
    }

    func save() {
        do {
            try context.save()
        } catch {
            print("Save error:", error)
        }
    }
}
