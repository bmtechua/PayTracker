//
//  ActivityLogger.swift
//  PayTracker
//
//  Created by bmtech on 14.04.2026.
//

import CoreData

final class ActivityLogger {

    static func log(
        _ type: ActivityType,
        title: String,
        message: String = "",
        context: NSManagedObjectContext
    ) {

        let log = ActivityLogEntity(context: context)
        log.id = UUID()
        log.type = type.rawValue
        log.title = title
        log.message = message
        log.date = Date()

        do {
            try context.save()
        } catch {
            print("❌ Activity log error:", error)
        }
    }
}
