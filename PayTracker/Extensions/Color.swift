//
//  Color.swift
//  PayTracker
//
//  Created by bmtech on 05.01.2026.
//

import SwiftUI

extension Color {
    func toHex() -> String {
        #if canImport(UIKit)
        let uiColor = UIColor(self)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return String(format:"#%02X%02X%02X", Int(red*255), Int(green*255), Int(blue*255))
        #else
        return "#999999" // fallback
        #endif
    }
}



let defaults: [(String, String, String)] = [
    ("Їжа", "fork.knife", "#FF6347"),
    ("Транспорт", "car.fill", "#1E90FF"),
    ("Розваги", "gamecontroller.fill", "#FFD700"),
    ("Комунальні", "house.fill", "#32CD32")
]
