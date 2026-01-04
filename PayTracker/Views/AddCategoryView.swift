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

    var categoryToEdit: CategoryEntity?
    var onSave: (() -> Void)? = nil

    @State private var name: String = ""
    @State private var icon: String = "tag"
    @State private var colorHex: String = "#999999"

    // Можливі іконки
    private let icons = ["tag", "cart", "house", "car", "fork.knife", "heart", "star", "gift", "book"]

    // Можливі кольори
    private let colors: [Color] = [.red, .orange, .yellow, .green, .blue, .purple, .gray]

    var body: some View {
        NavigationStack {
            Form {
                Section("Назва") {
                    TextField("Введіть назву", text: $name)
                }

                Section("Іконка") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(icons, id: \.self) { iconName in
                                Image(systemName: iconName)
                                    .font(.title)
                                    .padding()
                                    .background(icon == iconName ? Color.gray.opacity(0.3) : Color.clear)
                                    .cornerRadius(8)
                                    .onTapGesture {
                                        icon = iconName
                                    }
                            }
                        }
                    }
                }

                Section("Колір") {
                    HStack {
                        ForEach(colors, id: \.self) { color in
                            Circle()
                                .fill(color)
                                .frame(width: 30, height: 30)
                                .overlay(
                                    Circle()
                                        .stroke(Color.black, lineWidth: colorHex == color.toHex() ? 2 : 0)
                                )
                                .onTapGesture {
                                    colorHex = color.toHex()
                                }
                        }
                    }
                }
            }
            .navigationTitle(categoryToEdit == nil ? "Нова категорія" : "Редагувати")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Зберегти") {
                        saveCategory()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }

                ToolbarItem(placement: .cancellationAction) {
                    Button("Скасувати") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                if let cat = categoryToEdit {
                    name = cat.name ?? ""
                    icon = cat.icon ?? "tag"
                    colorHex = cat.colorHex ?? "#999999"
                }
            }
        }
    }

    private func saveCategory() {
        let category = categoryToEdit ?? CategoryEntity(context: context)

        if categoryToEdit == nil {
            category.id = UUID()
        }

        category.name = name.trimmingCharacters(in: .whitespaces)
        category.icon = icon
        category.colorHex = colorHex

        do {
            try context.save()
            dismiss()
            onSave?()
        } catch {
            print("Помилка збереження категорії:", error)
        }
    }
}

// MARK: - Допоміжне перетворення Color -> HEX
extension Color {
    func toHex() -> String {
        let uiColor = UIColor(self)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        let ri = Int(r*255), gi = Int(g*255), bi = Int(b*255)
        return String(format: "#%02X%02X%02X", ri, gi, bi)
    }
}

#Preview {
    let persistence = PersistenceController.shared
    let context = persistence.context

    AddCategoryView()
        .environment(\.managedObjectContext, context)
}
