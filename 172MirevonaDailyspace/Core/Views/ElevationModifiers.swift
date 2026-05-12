//
//  ElevationModifiers.swift
//  172MirevonaDailyspace
//

import SwiftUI

// MARK: - List rows (no shadow — many instances in `List`)

/// Gradient “plate” for table rows: cheap on the GPU (no blur, no shadow).
struct ListRowChromeBackground: View {
    var cornerRadius: CGFloat = 12

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [
                        Color.appSurface.opacity(0.9),
                        Color.appSurface.opacity(0.52)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                Color.appTextPrimary.opacity(0.14),
                                Color.appTextPrimary.opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            }
    }
}

// MARK: - View extensions (single shadow per card)

extension View {
    /// Primary floating panel: gradient fill + hairline + **one** soft shadow.
    func appElevatedCard(cornerRadius: CGFloat = 20, shadowRadius: CGFloat = 10, shadowY: CGFloat = 5) -> some View {
        self
            .background {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.appSurface.opacity(0.94),
                                Color.appSurface.opacity(0.56)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay {
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .strokeBorder(Color.appTextPrimary.opacity(0.11), lineWidth: 1)
                    }
                    .shadow(color: Color.black.opacity(0.2), radius: shadowRadius, x: 0, y: shadowY)
            }
    }

    /// Smaller controls (chips, tiles): lighter shadow.
    func appSoftLift(cornerRadius: CGFloat = 16, shadowRadius: CGFloat = 6, shadowY: CGFloat = 3) -> some View {
        self
            .background {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.appSurface.opacity(0.92),
                                Color.appSurface.opacity(0.54)
                            ],
                            startPoint: .top,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay {
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .strokeBorder(Color.appTextPrimary.opacity(0.09), lineWidth: 1)
                    }
                    .shadow(color: Color.black.opacity(0.16), radius: shadowRadius, x: 0, y: shadowY)
            }
    }

    /// Text fields & compact insets: gradient depth, **no** shadow (scroll lists stay smooth).
    func appInsetField(cornerRadius: CGFloat = 14) -> some View {
        self
            .background {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.appSurface.opacity(0.92),
                                Color.appSurface.opacity(0.62)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay {
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .strokeBorder(Color.appTextPrimary.opacity(0.08), lineWidth: 1)
                    }
            }
    }
}
