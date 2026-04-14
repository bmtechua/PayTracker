//
//  ExpensesViewModel.swift
//  PayTracker
//
//  Created by bmtech on 13.04.2026.
//

import SwiftUI
import CoreData
import Combine
import os

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

        do {
            expenses = try context.fetch(request)
            
            AppLogger.expense.info("Fetched \(self.expenses.count) expenses")
            Log.expense("Fetched \(expenses.count) expenses")
            
        } catch {
            AppLogger.coredata.error("Fetch error: \(error.localizedDescription)")
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

        let expensesToDelete = offsets.map { group.expenses[$0] }

        expensesToDelete.forEach {
            AppLogger.expense.info("Deleting expense: \($0.wrappedTitle), amount: \($0.amount)")
            Log.expense("Deleting: \($0.wrappedTitle), \($0.amount)")
            context.delete($0)
        }

        do {
            try context.save()
            AppLogger.coredata.info("Delete saved successfully")
        } catch {
            AppLogger.coredata.error("Delete error: \(error.localizedDescription)")
        }

        fetchExpenses()
    }

    /*func deleteExpense(group: DayGroup, offsets: IndexSet) {

        let expensesToDelete = offsets.map { group.expenses[$0] }

        expensesToDelete.forEach { context.delete($0) }

        do {
            try context.save()
        } catch {
            print("Delete error:", error)
        }
       
   
        fetchExpenses()
    }*/

}


