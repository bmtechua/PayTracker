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
    @EnvironmentObject var toastManager: ToastManager // 🔹 отримуємо ToastManager

    var onSave: (() -> Void)? = nil

    @State private var title = ""
    @State private var amount = ""
    @State private var date = Date()
    @State private var selectedCategory: CategoryEntity?

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \CategoryEntity.name, ascending: true)]
    )
    private var categories: FetchedResults<CategoryEntity>

    var expenseToEdit: ExpenseEntity?

    init(expenseToEdit: ExpenseEntity? = nil, onSave: (() -> Void)? = nil) {
        self.expenseToEdit = expenseToEdit
        self.onSave = onSave
    }

    var body: some View {
        NavigationStack {
            Form {
                TextField("Назва", text: $title)
                Picker("Категорія", selection: $selectedCategory) {
                    ForEach(categories) { category in
                        Text(category.name ?? "")
                            .tag(category as CategoryEntity?)
                    }
                }
                TextField("Сума", text: $amount)
                    .keyboardType(.decimalPad)
                DatePicker("Дата", selection: $date, displayedComponents: .date)
            }
            .navigationTitle(expenseToEdit == nil ? "Нова витрата" : "Редагувати витрату")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Зберегти") { save() }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Скасувати") { dismiss() }
                }
            }
            .onAppear {
                if let expense = expenseToEdit {
                    title = expense.wrappedTitle
                    amount = String(expense.amount)
                    date = expense.date ?? Date()
                    selectedCategory = expense.categoryRel
                }
            }
        }
    }

    private func save() {
        guard
            !title.isEmpty,
            let selectedCategory,
            let amountValue = Double(amount)
        else {
            toastManager.show("Заповніть усі поля ❌")
            return
        }

        let expense = expenseToEdit ?? ExpenseEntity(context: context)
        if expenseToEdit == nil {
            expense.id = UUID()
        }
        expense.title = title
        expense.amount = amountValue
        expense.date = date
        expense.categoryRel = selectedCategory

        do {
            try context.save()
            
            // 🔹 Показати toast про успіх
            toastManager.show(expenseToEdit == nil ? "Витрату додано ✅" : "Витрату оновлено ✅")
            
            // 🔹 Оновити список витрат у батьківському вью
            onSave?()
            
            // 🔹 Закрити модальне вікно
            dismiss()
        } catch {
            print("❌ Save error:", error)
            toastManager.show("Помилка при збереженні ❌")
        }
    }
}
