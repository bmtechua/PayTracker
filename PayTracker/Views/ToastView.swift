//
//  ToastView.swift
//  PayTracker
//
//  Created by bmtech on 05.01.2026.
//
import SwiftUI

struct ToastView: View {
    let message: String
    var onDismiss: (() -> Void)? = nil

    @State private var offsetY: CGFloat = 0

    var body: some View {
        Text(message)
            .padding()
            .background(Color.black.opacity(0.8))
            .foregroundColor(.white)
            .cornerRadius(10)
            .shadow(radius: 5)
            .padding(.horizontal, 20)
            .offset(y: offsetY)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        if value.translation.height > 0 {
                            offsetY = value.translation.height
                        }
                    }
                    .onEnded { value in
                        if value.translation.height > 50 {
                            onDismiss?() // виклик dismiss()
                        } else {
                            withAnimation(.spring()) {
                                offsetY = 0
                            }
                        }
                    }
            )
            .animation(.spring(), value: offsetY)
    }
}
