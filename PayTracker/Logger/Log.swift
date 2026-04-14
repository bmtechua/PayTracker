//
//  Log.swift
//  PayTracker
//
//  Created by bmtech on 14.04.2026.
//

struct Log {
    
    static func expense(_ message: String) {
        FileLogger.shared.log("💰 EXPENSE: \(message)")
    }
    
    static func category(_ message: String) {
        FileLogger.shared.log("🏷 CATEGORY: \(message)")
    }
    
    static func coredata(_ message: String) {
        FileLogger.shared.log("🗄 CORE DATA: \(message)")
    }
}
