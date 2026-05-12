//
//  AchievementBannerOverlay.swift
//  172MirevonaDailyspace
//

import Combine
import SwiftUI

struct AchievementBannerOverlay: View {
    @ObservedObject var controller: AchievementBannerController

    var body: some View {
        VStack {
            bannerOptionalContent
            Spacer()
        }
        .allowsHitTesting(false)
    }

    @ViewBuilder
    private var bannerOptionalContent: some View {
        if controller.isVisible {
            if let title = controller.currentTitle {
                AchievementBannerCard(title: title)
            }
        }
    }
}

private struct AchievementBannerCard: View {
    let title: String

    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            trophyImage
            titleStack
            Spacer(minLength: 0)
        }
        .padding(14)
        .background {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color("AppPrimary"), Color("AppPrimary").opacity(0.82)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.22), lineWidth: 1)
                }
                .shadow(color: Color.black.opacity(0.28), radius: 12, x: 0, y: 6)
        }
        .padding(.horizontal, 16)
        .padding(.top, 10)
        .transition(.opacity)
    }

    private var trophyImage: some View {
        Image(systemName: "trophy.fill")
            .foregroundStyle(Color("AppBackground"))
    }

    private var titleStack: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("Achievement unlocked")
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color("AppBackground"))
                .opacity(0.9)
            Text(title)
                .font(.headline)
                .foregroundStyle(Color("AppBackground"))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
    }
}
