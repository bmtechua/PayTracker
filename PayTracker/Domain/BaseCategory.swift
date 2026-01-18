//
//  BaseCategory.swift
//  PayTracker
//
//  Created by bmtech on 18.01.2026.
//

enum BaseCategory: CaseIterable {

    case food
    case transport
    case entertainment
    case health
    case other

    var name: String {
        switch self {
        case .food: return "Їжа"
        case .transport: return "Транспорт"
        case .entertainment: return "Розваги"
        case .health: return "Здоровʼя"
        case .other: return "Інше"
        }
    }

    var icon: String {
        switch self {
        case .food: return "fork.knife"
        case .transport: return "car.fill"
        case .entertainment: return "gamecontroller.fill"
        case .health: return "cross.fill"
        case .other: return "square.grid.2x2.fill"
        }
    }

    var colorHex: String {
        switch self {
        case .food: return "#FF6B6B"
        case .transport: return "#4D96FF"
        case .entertainment: return "#FFD93D"
        case .health: return "#6BCF63"
        case .other: return "#999999"
        }
    }
}
