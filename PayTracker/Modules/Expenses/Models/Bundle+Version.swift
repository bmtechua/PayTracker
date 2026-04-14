//
//  Bundle+Version.swift
//  PayTracker
//
//  Created by bmtech on 05.01.2026.
//

import Foundation

extension Bundle {
    var appVersion: String {
        let version = infoDictionary?["CFBundleShortVersionString"] as? String ?? "—"
        let build = infoDictionary?["CFBundleVersion"] as? String ?? "—"
        return "\(version) (\(build))"
    }
}
