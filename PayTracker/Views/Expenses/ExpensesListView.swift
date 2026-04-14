//
//  ExpensesListView.swift
//  PayTracker
//
//  Created by bmtech on 05.01.2026.
//
import SwiftUI
import CoreData

struct ExpensesListView: View {

    @Environment(\.managedObjectContext) private var context
    @EnvironmentObject private var toast: ToastManager
    @AppStorage("currency") private var currency: AppCurrency = .uah

    @StateObject private var vm: ExpensesViewModel

    // 🔥 ОДИН SOURCE OF TRUTH (ВАЖЛИВО)
    @State private var selectedExpense: ExpenseEntity?

    // MARK: - Init
    init(context: NSManagedObjectContext) {
        _vm = StateObject(wrappedValue: ExpensesViewModel(context: context))
    }

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

            // MARK: - Toolbar
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

                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Button {
                        vm.changeMonth(-1)
                    } label: {
                        Image(systemName: "chevron.left")
                    }

                    Button {
                        vm.changeMonth(1)
                    } label: {
                        Image(systemName: "chevron.right")
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        selectedExpense = ExpenseEntity(context: context)
                        // 👆 nil = create new, але краще окремо можна зробити
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }

            // MARK: - Search
            .onChange(of: vm.searchText) { _ in
                vm.applyFilters()
            }

            // MARK: - SHEET (ПРАВИЛЬНО)
            .sheet(item: $selectedExpense) { expense in
                AddExpenseView(expenseToEdit: expense) { _ in
                    vm.fetchExpenses()
                    selectedExpense = nil
                }
                .environment(\.managedObjectContext, context)
                .environmentObject(toast)
            }
        }
    }

    // MARK: - Row

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
            selectedExpense = expense
        }
    }

    // MARK: - Header

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

