//
//  HomeView.swift
//  PayTracker
//
//  Created by user on 01.01.2026.
//

import SwiftUI
import CoreData
import Charts

struct CategoryExpense: Identifiable {
    let id = UUID()
    let name: String
    let total: Double
}

struct HomeView: View {

    @Environment(\.managedObjectContext) private var context

    @State private var selectedMonth = Date().startOfMonthOnly
    @State private var expenses: [ExpenseEntity] = []

    @State private var showAddExpense = false
    @State private var expenseToEdit: ExpenseEntity?

    // MARK: - Computed

    private var totalAmount: Double {
        expenses.reduce(0) { $0 + $1.amount }
    }

    private var categoryExpenses: [CategoryExpense] {
        Dictionary(grouping: expenses, by: { $0.wrappedCategory })
            .map {
                CategoryExpense(
                    name: $0.key,
                    total: $0.value.reduce(0) { $0 + $1.amount }
                )
            }
            .sorted { $0.total > $1.total }
    }

    // MARK: - UI

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {

                // 🔹 Загальна сума
                Text("₴ \(totalAmount, specifier: "%.2f")")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                // 🔹 Список витрат
                List {
                    ForEach(expenses) { expense in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(expense.wrappedTitle)
                                Text(expense.wrappedCategory)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Text("- ₴\(expense.amount, specifier: "%.2f")")
                                .foregroundColor(.red)
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            expenseToEdit = expense
                            showAddExpense = true
                        }
                    }
                    .onDelete(perform: deleteExpense)
                }
                .listStyle(.plain)
            }

            // 🔝 Title
            .navigationTitle(selectedMonth.monthYearString)

            // 🔝 TOOLBAR
            .toolbar {

                // ◀️ Попередній місяць
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        changeMonth(-1)
                    } label: {
                        Image(systemName: "chevron.left")
                    }
                }

                // ▶️ Наступний місяць
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        changeMonth(1)
                    } label: {
                        Image(systemName: "chevron.right")
                    }
                }

                // ➕ Додати витрату
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        expenseToEdit = nil
                        showAddExpense = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }

            // 🔹 Add / Edit sheet
            .sheet(isPresented: $showAddExpense) {
                AddExpenseView(expenseToEdit: expenseToEdit) {
                    fetchExpenses()
                }
                .environment(\.managedObjectContext, context)
            }

            .onAppear {
                fetchExpenses()
            }
        }
    }

    // MARK: - Helpers

    private func changeMonth(_ value: Int) {
        selectedMonth = Calendar.current.date(
            byAdding: .month,
            value: value,
            to: selectedMonth
        )!.startOfMonthOnly
        fetchExpenses()
    }

    private func fetchExpenses() {
        let request: NSFetchRequest<ExpenseEntity> = ExpenseEntity.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \ExpenseEntity.date, ascending: false)
        ]
        request.predicate = NSPredicate(
            format: "date >= %@ AND date <= %@",
            selectedMonth.startOfMonth as NSDate,
            selectedMonth.endOfMonth as NSDate
        )

        expenses = (try? context.fetch(request)) ?? []
    }

    private func deleteExpense(at offsets: IndexSet) {
        offsets.map { expenses[$0] }.forEach(context.delete)
        try? context.save()
        fetchExpenses()
    }
}
