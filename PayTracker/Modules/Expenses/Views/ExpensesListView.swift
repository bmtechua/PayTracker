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
                        expenseToEdit = nil
                        showAddExpense = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            
            .sheet(isPresented: $showAddExpense) {
                AddExpenseView(
                    expenseToEdit: expenseToEdit
                ) { _ in
                    vm.fetchExpenses()
                }
            }
            /*
            .sheet(isPresented: $showAddExpense) {
                AddExpenseView { _ in
                    vm.fetchExpenses()
                }
            }*/
            
            
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
    
