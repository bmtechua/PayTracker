//
//  SettingsView.swift
//  PayTracker
//
//  Created by bmtech on 04.01.2026.
//

import SwiftUI

enum AppCurrency: String, CaseIterable, Identifiable {
    case uah = "₴ UAH"
    case usd = "$ USD"
    case eur = "€ EUR"
    case cad = "C$ CAD"

    var id: String { rawValue }

    var symbol: String {
        switch self {
        case .uah: return "₴"
        case .usd: return "$"
        case .eur: return "€"
        case .cad: return "C$"
        }
    }
}

enum AppTheme: String, CaseIterable, Identifiable {
    case system = "Системна"
    case light = "Світла"
    case dark = "Темна"

    var id: String { rawValue }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}

struct SettingsView: View {

    @AppStorage("currency") private var currency: AppCurrency = .uah
    @AppStorage("theme") private var theme: AppTheme = .system
    @AppStorage("isPremiumUser") private var isPremiumUser = false

    var body: some View {
        NavigationStack {
            Form {

                // 💱 Валюта
                Section(header: Text("Валюта")) {
                    Picker("Основна валюта", selection: $currency) {
                        ForEach(AppCurrency.allCases) { currency in
                            Text(currency.rawValue)
                                .tag(currency)
                        }
                    }
                    .pickerStyle(.navigationLink)
                }

                // 🎨 Тема
                Section(header: Text("Оформлення")) {
                    Picker("Тема", selection: $theme) {
                        ForEach(AppTheme.allCases) { theme in
                            Text(theme.rawValue)
                                .tag(theme)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                // Преміум
                Section {
                    if isPremiumUser {
                        NavigationLink("Категорії", destination: CategoriesView())
                    } else {
                        HStack {
                            Text("Категорії")
                            Spacer()
                            Image(systemName: "lock.fill")
                        }
                        .onTapGesture {
                            // показати paywall / toast
                        }
                    }
                }
                Section(header: Text("Дані")) {
                    // 📊 Activity Log
                    NavigationLink {
                        ActivityListView()
                    } label: {
                        HStack {
                            Text("Активність")
                            Spacer()
                            Image(systemName: "clock.arrow.circlepath")
                                .foregroundColor(.gray)
                        }
                    }
                }

                // ℹ️ Інфо
                Section {
                    HStack {
                        Text("Версія")
                        Spacer()
                        Text(Bundle.main.appVersion)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Налаштування")
        }
    }
}
