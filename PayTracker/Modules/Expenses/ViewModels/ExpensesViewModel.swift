//
//  ExpensesViewModel.swift
//  PayTracker
//
//  Created by bmtech on 13.04.2026.
//

import SwiftUI
import CoreData
import Combine

class ExpensesViewModel: ObservableObject {

    @Published var expenses: [ExpenseEntity] = []
    @Published var groupedExpenses: [DayGroup] = []

    @Published var selectedMonth = Date().startOfMonthOnly
    @Published var searchText = ""

    private let context = PersistenceController.shared.container.viewContext

    // MARK: - Fetch

    func fetchExpenses() {
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
        applyFilters()
    }

    // MARK: - Filters

    func applyFilters() {
        let filtered = expenses.filter {
            searchText.isEmpty ||
            $0.wrappedTitle.localizedCaseInsensitiveContains(searchText) ||
            $0.wrappedCategory.localizedCaseInsensitiveContains(searchText)
        }

        let grouped = Dictionary(grouping: filtered) {
            Calendar.current.startOfDay(for: $0.date ?? Date())
        }

        groupedExpenses = grouped
            .map { DayGroup(date: $0.key, expenses: $0.value) }
            .sorted { $0.date > $1.date }
    }

    // MARK: - Month

    func changeMonth(_ value: Int) {
        selectedMonth = Calendar.current
            .date(byAdding: .month, value: value, to: selectedMonth)!
            .startOfMonthOnly

        fetchExpenses()
    }

    // MARK: - Delete

    func deleteExpense(group: DayGroup, offsets: IndexSet) {

        let expensesToDelete = offsets.map { group.expenses[$0] }

        expensesToDelete.forEach { context.delete($0) }

        do {
            try context.save()
        } catch {
            print("Delete error:", error)
        }
        // 🔥 LOG кожної витрати
   
        fetchExpenses()
    }

}

/*
class ExpensesViewModel: ObservableObject {

    @Published var expenses: [ExpenseEntity] = []
    @Published var groupedExpenses: [DayGroup] = []

    @Published var searchText: String = ""
    @Published var selectedMonth: Date = Date()

    private let service = ExpenseService()

    func loadExpenses() {
        expenses = service.fetchExpenses()
        applyFilters()
    }

    func applyFilters() {
        var filtered = expenses

        if !searchText.isEmpty {
            filtered = filtered.filter {
                ($0.title ?? "").lowercased().contains(searchText.lowercased())
            }
        }

        filtered = filtered.filter {
            guard let date = $0.date else { return false }
            return Calendar.current.isDate(date, equalTo: selectedMonth, toGranularity: .month)
        }
        groupedExpenses = service.groupByDay(filtered)
    }

    func formatDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateStyle = .medium
        return f.string(from: date)
    }

    func formatAmount(_ amount: Double) -> String {
        String(format: "%.2f", amount)
    }

    func formatTotal(_ total: Double) -> String {
        String(format: "%.2f", total)
    }
}
*/
