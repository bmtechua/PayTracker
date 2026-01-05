//
//  ExpensesListView.swift
//  PayTracker
//
//  Created by bmtech on 05.01.2026.
//

import SwiftUI
import CoreData

// MARK: - Day Group Model

struct DayGroup: Identifiable {
    let id = UUID()
    let date: Date
    let expenses: [ExpenseEntity]

    var total: Double {
        expenses.reduce(0) { $0 + $1.amount }
    }
}

// MARK: - Expenses List View

struct ExpensesListView: View {

    @Environment(\.managedObjectContext) private var context
    
    @AppStorage("currency") private var currency: AppCurrency = .uah

    // Filters
    @State private var selectedMonth = Date().startOfMonthOnly
    @State private var searchText = ""

    // Data
    @State private var expenses: [ExpenseEntity] = []

    // UI
    @State private var showAddExpense = false
    @State private var expenseToEdit: ExpenseEntity?

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

            // 🔝 Custom title with period
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

                // 📤 Export CSV
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        exportCSV()
                    } label: {
                        Image(systemName: "square.and.arrow.up")
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

            // ➕ Add / Edit sheet
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

    // MARK: - Rows & Headers

    private func expenseRow(_ expense: ExpenseEntity) -> some View {
        HStack {
            VStack(alignment: .leading) {
                Text(expense.wrappedTitle)
                Text(expense.wrappedCategory)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Text("\(currency.symbol) \(expense.amount, specifier: "%.2f")")
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
            Text("\(currency.symbol)  \(group.total, specifier: "%.0f")")
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

    // MARK: - Export CSV

    private func exportCSV() {
        let header = "Date,Title,Category,Amount\n"

        let rows = expenses.map {
            "\(formatDate($0.date)),\($0.wrappedTitle),\($0.wrappedCategory),\($0.amount)"
        }
        .joined(separator: "\n")

        let csv = header + rows

        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("expenses_\(periodTitle).csv")

        try? csv.write(to: url, atomically: true, encoding: .utf8)

        let activityVC = UIActivityViewController(
            activityItems: [url],
            applicationActivities: nil
        )

        UIApplication.shared
            .connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.keyWindow }
            .first?
            .rootViewController?
            .present(activityVC, animated: true)
    }

    private func formatDate(_ date: Date?) -> String {
        guard let date else { return "" }
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter.string(from: date)
    }
}
