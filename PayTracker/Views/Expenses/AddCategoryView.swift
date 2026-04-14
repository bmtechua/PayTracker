//
//  AddCategoryView.swift
//  PayTracker
//
//  Created by user on 01.01.2026.
//
import SwiftUI
import CoreData

struct AddCategoryView: View {
    @Environment(\.managedObjectContext) private var context
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var userManager: UserManager

    var categoryToEdit: CategoryEntity?
    var onSave: (() -> Void)? = nil

    @State private var name: String = ""
    @State private var icon: String = "tag"
    @State private var colorHex: String = "#999999"

    var body: some View {
        Group {
            // 🔒 Повна блокада доступу без Premium
            if userManager.isPremium {
                content
            } else {
                Color.clear
                    .onAppear {
                        dismiss()
                    }
            }
        }
    }

    // MARK: - Основний контент
    private var content: some View {
        NavigationStack {
            Form {
                TextField("Назва категорії", text: $name)
                TextField("Іконка (SF Symbol)", text: $icon)

                ColorPicker(
                    "Колір",
                    selection: Binding(
                        get: { Color(hex: colorHex) },
                        set: { colorHex = $0.toHex() }
                    )
                )
            }
            .navigationTitle(
                categoryToEdit == nil
                ? "Нова категорія"
                : "Редагувати категорію"
            )
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Зберегти") {
                        saveCategory()
                    }
                    // 🔒 базові категорії не редагуються
                    .disabled(categoryToEdit?.isPremium == false)
                }

                ToolbarItem(placement: .cancellationAction) {
                    Button("Скасувати") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                if let c = categoryToEdit {
                    name = c.name ?? ""
                    icon = c.icon ?? "tag"
                    colorHex = c.colorHex ?? "#999999"
                }
            }
        }
    }

    // MARK: - Збереження
    private func saveCategory() {
        // 🔒 Захист від не-Premium
        guard userManager.isPremium else {
            dismiss()
            return
        }

        // 🔒 Заборона редагування базових
        if let c = categoryToEdit, c.isPremium == false {
            dismiss()
            return
        }

        let category = categoryToEdit ?? CategoryEntity(context: context)
        category.name = name
        category.icon = icon
        category.colorHex = colorHex
        category.isPremium = true   // 🔐 ВСІ користувацькі категорії = premium

        do {
            try context.save()
            onSave?()
            dismiss()
        } catch {
            print("Помилка збереження категорії:", error)
        }
    }
}

// MARK: - Color + HEX
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(
            in: CharacterSet.alphanumerics.inverted
        )
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)

        let r, g, b: UInt64
        switch hex.count {
        case 6:
            (r, g, b) = (
                (int >> 16) & 0xFF,
                (int >> 8) & 0xFF,
                int & 0xFF
            )
        default:
            (r, g, b) = (153, 153, 153)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: 1
        )
    }
}
