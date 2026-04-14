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
    var onSave: ((Bool) -> Void)? = nil

    // MARK: - Form state
    @State private var title = ""
    @State private var amount = ""
    @State private var date = Date()

    // ❗ НЕ optional більше (FIX Picker crash)
    @State private var selectedCategoryID: NSManagedObjectID?

    // MARK: - Categories
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \CategoryEntity.name, ascending: true)]
    )
    private var categories: FetchedResults<CategoryEntity>

    // MARK: - Init
    init(expenseToEdit: ExpenseEntity? = nil, onSave: ((Bool) -> Void)? = nil) {
        self.expenseToEdit = expenseToEdit
        self.onSave = onSave
    }

    var body: some View {
        NavigationStack {
            Form {

                TextField("Назва", text: $title)

                // 🔥 SAFE PICKER (NO NIL CRASH)
                if !categories.isEmpty {

                    Picker("Категорія", selection: Binding(
                        get: {
                            selectedCategoryID ?? categories.first!.objectID
                        },
                        set: {
                            selectedCategoryID = $0
                        }
                    )) {
                        ForEach(categories, id: \.objectID) { category in
                            Text(category.name ?? "Без назви")
                                .tag(category.objectID)
                        }
                    }
                }

                TextField("Сума", text: $amount)
                    .keyboardType(.decimalPad)

                DatePicker("Дата", selection: $date, displayedComponents: .date)
            }
            .navigationTitle(expenseToEdit == nil ? "Нова витрата" : "Редагувати витрату")
            .toolbar {

                ToolbarItem(placement: .confirmationAction) {
                    Button("Зберегти") {
                        save()
                    }
                }

                ToolbarItem(placement: .cancellationAction) {
                    Button("Скасувати") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                loadData()
            }
        }
    }

    // MARK: - Load data
    private func loadData() {

        if let expense = expenseToEdit {

            title = expense.wrappedTitle
            amount = String(expense.amount)
            date = expense.date ?? Date()

            selectedCategoryID = expense.categoryRel?.objectID

        } else {

            // 🔥 DEFAULT CATEGORY (FIX NIL ISSUE)
            DispatchQueue.main.async {
                selectedCategoryID = categories.first?.objectID
            }
        }
    }

    // MARK: - Save
    private func save() {
        guard
            !title.isEmpty,
            let selectedCategoryID,
            let category = try? context.existingObject(with: selectedCategoryID) as? CategoryEntity,
            let amountValue = Double(amount)
        else { return }

        let expense = expenseToEdit ?? ExpenseEntity(context: context)

        if expenseToEdit == nil {
            expense.id = UUID()
        }

        expense.title = title
        expense.amount = amountValue
        expense.date = date
        expense.categoryRel = category

        do {
            try context.save()
            onSave?(expenseToEdit == nil)

        } catch {
            print("❌ Save error:", error)
            onSave?(false)
        }
    }
}
#Preview {
    let persistence = PersistenceController.shared
    let context = persistence.context

    AddExpenseView()
        .environment(\.managedObjectContext, context)
}
