//
//  CategoryBootstrap.swift
//  PayTracker
//
//  Created by bmtech on 06.01.2026.
//

import CoreData

struct CategoryBootstrap {

    static func addBaseCategoriesIfNeeded(context: NSManagedObjectContext) {

        let request: NSFetchRequest<CategoryEntity> = CategoryEntity.fetchRequest()
        request.predicate = NSPredicate(format: "isPremium == NO")

        let count = (try? context.count(for: request)) ?? 0
        guard count == 0 else { return }

        BaseCategory.allCases.forEach { base in
            let c = CategoryEntity(context: context)
            c.id = UUID()
            c.name = base.name
            c.icon = base.icon
            c.colorHex = base.colorHex
            c.isPremium = false
        }

        try? context.save()
    }
}
