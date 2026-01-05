//
//  SettingsView.swift
//  PayTracker
//
//  Created by bmtech on 04.01.2026.
//

import SwiftUI

struct SettingsView: View {

    var body: some View {
        NavigationStack {
            List {
                Section("Загальні") {
                    Text("Валюта")
                    Text("Мова")
                }

                Section("Про додаток") {
                    Text("Версія 1.0")
                    Text("Розробник")
                }
            }
            .navigationTitle("Налаштування")
        }
    }
}
