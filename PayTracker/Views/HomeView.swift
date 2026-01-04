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

    @State private var selectedMonth = Date()
    @State private var expenses: [ExpenseEntity] = []

    @State private var showAddExpense = false
    @State private var expenseToEdit: ExpenseEntity?

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

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {

                // 🔹 Загальна сума
                Text("₴ \(totalAmount, specifier: "%.2f")")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                // 🔹 Графік
                if !categoryExpenses.isEmpty {
                    if #available(iOS 16.0, *) {
                        Chart(categoryExpenses) { item in
                            SectorMark(
                                angle: .value("Сума", item.total),
                                innerRadius: .ratio(0.55)
                            )
                            .foregroundStyle(by: .value("Категорія", item.name))
                        }
                        .frame(height: 240)
                        .padding(.horizontal)
                    } else {
                        VStack {
                            ForEach(categoryExpenses) { item in
                                ProgressView(
                                    item.name,
                                    value: item.total,
                                    total: totalAmount
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                }

                // 🔹 Список
                List {
                    ForEach(expenses) { expense in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(expense.wrappedTitle)
                                Text(expense.wrappedCategory)
                                    .font(.caption)
                                    .foregroundColor(.gray)
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
            }
            .navigationTitle(selectedMonth.monthYearString)

            // 🔹 TOOLBAR
            .toolbar {

                // ⬅️ Місяць назад
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        selectedMonth = Calendar.current.date(
                            byAdding: .month,
                            value: -1,
                            to: selectedMonth
                        )!
                        fetchExpenses()
                    } label: {
                        Image(systemName: "chevron.left")
                    }
                }

                // ➡️ Місяць вперед
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        selectedMonth = Calendar.current.date(
                            byAdding: .month,
                            value: 1,
                            to: selectedMonth
                        )!
                        fetchExpenses()
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
                AddExpenseView(expenseToEdit: expenseToEdit)
                    .environment(\.managedObjectContext, context)
            }

            .onAppear {
                fetchExpenses()
            }
        }
    }

    // MARK: - CoreData

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

#Preview {
    let persistence = PersistenceController.shared
    HomeView()
        .environment(\.managedObjectContext, persistence.context)
}
