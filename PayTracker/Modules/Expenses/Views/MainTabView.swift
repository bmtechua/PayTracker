//
//  MainTabView.swift
//  PayTracker
//
//  Created by bmtech on 04.01.2026.
//

import SwiftUI

struct MainTabView: View {

    var body: some View {
        TabView {
            
            ExpensesListView()
                .tabItem {
                    Label("Всі", systemImage: "tray.full")
                }

            HomeView()
                .tabItem {
                    Label("Витрати", systemImage: "list.bullet")
                }
            
            
            CategoriesView()
                    .tabItem {
                        Label("Категорії", systemImage: "tag")
                    }

            ChartsView()
                .tabItem {
                    Label("Аналітика", systemImage: "chart.pie")
                }
           
            SettingsView()
                .tabItem {
                    Label("Налаштування", systemImage: "gear")
                }
        }
    }
}
