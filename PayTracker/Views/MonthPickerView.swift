//
//  MonthPickerView.swift
//  PayTracker
//
//  Created by user on 01.01.2026.
//

import SwiftUI

struct MonthPickerView: View {
    @Binding var selectedDate: Date

    private var months: [Date] {
        let calendar = Calendar.current
        let today = Date()
        return (0..<12).compactMap { calendar.date(byAdding: .month, value: -$0, to: today)?.startOfMonthOnly }
    }

    var body: some View {
        Picker("Місяць", selection: $selectedDate) {
            ForEach(months, id: \.self) { date in
                Text(date.monthYearString)
                    .tag(date)
            }
        }
        .pickerStyle(MenuPickerStyle())
    }
}

extension Date {
    var startOfMonthOnly: Date {
        Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: self)) ?? self
    }

    var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL yyyy"
        formatter.locale = Locale(identifier: "uk_UA")
        return formatter.string(from: self)
    }

    var startOfMonth: Date { startOfMonthOnly }
    var endOfMonth: Date {
        let calendar = Calendar.current
        var components = DateComponents()
        components.month = 1
        components.day = -1
        return calendar.date(byAdding: components, to: startOfMonthOnly) ?? self
    }
}
