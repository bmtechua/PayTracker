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
        sortDescriptors: [
            NSSortDescriptor(keyPath: \ActivityLogEntity.date, ascending: false)
        ],
        animation: .default
    )
    private var logs: FetchedResults<ActivityLogEntity>

    var body: some View {
        NavigationStack {
            List {
                ForEach(logs) { log in
                    VStack(alignment: .leading, spacing: 4) {

                        Text(log.title ?? "Без назви")
                            .font(.headline)

                        Text(log.message ?? "")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        Text(log.date ?? Date(), style: .time)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }
            .navigationTitle("Активність")
        }
    }
}
