//
//  AddExpenseView.swift
//  PayTracker
//
//  Created by user on 01.01.2026.
//

import SwiftUI
import CoreData

struct AddExpenseView: View {

    @Environment(\.managedObjectContext) private var context
    @Environment(\.dismiss) private var dismiss

    var expenseToEdit: ExpenseEntity?
    var onSave: (() -> Void)? = nil

    @State private var title = ""
    @State private var selectedCategory: CategoryEntity?
    @State private var amount = ""
    @State private var date = Date()

    @State private var showAddCategoryView = false

    // Підтягуємо всі категорії з Core Data
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \CategoryEntity.name, ascending: true)]
    )
    private var categories: FetchedResults<CategoryEntity>

    var body: some View {
        NavigationStack {
            Form {
                TextField("Назва витрати", text: $title)

                Picker("Категорія", selection: $selectedCategory) {
                    ForEach(categories, id: \.self) { category in
                        Label(category.name ?? "",
                              systemImage: category.icon ?? "tag")
                            .foregroundColor(Color(category.colorHex ?? "#999999"))
                            .tag(category as CategoryEntity?)
                    }

                    // Додати нову категорію
                    Text("➕ Додати категорію").tag(nil as CategoryEntity?)
                }
                .onChange(of: selectedCategory) { newValue in
                    if newValue == nil {
                        showAddCategoryView = true
                    }
                }

                TextField("Сума", text: $amount)
                    .keyboardType(.decimalPad)

                DatePicker("Дата", selection: $date, displayedComponents: .date)
            }
            .navigationTitle(expenseToEdit == nil ? "Нова витрата" : "Редагувати")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Зберегти") { saveExpense() }
                        .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty || selectedCategory == nil || Double(amount) == nil)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Скасувати") { dismiss() }
                }
            }
            .sheet(isPresented: $showAddCategoryView) {
                AddCategoryView(
                    categoryToEdit: nil,
                    onSave: {
                        // Після додавання нової категорії вибираємо її
                        selectedCategory = categories.last
                        showAddCategoryView = false
                    }
                )
                .environment(\.managedObjectContext, context)
            }
            .onAppear {
                if let expense = expenseToEdit {
                    title = expense.title ?? ""
                    selectedCategory = expense.categoryRel
                    amount = String(expense.amount)
                    date = expense.date ?? Date()
                } else {
                    selectedCategory = categories.first
                }
            }
        }
    }

    private func saveExpense() {
        guard
            !title.isEmpty,
            let category = selectedCategory,
            let amountValue = Double(amount)
        else { return }

        let expense = expenseToEdit ?? ExpenseEntity(context: context)
        if expenseToEdit == nil { expense.id = UUID() }

        expense.title = title
        expense.categoryRel = category
        expense.amount = amountValue
        expense.date = date

        do {
            try context.save()
            dismiss()
            onSave?()
        } catch {
            print("Помилка збереження витрати:", error)
        }
    }
}

#Preview {
    AddExpenseView()
}
