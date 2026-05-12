//
//  CustomTabBar.swift
//  172MirevonaDailyspace
//

import SwiftUI

enum RootTab: Int, CaseIterable, Identifiable {
    case home = 0
    case palettes = 1
    case studio = 2
    case achievements = 3
    case settings = 4

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .home: return "Home"
        case .palettes: return "Palettes"
        case .studio: return "Studio"
        case .achievements: return "Achievements"
        case .settings: return "Settings"
        }
    }

    var symbol: String {
        switch self {
        case .home: return "house.fill"
        case .palettes: return "paintpalette.fill"
        case .studio: return "rectangle.stack.fill"
        case .achievements: return "trophy.fill"
        case .settings: return "gearshape.fill"
        }
    }
}

struct CustomTabBar: View {
    @Binding var selection: RootTab

    var body: some View {
        HStack(spacing: 0) {
            ForEach(RootTab.allCases) { tab in
                Button {
                    HapticFeedback.tap()
                    selection = tab
                } label: {
                    VStack(spacing: 6) {
                        Image(systemName: tab.symbol)
                            .font(.system(size: 20, weight: .semibold))
                        Text(tab.title)
                            .font(.caption2.weight(.semibold))
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .foregroundStyle(selection == tab ? Color.appBackground : Color.appTextSecondary)
                    .padding(.horizontal, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(
                                selection == tab
                                    ? LinearGradient(
                                        colors: [Color.appPrimary, Color.appPrimary.opacity(0.82)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                    : LinearGradient(colors: [Color.clear, Color.clear], startPoint: .top, endPoint: .bottom)
                            )
                            .shadow(
                                color: selection == tab ? Color.black.opacity(0.22) : .clear,
                                radius: selection == tab ? 6 : 0,
                                x: 0,
                                y: selection == tab ? 3 : 0
                            )
                    )
                }
                .buttonStyle(TapHapticButtonStyle())
                .frame(minHeight: 44)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color.appSurface.opacity(0.98), Color.appSurface.opacity(0.82)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .overlay {
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .strokeBorder(
                            LinearGradient(
                                colors: [Color.appTextPrimary.opacity(0.16), Color.appTextPrimary.opacity(0.05)],
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: 1
                        )
                }
                .shadow(color: Color.black.opacity(0.22), radius: 12, x: 0, y: 6)
        }
        .padding(.horizontal, 14)
    }
}
