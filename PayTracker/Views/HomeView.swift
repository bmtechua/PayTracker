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

// MARK: - HomeView

struct HomeView: View {

    @Environment(\.managedObjectContext) private var context
    @AppStorage("currency") private var currency: AppCurrency = .uah
    @EnvironmentObject var toast: ToastManager


    @State private var selectedMonth = Date().startOfMonthOnly
    @State private var categories: [CategorySummary] = []
    @State private var showAddExpense = false

    var totalAmount: Double {
        categories.reduce(0) { $0 + $1.total }
    }

    var body: some View {
        ZStack {
            NavigationStack {
                VStack(spacing: 16) {
                    // 🔹 Загальна сума
                    Text(
                        CurrencyFormatter.string(amount: totalAmount,
                                                 currencyCode: currency.currencyCode)
                    )
                    .font(.largeTitle)
                    .fontWeight(.bold)

                    // 🔹 Категорії
                    List {
                        ForEach(categories) { category in
                            NavigationLink {
                                CategoryDetailView(categoryName: category.name,
                                                   month: selectedMonth)
                            } label: {
                                HStack {
                                    Text(category.name)
                                    Spacer()
                                    Text(
                                        CurrencyFormatter.string(amount: category.total,
                                                                 currencyCode: currency.currencyCode)
                                    )
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
                        Button { changeMonth(-1) } label: { Image(systemName: "chevron.left") }
                        Button { changeMonth(1) } label: { Image(systemName: "chevron.right") }
                    }

                    // ➕ Додати витрату
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button { showAddExpense = true } label: { Image(systemName: "plus") }
                    }
                }
                .sheet(isPresented: $showAddExpense) {
                    AddExpenseView {
                        fetchCategories()
                        toast.show("Витрату додано ✅")
                    }
                    .environment(\.managedObjectContext, context)
                    .environmentObject(toast)
                }
                .onAppear { fetchCategories() }
            }

            // 🔹 Toast Container
            if let currentToast = toast.currentToast {
                            VStack {
                                ToastView(message: currentToast.message) {
                                    toast.dismiss() // виклик методy dismiss()
                                }
                                Spacer()
                            }
                            .transition(.move(edge: .top).combined(with: .opacity))
                            .animation(.spring(), value: currentToast.id)
                            .zIndex(1)
                        }
        }
    }

    // MARK: - Helpers

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

        let grouped = Dictionary(grouping: expenses) { $0.wrappedCategory }

        categories = grouped.map { CategorySummary(name: $0.key,
                                                   total: $0.value.reduce(0) { $0 + $1.amount }) }
            .sorted { $0.total > $1.total }
    }
}
