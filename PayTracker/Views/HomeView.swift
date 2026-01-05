//
//  HomeView.swift
//  PayTracker
//
//  Created by user on 01.01.2026.
//

import SwiftUI
import CoreData

struct CategorySummary: Identifiable {
    let id = UUID()
    let name: String
    let total: Double
}

struct HomeView: View {

    @Environment(\.managedObjectContext) private var context

    @State private var selectedMonth = Date().startOfMonthOnly
    @State private var categories: [CategorySummary] = []

    @State private var showAddExpense = false

    var totalAmount: Double {
        categories.reduce(0) { $0 + $1.total }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {

                // 🔹 Загальна сума
                Text("₴ \(totalAmount, specifier: "%.2f")")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                // 🔹 Категорії
                List {
                    ForEach(categories) { category in
                        NavigationLink {
                            CategoryDetailView(
                                categoryName: category.name,
                                month: selectedMonth
                            )
                        } label: {
                            HStack {
                                Text(category.name)
                                Spacer()
                                Text("₴ \(category.total, specifier: "%.2f")")
                                    .fontWeight(.semibold)
                            }
                        }
                    }
                }
                .listStyle(.plain)
            }
            .navigationTitle(selectedMonth.monthYearString)
            .toolbar {

                // ◀️ / ▶️ Місяці
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Button { changeMonth(-1) } label: {
                        Image(systemName: "chevron.left")
                    }
                    Button { changeMonth(1) } label: {
                        Image(systemName: "chevron.right")
                    }
                }

                // ➕ Додати витрату
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showAddExpense = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddExpense) {
                AddExpenseView {
                    fetchCategories()
                }
                .environment(\.managedObjectContext, context)
            }
            .onAppear {
                fetchCategories()
            }
        }
    }

    // MARK: - Data

    private func changeMonth(_ value: Int) {
        selectedMonth = Calendar.current
            .date(byAdding: .month, value: value, to: selectedMonth)!
            .startOfMonthOnly
        fetchCategories()
    }

    private func fetchCategories() {
        let request: NSFetchRequest<ExpenseEntity> = ExpenseEntity.fetchRequest()
        request.predicate = NSPredicate(
            format: "date >= %@ AND date <= %@",
            selectedMonth.startOfMonth as NSDate,
            selectedMonth.endOfMonth as NSDate
        )

        let expenses = (try? context.fetch(request)) ?? []

        let grouped = Dictionary(grouping: expenses) {
            $0.wrappedCategory
        }

        categories = grouped.map {
            CategorySummary(
                name: $0.key,
                total: $0.value.reduce(0) { $0 + $1.amount }
            )
        }
        .sorted { $0.total > $1.total }
    }
}
