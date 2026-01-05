//
//  ToastContainer.swift
//  PayTracker
//
//  Created by bmtech on 05.01.2026.
//

import SwiftUI

struct ToastContainer<Content: View>: View {
    @EnvironmentObject var toast: ToastManager
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        ZStack {
            content

            if let toastData = toast.currentToast {
                VStack {
                    ToastView(message: toastData.message)
                        .padding(.top, 50)
                    Spacer()
                }
                .animation(.spring(), value: toastData.id)
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
    }
}
