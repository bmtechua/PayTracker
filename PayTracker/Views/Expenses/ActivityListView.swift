//
//  ActivityListView.swift
//  PayTracker
//
//  Created by bmtech on 14.04.2026.
//

import SwiftUI
import CoreData

struct ActivityListView: View {

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \ActivityLogEntity.date, ascending: false)]
    )
    private var logs: FetchedResults<ActivityLogEntity>

    var body: some View {
        NavigationStack {
            List {

                ForEach(groupedLogs, id: \.title) { group in

                    Section(group.title) {

                        ForEach(group.logs) { log in
                            row(log)
                        }
                    }
                }
            }
            .navigationTitle("Активність")
        }
    }

    // MARK: - Grouping

    private var groupedLogs: [(title: String, logs: [ActivityLogEntity])] {
        let calendar = Calendar.current

        let grouped = Dictionary(grouping: logs) { log in

            guard let date = log.date else { return "Інше" }

            if calendar.isDateInToday(date) {
                return "Сьогодні"
            } else if calendar.isDateInYesterday(date) {
                return "Вчора"
            } else {
                return "Раніше"
            }
        }

        return grouped.map { ($0.key, $0.value) }
            .sorted { lhs, rhs in
                order(lhs.title) < order(rhs.title)
            }
    }

    private func order(_ title: String) -> Int {
        switch title {
        case "Сьогодні": return 0
        case "Вчора": return 1
        default: return 2
        }
    }

    // MARK: - Row

    private func row(_ log: ActivityLogEntity) -> some View {

        HStack(spacing: 12) {

            Text(icon(log.type))
                .font(.title3)

            VStack(alignment: .leading) {
                Text(log.title ?? "")
                    .font(.headline)

                Text(log.message ?? "")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Text(log.date ?? Date(), style: .time)
                .font(.caption2)
                .foregroundColor(.gray)
        }
        .padding(.vertical, 4)
    }

    private func icon(_ type: String?) -> String {
        switch type {
        case ActivityType.addExpense.rawValue,
             ActivityType.addCategory.rawValue:
            return "➕"

        case ActivityType.editExpense.rawValue,
             ActivityType.editCategory.rawValue:
            return "✏️"

        case ActivityType.deleteExpense.rawValue,
             ActivityType.deleteCategory.rawValue:
            return "🗑"

        default:
            return "ℹ️"
        }
    }
}
