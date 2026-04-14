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

    private let context: NSManagedObjectContext

    // MARK: - Init

    init(context: NSManagedObjectContext) {
        self.context = context
        fetchExpenses()
    }

    // MARK: - Fetch

    func fetchExpenses() {
        let request: NSFetchRequest<ExpenseEntity> = ExpenseEntity.fetchRequest()

        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \ExpenseEntity.date, ascending: false)
        ]

        // ✅ ПРАВИЛЬНИЙ ФІЛЬТР ДАТИ
        let start = selectedMonth.startOfMonth
        let end = Calendar.current.date(byAdding: .month, value: 1, to: start)!

        request.predicate = NSPredicate(
            format: "date >= %@ AND date < %@",
            start as NSDate,
            end as NSDate
        )

        do {
            expenses = try context.fetch(request)
        } catch {
            print("Fetch error:", error)
            expenses = []
        }

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
        offsets.map { group.expenses[$0] }.forEach(context.delete)

        do {
            try context.save()
        } catch {
            print("Delete error:", error)
        }
        
        ActivityLogger.log(
            .deleteExpense,
            title: "Витрата видалена",
            message: expense.wrappedTitle,
            context: context
        )
        
        fetchExpenses()
    }
}
