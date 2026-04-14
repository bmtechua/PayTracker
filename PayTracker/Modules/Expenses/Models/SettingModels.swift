//
//  SettingModels.swift
//  PayTracker
//
//  Created by bmtech on 05.01.2026.
//

import Foundation

extension AppCurrency {

    static func systemDefault() -> AppCurrency {
        let locale = Locale.current
        
        // Для iOS 16+
        let code = locale.currency?.identifier ?? "UAH"

        switch code {
        case "UAH": return .uah
        case "USD": return .usd
        case "EUR": return .eur
        case "CAD": return .cad
        default: return .uah
        }
    }

    var currencyCode: String {
        switch self {
        case .uah: return "UAH"
        case .usd: return "USD"
        case .eur: return "EUR"
        case .cad: return "CAD"
        }
    }
}
