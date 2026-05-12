//
//  DesignButtonStyles.swift
//  172MirevonaDailyspace
//

import Combine
import SwiftUI

struct TapHapticButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        TapHapticButtonBody(configuration: configuration)
    }
}

private struct TapHapticButtonBody: View {
    let configuration: ButtonStyle.Configuration

    var body: some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.spring(response: 0.35, dampingFraction: 0.72), value: configuration.isPressed)
    }
}

struct PrimaryProminentButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        PrimaryProminentButtonBody(configuration: configuration)
    }
}

private struct PrimaryProminentButtonBody: View {
    let configuration: ButtonStyle.Configuration

    private var labelColor: Color {
        Color("AppBackground")
    }

    var body: some View {
        configuration.label
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .foregroundStyle(labelColor)
            .background {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color("AppPrimary").opacity(configuration.isPressed ? 0.78 : 1.0),
                                Color("AppPrimary").opacity(configuration.isPressed ? 0.62 : 0.82)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .strokeBorder(Color.white.opacity(0.22), lineWidth: 1)
                    }
                    .shadow(color: Color.black.opacity(0.2), radius: 6, x: 0, y: 3)
            }
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.spring(response: 0.35, dampingFraction: 0.72), value: configuration.isPressed)
    }
}
