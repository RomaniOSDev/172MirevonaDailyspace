//
//  MainTabContainerView.swift
//  172MirevonaDailyspace
//

import SwiftUI

private enum MainTabChrome {
    /// Visual height of `CustomTabBar` (card + shadow), excluding the home indicator — tuned after removing inner bottom padding on the bar.
    static let tabBarBodyHeight: CGFloat = 78
}

struct MainTabContainerView: View {
    @State private var tab: RootTab = .home

    var body: some View {
        GeometryReader { proxy in
            let homeBottom = proxy.safeAreaInsets.bottom
            ZStack(alignment: .bottom) {
                tabRoot
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    .padding(.bottom, MainTabChrome.tabBarBodyHeight + homeBottom)

                CustomTabBar(selection: $tab)
                    .padding(.bottom, max(homeBottom, 6))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        // Read real home-indicator inset (otherwise `safeAreaInsets.bottom` is often 0 here and we add a fake extra gap).
        .ignoresSafeArea(edges: .bottom)
    }

    @ViewBuilder
    private var tabRoot: some View {
        switch tab {
        case .home:
            HomeView(selectedTab: $tab)
        case .palettes:
            PaletteManagerView()
        case .studio:
            StudioContainerView()
        case .achievements:
            AchievementsView()
        case .settings:
            SettingsView()
        }
    }
}
