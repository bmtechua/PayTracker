//
//  CategoriesView.swift
//  PayTracker
//
//  Created by user on 01.01.2026.
//

import SwiftUI
import CoreData

struct CategoriesView: View {
    @Environment(\.managedObjectContext) private var context
    @EnvironmentObject var userManager: UserManager

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \CategoryEntity.name, ascending: true)]
    )
    private var categories: FetchedResults<CategoryEntity>

    @State private var showAddCategory = false
    @State private var categoryToEdit: CategoryEntity?

    // Базові категорії
    private let baseCategories = [
        ("Їжа", "fork.knife", "#FF6B6B"),
        ("Транспорт", "car", "#4ECDC4"),
        ("Розваги", "gamecontroller", "#FFD93D"),
        ("Комунальні", "house.fill", "#32CD32")
    ]

    var body: some View {
        NavigationStack {
            List {
                // 🔹 Базові категорії
                ForEach(baseCategories, id: \.0) { item in
                    HStack {
                        Image(systemName: item.1)
                            .foregroundColor(Color(hex: item.2))
                        Text(item.0)
                        Spacer()
                        if userManager.isPremium {
                            Button("Редагувати") {
                                // для базових категорій можна реалізувати клон
                                categoryToEdit = nil
                                showAddCategory = true
                            }
                            .buttonStyle(BorderlessButtonStyle())
                        }
                    }
                }

                // 🔹 Користувацькі категорії
                ForEach(categories, id: \.self) { category in
                    HStack {
                        Image(systemName: category.icon ?? "tag")
                            .foregroundColor(Color(hex: category.colorHex ?? "#999999"))
                        Text(category.name ?? "")
                        Spacer()
                        if userManager.isPremium {
                            Button("Редагувати") {
                                categoryToEdit = category
                                showAddCategory = true
                            }
                            .buttonStyle(BorderlessButtonStyle())
                        }
                    }
                }
                .onDelete { offsets in
                    if userManager.isPremium {
                        deleteCategory(at: offsets)
                    }
                }
            }
            .navigationTitle("Категорії")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if userManager.isPremium {
                        Button {
                            categoryToEdit = nil
                            showAddCategory = true
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                }
            }
            .sheet(isPresented: $showAddCategory) {
                AddCategoryView(
                    categoryToEdit: categoryToEdit,
                    onSave: {
                        showAddCategory = false
                    }
                )
                .environment(\.managedObjectContext, context)
            }
        }
    }

    private func deleteCategory(at offsets: IndexSet) {
        offsets.map { categories[$0] }.forEach { context.delete($0) }
        do { try context.save() } catch { print("Помилка видалення категорії:", error) }
    }
}

// Preview
#Preview {
    let persistence = PersistenceController.shared
    let context = persistence.context
    CategoriesView()
        .environment(\.managedObjectContext, context)
}
