//
//  ToastManager.swift
//  PayTracker
//
//  Created by bmtech on 05.01.2026.
//
import SwiftUI
import Combine

final class ToastManager: ObservableObject {
    struct ToastData: Identifiable {
        let id = UUID()
        let message: String
    }

    @Published var currentToast: ToastData?

    // Показати toast
    func show(_ message: String, duration: TimeInterval = 2) {
        withAnimation {
            currentToast = ToastData(message: message)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            withAnimation {
                self.currentToast = nil
            }
        }
    }

    // Закрити toast вручну
    func dismiss() {
        withAnimation {
            currentToast = nil
        }
    }
}

