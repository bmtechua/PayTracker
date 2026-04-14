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
    @EnvironmentObject var toastManager: ToastManager

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \CategoryEntity.name, ascending: true)]
    )
    private var categories: FetchedResults<CategoryEntity>

    @State private var showAddCategory = false
    @State private var categoryToEdit: CategoryEntity?


    var body: some View {
        NavigationStack {
            List {
                ForEach(categories) { category in
                    HStack {
                        Image(systemName: category.icon ?? "tag")
                            .foregroundColor(
                                Color(hex: category.colorHex ?? "#999999")
                            )

                        Text(category.name ?? "")
                        Spacer()

                        if !category.isPremium {
                            HStack(spacing: 4) {
                                Image(systemName: "lock.fill")
                                    .font(.caption2)
                                Text("Базова")
                                    .font(.caption)
                            }
                            .foregroundColor(.secondary)

                        } else if userManager.isPremium {
                            Button("Редагувати") {
                                categoryToEdit = category
                                showAddCategory = true
                            }
                            .buttonStyle(.borderless)

                        } else {
                            HStack(spacing: 4) {
                                Image(systemName: "lock.fill")
                                    .font(.caption2)
                                Text("Premium")
                                    .font(.caption)
                            }
                            .foregroundColor(.orange)
                        }
                    }
                }
                .onDelete { indexSet in
                    guard userManager.isPremium else {
                        toastManager.show(
                            "Видалення категорій доступне в Premium",
                        )
                        return
                    }

                    let deletable = indexSet
                        .map { categories[$0] }
                        .filter { $0.isPremium }

                    guard !deletable.isEmpty else {
                        toastManager.show(
                            "Базові категорії не можна видаляти"
                        )
                        return
                    }

                    deletable.forEach(context.delete)
                    try? context.save()
                }


            }
            .navigationTitle("Категорії")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        if userManager.isPremium {
                            categoryToEdit = nil
                            showAddCategory = true
                        } else {
                            toastManager.show(
                                "Додавання категорій доступне в Premium"
                            )
                        }
                    } label: {
                        Image(systemName: "plus")
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
}

#Preview {
    let persistence = PersistenceController.shared
    let context = persistence.context

    CategoriesView()
        .environment(\.managedObjectContext, context)
}
