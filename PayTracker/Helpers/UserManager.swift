//
//  UserManager.swift
//  PayTracker
//
//  Created by bmtech on 05.01.2026.
//

import SwiftUI
import Combine

final class UserManager: ObservableObject {
    // Чи є у користувача преміум-доступ
    @Published var isPremium: Bool = false
    
    // Можеш додати інші налаштування користувача
    @Published var username: String = "Guest"
    
    // Метод для активації преміум
    func activatePremium() {
        isPremium = true
    }
}
