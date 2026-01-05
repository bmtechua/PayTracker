//
//  PersistenceController..swift
//  PayTracker
//
//  Created by user on 01.01.2026.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()
    let container: NSPersistentContainer
    var context: NSManagedObjectContext { container.viewContext }

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "PayTracker")
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores { _, error in
            if let error = error { fatalError("Core Data failed to load: \(error)") }
        }
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}

extension PersistenceController {
    func preloadBaseCategories() {
        let context = self.context

        // Перевіряємо, чи вже є категорії
        let request: NSFetchRequest<CategoryEntity> = CategoryEntity.fetchRequest()
        request.predicate = NSPredicate(format: "isPremium == NO")
        let count = (try? context.count(for: request)) ?? 0
        guard count == 0 else { return } // якщо вже є, нічого не додаємо

        // Базові категорії
        let baseCategories = [
            ("Їжа", "fork.knife", "#FF6B6B"),
            ("Транспорт", "car", "#1DD1A1"),
            ("Розваги", "gamecontroller", "#54A0FF"),
            ("Здоров’я", "heart", "#F368E0"),
            ("Інше", "tag", "#576574")
        ]

        for (name, icon, colorHex) in baseCategories {
            let cat = CategoryEntity(context: context)
            cat.id = UUID()
            cat.name = name
            cat.icon = icon
            cat.colorHex = colorHex
            cat.isPremium = false
        }

        try? context.save()
    }
}
