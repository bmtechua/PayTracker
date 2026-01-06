//
//  CategoryBootstrap.swift
//  PayTracker
//
//  Created by bmtech on 06.01.2026.
//

import CoreData

struct CategoryBootstrap {

    private static let key = "baseCategoriesAdded_v1"

    static func addBaseCategoriesIfNeeded(context: NSManagedObjectContext) {
        guard !UserDefaults.standard.bool(forKey: key) else { return }

        let base: [(String, String, String)] = [
            ("Їжа", "fork.knife", "#FF6B6B"),
            ("Транспорт", "car.fill", "#4D96FF"),
            ("Розваги", "gamecontroller.fill", "#FFD93D"),
            ("Здоровʼя", "cross.fill", "#6BCF63"),
            ("Інше", "square.grid.2x2.fill", "#999999")
        ]

        for item in base {
            let c = CategoryEntity(context: context)
            c.id = UUID()
            c.name = item.0
            c.icon = item.1
            c.colorHex = item.2
            c.isPremium = false   // 🔒 базова
        }

        try? context.save()
        UserDefaults.standard.set(true, forKey: key)
    }
}
