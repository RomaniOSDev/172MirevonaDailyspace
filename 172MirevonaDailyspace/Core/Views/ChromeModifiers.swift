//
//  ChromeModifiers.swift
//  172MirevonaDailyspace
//

import SwiftUI

extension View {
    /// Lets the root `LayeredBackgroundView` show through system navigation chrome.
    func transparentAppNavigation() -> some View {
        toolbarBackground(.hidden, for: .navigationBar)
    }

    /// Decorative atmosphere behind a screen root (e.g. `NavigationStack`) so lists/scrolls aren’t flat ink over the window.
    func appScreenAtmosphere() -> some View {
        background {
            LayeredBackgroundView()
        }
    }

    /// Sheet / full-screen cover use a white system backdrop by default; match app chrome (iOS 16.4+).
    @ViewBuilder
    func appPresentationChrome() -> some View {
        if #available(iOS 16.4, *) {
            presentationBackground {
                LayeredBackgroundView()
            }
        } else {
            self
        }
    }
}
