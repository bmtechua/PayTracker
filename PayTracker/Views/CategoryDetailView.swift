//
//  CategoryDetailView.swift
//  PayTracker
//
//  Created by bmtech on 05.01.2026.
//

import SwiftUI
import CoreData

struct CategoryDetailView: View {

    @Environment(\.managedObjectContext) private var context

    let categoryName: String
    let month: Date

    @State private var expenses: [ExpenseEntity] = []

    var body: some View {
        List {
            ForEach(expenses) { expense in
                HStack {
                    VStack(alignment: .leading) {
                        Text(expense.wrappedTitle)
                        Text(expense.date?.formatted(date: .abbreviated, time: .omitted) ?? "")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Text("₴ \(expense.amount, specifier: "%.2f")")
                        .foregroundColor(.red)
                }
            }
        }
        .navigationTitle(categoryName)
        .onAppear {
            fetchExpenses()
        }
    }

    private func fetchExpenses() {
        let request: NSFetchRequest<ExpenseEntity> = ExpenseEntity.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \ExpenseEntity.date, ascending: false)
        ]
        request.predicate = NSPredicate(
            format: "categoryRel.name == %@ AND date >= %@ AND date <= %@",
            categoryName,
            month.startOfMonth as NSDate,
            month.endOfMonth as NSDate
        )

        expenses = (try? context.fetch(request)) ?? []
    }
}
