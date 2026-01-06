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

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \CategoryEntity.name, ascending: true)]
    )
    private var categories: FetchedResults<CategoryEntity>

    @State private var showAddCategory = false
    @State private var categoryToEdit: CategoryEntity?

    private var isPremiumUser: Bool {
        categories.contains(where: { $0.isPremium })
    }

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

                        if category.isPremium {
                            Button("Редагувати") {
                                categoryToEdit = category
                                showAddCategory = true
                            }
                            .buttonStyle(.borderless)
                        } else {
                            Text("Базова")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .onDelete { indexSet in
                    indexSet
                        .map { categories[$0] }
                        .filter { $0.isPremium }
                        .forEach(context.delete)

                    try? context.save()
                }
            }
            .navigationTitle("Категорії")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if isPremiumUser {
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
}
