//
//  ChartsView.swift
//  PayTracker
//
//  Created by bmtech on 04.01.2026.
//

import SwiftUI
import CoreData
import Charts

struct ChartsView: View {

    @Environment(\.managedObjectContext) private var context

    // Filters
    @State private var selectedMonth = Date().startOfMonthOnly
    @State private var selectedCategory = "Всі"

    // MARK: - FetchRequest для live Core Data updates
    @FetchRequest(
        sortDescriptors: [],
        predicate: nil,
        animation: .default
    )
    private var allExpenses: FetchedResults<ExpenseEntity>

    // MARK: - Local structs for charts
    struct ChartDayExpense: Identifiable {
        let id = UUID()
        let date: Date
        let total: Double
    }

    struct ChartCategoryExpense: Identifiable {
        let id = UUID()
        let name: String
        let total: Double
    }

    // MARK: - Computed properties

    private var filteredByMonth: [ExpenseEntity] {
        allExpenses.filter { expense in
            guard let date = expense.date else { return false }
            return date >= selectedMonth.startOfMonth && date <= selectedMonth.endOfMonth
        }
    }

    private var categories: [String] {
        let unique = Set(filteredByMonth.map { $0.wrappedCategory })
        return ["Всі"] + unique.sorted()
    }

    private var filteredExpenses: [ExpenseEntity] {
        guard selectedCategory != "Всі" else { return filteredByMonth }
        return filteredByMonth.filter { $0.wrappedCategory == selectedCategory }
    }

    private var categoryTotals: [ChartCategoryExpense] {
        Dictionary(grouping: filteredExpenses, by: { $0.wrappedCategory })
            .map {
                ChartCategoryExpense(
                    name: $0.key,
                    total: $0.value.reduce(0) { $0 + $1.amount }
                )
            }
            .sorted { $0.total > $1.total }
    }

    private var dailyTotals: [ChartDayExpense] {
        Dictionary(grouping: filteredExpenses) {
            Calendar.current.startOfDay(for: $0.date ?? Date())
        }
        .map {
            ChartDayExpense(
                date: $0.key,
                total: $0.value.reduce(0) { $0 + $1.amount }
            )
        }
        .sorted { $0.date < $1.date }
    }

    // MARK: - UI

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    filterSection

                    if #available(iOS 16.0, *) {
                        pieChart
                        barChart
                    } else {
                        fallbackView
                    }
                }
                .padding()
            }
            .navigationTitle("Аналітика")
        }
    }

    // MARK: - Filter Section

    private var filterSection: some View {
        VStack(spacing: 12) {
            HStack {
                Button { changeMonth(-1) } label: { Image(systemName: "chevron.left") }
                Spacer()
                Text(selectedMonth.monthYearString).font(.headline)
                Spacer()
                Button { changeMonth(1) } label: { Image(systemName: "chevron.right") }
            }

            Picker("Категорія", selection: $selectedCategory) {
                ForEach(categories, id: \.self) { category in
                    Text(category).tag(category)
                }
            }
            .pickerStyle(.menu)
        }
    }

    // MARK: - Charts (iOS 16+)

    @available(iOS 16.0, *)
    private var pieChart: some View {
        VStack(alignment: .leading) {
            Text("По категоріях").font(.headline)

            Chart(categoryTotals) { item in
                SectorMark(
                    angle: .value("Сума", item.total),
                    innerRadius: .ratio(0.6)
                )
                .foregroundStyle(by: .value("Категорія", item.name))
            }
            .frame(height: 260)
        }
    }

    @available(iOS 16.0, *)
    private var barChart: some View {
        VStack(alignment: .leading) {
            Text("По днях").font(.headline)

            Chart(dailyTotals) { item in
                BarMark(
                    x: .value("Дата", item.date, unit: .day),
                    y: .value("Сума", item.total)
                )
            }
            .frame(height: 220)
        }
    }

    // MARK: - Fallback (iOS 15)

    private var fallbackView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Розподіл витрат").font(.headline)

            ForEach(categoryTotals) { item in
                VStack(alignment: .leading) {
                    HStack {
                        Text(item.name)
                        Spacer()
                        Text("₴ \(item.total, specifier: "%.0f")")
                    }
                    ProgressView(
                        value: item.total,
                        total: categoryTotals.reduce(0) { $0 + $1.total }
                    )
                }
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
    }
}


#Preview {
    let persistence = PersistenceController.shared
    let context = persistence.context

    ChartsView()
        .environment(\.managedObjectContext, context)
}
