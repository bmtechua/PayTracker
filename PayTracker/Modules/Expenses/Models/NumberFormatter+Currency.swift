//
//  NumberFormatter+Currency.swift
//  PayTracker
//
//  Created by bmtech on 05.01.2026.
//

import Foundation

struct CurrencyFormatter {

    static func string(
        amount: Double,
        currencyCode: String,
        locale: Locale = .current
    ) -> String {

        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = locale
        formatter.currencyCode = currencyCode
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2

        return formatter.string(from: NSNumber(value: amount)) ?? "\(amount)"
    }
}
