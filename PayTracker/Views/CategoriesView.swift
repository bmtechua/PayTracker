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

    var body: some View {
        NavigationStack {
            List {
                ForEach(categories, id: \.self) { category in
                    HStack {
                        // Іконка + колір
                        Image(systemName: category.icon ?? "tag")
                            .foregroundColor(Color(category.colorHex ?? "#999999"))

                        Text(category.name ?? "")
                            .font(.body)

                        Spacer()

                        Button("Редагувати") {
                            categoryToEdit = category
                            showAddCategory = true
                        }
                        .buttonStyle(BorderlessButtonStyle())
                    }
                }
                .onDelete(perform: deleteCategory)
            }
            .navigationTitle("Категорії")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        categoryToEdit = nil
                        showAddCategory = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddCategory) {
                AddCategoryView(
                    categoryToEdit: categoryToEdit,
                    onSave: {
                        // автоматично оновлюємо список після додавання/редагування
                        showAddCategory = false
                    }
                )
                .environment(\.managedObjectContext, context)
            }
        }
    }

    private func deleteCategory(at offsets: IndexSet) {
        offsets.map { categories[$0] }.forEach { context.delete($0) }
        do {
            try context.save()
        } catch {
            print("Помилка видалення категорії:", error)
        }
    }
}

#Preview {
    let persistence = PersistenceController.shared
    let context = persistence.context

    CategoriesView()
        .environment(\.managedObjectContext, context)
}
