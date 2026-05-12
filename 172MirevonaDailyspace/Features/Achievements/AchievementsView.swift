//
//  AchievementsView.swift
//  172MirevonaDailyspace
//

import Combine
import SwiftUI

struct AchievementsView: View {
    @EnvironmentObject private var store: AppStorageStore
    @StateObject private var viewModel = AchievementsViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    summaryCard
                    LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                        ForEach(AchievementCatalog.all) { achievement in
                            AchievementBadgeView(
                                achievement: achievement,
                                unlocked: achievement.isUnlocked(
                                    itemsCreated: store.itemsCreated,
                                    totalSessionsCompleted: store.totalSessionsCompleted,
                                    streakDays: store.streakDays,
                                    duplicatePalettesCount: store.duplicatePalettesCount,
                                    snapshotsCreatedCount: store.snapshotsCreatedCount,
                                    palettesWithTagsCount: store.palettesWithTagsCount,
                                    favoritePaletteCount: store.favoritePaletteCount
                                ),
                                date: store.achievementsUnlocked[achievement.id]
                            )
                        }
                    }
                }
                .padding(16)
            }
            .scrollContentBackground(.hidden)
            .scrollIndicators(.visible)
            .navigationTitle("Achievements")
            .onAppear {
                viewModel.touch()
            }
            .transparentAppNavigation()
            .appScreenAtmosphere()
        }
    }

    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Progress overview")
                .font(.headline)
                .foregroundStyle(Color.appTextPrimary)
            HStack {
                metricBlock(title: "Palettes", value: "\(store.itemsCreated)")
                metricBlock(title: "Minutes", value: "\(store.totalMinutesUsed)")
                metricBlock(title: "Streak", value: "\(store.streakDays)d")
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .appElevatedCard(cornerRadius: 18)
    }

    private func metricBlock(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title.uppercased())
                .font(.caption2.weight(.semibold))
                .foregroundStyle(Color.appTextSecondary)
            Text(value)
                .font(.title3.bold())
                .foregroundStyle(Color.appAccent)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct AchievementBadgeView: View {
    let achievement: AchievementDefinition
    let unlocked: Bool
    let date: Date?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: unlocked ? "star.circle.fill" : "lock.circle")
                    .foregroundStyle(unlocked ? Color.appAccent : Color.appTextSecondary)
                Spacer()
            }
            Text(achievement.title)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(Color.appTextPrimary)
                .lineLimit(2)
                .minimumScaleFactor(0.75)
            Text(achievement.description)
                .font(.caption2)
                .foregroundStyle(Color.appTextSecondary)
                .lineLimit(3)
                .minimumScaleFactor(0.8)
            if unlocked, let date {
                Text(date.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(Color.appPrimary)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, minHeight: 140, alignment: .topLeading)
        .background {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.appSurface.opacity(unlocked ? 0.95 : 0.62),
                            Color.appSurface.opacity(unlocked ? 0.68 : 0.4)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .strokeBorder(
                            unlocked
                                ? Color.appAccent.opacity(0.45)
                                : Color.appTextPrimary.opacity(0.08),
                            lineWidth: unlocked ? 1.5 : 1
                        )
                }
        }
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}
