//
//  ExpensesListView.swift
//  PayTracker
//
//  Created by bmtech on 05.01.2026.
//
import SwiftUI
import CoreData

struct ExpensesListView: View {
    
    @StateObject private var vm = ExpensesViewModel()
    
    @EnvironmentObject private var toast: ToastManager
    @AppStorage("currency") private var currency: AppCurrency = .uah
    
    @State private var expenseToEdit: ExpenseEntity?
    @State private var showAddExpense = false
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(vm.groupedExpenses) { group in
                    Section {
                        ForEach(group.expenses) { expense in
                            expenseRow(expense)
                        }
                        .onDelete { offsets in
                            vm.deleteExpense(group: group, offsets: offsets)
                        }
                    } header: {
                        sectionHeader(group)
                    }
                }
            }
            .listStyle(.plain)
            .onAppear {
                vm.fetchExpenses()
            }
            // 🔝 Title
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack {
                        Text("Всі витрати")
                            .font(.headline)
                        Text(vm.selectedMonth.monthYearString)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showAddExpense = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddExpense) {
                AddExpenseView { _ in
                    vm.fetchExpenses()
                }
            }
            
            
        }}
    
    
    // MARK: - Rows
    
    private func expenseRow(_ expense: ExpenseEntity) -> some View {
        HStack {
            VStack(alignment: .leading) {
                Text(expense.wrappedTitle)
                Text(expense.wrappedCategory)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Text(
                CurrencyFormatter.string(
                    amount: expense.amount,
                    currencyCode: currency.currencyCode
                )
            )
            .foregroundColor(.red)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            expenseToEdit = expense
            showAddExpense = true
        }
    }
    
    private func sectionHeader(_ group: DayGroup) -> some View {
        HStack {
            Text(group.date.formatted(date: .abbreviated, time: .omitted))
                .font(.headline)
            Spacer()
            Text(
                CurrencyFormatter.string(
                    amount: group.total,
                    currencyCode: currency.currencyCode
                )
            )
            .font(.subheadline)
            .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}
    

/*

import SwiftUI
import CoreData

// MARK: - Expenses List View

struct ExpensesListView: View {

    @Environment(\.managedObjectContext) private var context
    @EnvironmentObject private var toast: ToastManager
    @AppStorage("currency") private var currency: AppCurrency = .uah

    // Filters
    @State private var selectedMonth = Date().startOfMonthOnly
    @State private var searchText = ""

    // Data
    @State private var expenses: [ExpenseEntity] = []

    // UI
    @State private var expenseToEdit: ExpenseEntity?
    @State private var showAddExpense = false

    // MARK: - Computed

    private var periodTitle: String {
        selectedMonth.monthYearString
    }

    private var dayGroups: [DayGroup] {
        let filtered = expenses.filter {
            searchText.isEmpty ||
            $0.wrappedTitle.localizedCaseInsensitiveContains(searchText) ||
            $0.wrappedCategory.localizedCaseInsensitiveContains(searchText)
        }

        let grouped = Dictionary(grouping: filtered) {
            Calendar.current.startOfDay(for: $0.date ?? Date())
        }

        return grouped
            .map { DayGroup(date: $0.key, expenses: $0.value) }
            .sorted { $0.date > $1.date }
    }

    // MARK: - UI

    var body: some View {
        NavigationStack {
            List {
                ForEach(dayGroups) { group in
                    Section {
                        ForEach(group.expenses) { expense in
                            expenseRow(expense)
                        }
                        .onDelete { offsets in
                            deleteExpense(group: group, offsets: offsets)
                        }
                    } header: {
                        sectionHeader(group)
                    }
                }
            }
            .listStyle(.plain)

            // 🔝 Custom title
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack {
                        Text("Всі витрати")
                            .font(.headline)
                        Text(periodTitle)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                // ◀️ ▶️ Month navigation
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Button { changeMonth(-1) } label: {
                        Image(systemName: "chevron.left")
                    }
                    Button { changeMonth(1) } label: {
                        Image(systemName: "chevron.right")
                    }
                }

                // ➕ Add
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        expenseToEdit = nil
                        showAddExpense = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }

            // 🔍 Search
            .searchable(text: $searchText, prompt: "Пошук витрат")

            // ➕ Add / ✏️ Edit
            .sheet(isPresented: $showAddExpense) {
                AddExpenseView(expenseToEdit: expenseToEdit) { _ in
                    fetchExpenses()
                }
                .environment(\.managedObjectContext, context)
                .environmentObject(toast)
            }

            .onAppear {
                fetchExpenses()
            }
        }
    }

    // MARK: - Rows

    private func expenseRow(_ expense: ExpenseEntity) -> some View {
        HStack {
            VStack(alignment: .leading) {
                Text(expense.wrappedTitle)
                Text(expense.wrappedCategory)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Text(
                CurrencyFormatter.string(
                    amount: expense.amount,
                    currencyCode: currency.currencyCode
                )
            )
            .foregroundColor(.red)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            expenseToEdit = expense
            showAddExpense = true
        }
    }

    private func sectionHeader(_ group: DayGroup) -> some View {
        HStack {
            Text(group.date.formatted(date: .abbreviated, time: .omitted))
                .font(.headline)
            Spacer()
            Text(
                CurrencyFormatter.string(
                    amount: group.total,
                    currencyCode: currency.currencyCode
                )
            )
            .font(.subheadline)
            .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }

    // MARK: - Data

    private func changeMonth(_ value: Int) {
        selectedMonth = Calendar.current
            .date(byAdding: .month, value: value, to: selectedMonth)!
            .startOfMonthOnly
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

    private func deleteExpense(group: DayGroup, offsets: IndexSet) {
        offsets.map { group.expenses[$0] }.forEach(context.delete)
        try? context.save()
        fetchExpenses()
    }
 
}

*/
