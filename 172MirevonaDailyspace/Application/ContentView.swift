//
//  ContentView.swift
//  172MirevonaDailyspace
//

import Combine
import SwiftUI
import UIKit

struct ContentView: View {
    @StateObject private var store = AppStorageStore()
    @Environment(\.scenePhase) private var scenePhase
    private let minuteTicker = Timer.publish(every: 60, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack(alignment: .top) {
            LayeredBackgroundView()
            Group {
                if store.hasSeenOnboarding {
                    MainTabContainerView()
                } else {
                    OnboardingView()
                }
            }
            AchievementBannerOverlay(controller: store.bannerController)
        }
        .environmentObject(store)
        .tint(Color.appPrimary)
        .preferredColorScheme(.dark)
        .onAppear {
            styleKeyWindowForAppBackground()
            DispatchQueue.main.async {
                styleKeyWindowForAppBackground()
            }
        }
        .onReceive(minuteTicker) { _ in
            guard scenePhase == .active else { return }
            store.incrementMinuteUsed()
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active {
                store.registerActivity()
            }
        }
    }

    private func styleKeyWindowForAppBackground() {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
        let window = scene.windows.first { $0.isKeyWindow } ?? scene.windows.first
        guard let window else { return }
        let bg = UIColor(named: "AppBackground") ?? UIColor(red: 0.18, green: 0.12, blue: 0.20, alpha: 1)
        let lift = UIColor(named: "AppSurface") ?? bg
        window.backgroundColor = bg
        // Slightly lighter than pure base so launch / safe areas feel less “ink black”.
        window.rootViewController?.view.backgroundColor = lift.withAlphaComponent(0.94)
    }
}

#Preview {
    ContentView()
}
