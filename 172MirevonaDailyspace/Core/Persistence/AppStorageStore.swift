//
//  AppStorageStore.swift
//  172MirevonaDailyspace
//

import Combine
import Foundation
import SwiftUI

@MainActor
final class AppStorageStore: ObservableObject {
    private let defaults = UserDefaults.standard
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private var cancellables = Set<AnyCancellable>()

    private enum Key {
        static let hasSeenOnboarding = "dn_hasSeenOnboarding"
        static let palettes = "dn_palettes"
        static let paletteHistory = "dn_paletteHistory"
        static let recentlyUsedColors = "dn_recentlyUsedColors"
        static let favoriteColorHex = "dn_favoriteColorHex"
        static let trendingColors = "dn_trendingColors"
        static let lastSelectedPaletteId = "dn_lastSelectedPaletteId"
        static let totalSessionsCompleted = "dn_totalSessionsCompleted"
        static let totalMinutesUsed = "dn_totalMinutesUsed"
        static let streakDays = "dn_streakDays"
        static let lastActivityDate = "dn_lastActivityDate"
        static let achievementsUnlocked = "dn_achievementsUnlocked"
        static let trendInsightsViews = "dn_trendInsightsViews"
        static let perfectHarmonyPaletteCount = "dn_perfectHarmonyPaletteCount"
        static let duplicatePalettesCount = "dn_duplicatePalettesCount"
        static let snapshotsCreatedCount = "dn_snapshotsCreatedCount"
    }

    @Published private(set) var hasSeenOnboarding: Bool
    @Published private(set) var palettes: [SavedPalette]
    @Published private(set) var paletteHistory: [SavedPalette]
    @Published private(set) var recentlyUsedColors: [String]
    @Published private(set) var favoriteColorHex: String
    @Published private(set) var trendingColors: [ColorTrend]
    @Published private(set) var lastSelectedPaletteId: UUID?
    @Published private(set) var totalSessionsCompleted: Int
    @Published private(set) var totalMinutesUsed: Int
    @Published private(set) var streakDays: Int
    @Published private(set) var lastActivityDate: Date?
    @Published private(set) var achievementsUnlocked: [String: Date]
    @Published private(set) var trendInsightsViews: Int
    @Published private(set) var perfectHarmonyPaletteCount: Int
    @Published private(set) var duplicatePalettesCount: Int
    @Published private(set) var snapshotsCreatedCount: Int

    let bannerController = AchievementBannerController()

    var itemsCreated: Int {
        palettes.count
    }

    var palettesWithTagsCount: Int {
        palettes.filter { $0.tags.isEmpty == false }.count
    }

    var favoritePaletteCount: Int {
        palettes.filter(\.isFavorite).count
    }

    init() {
        hasSeenOnboarding = defaults.bool(forKey: Key.hasSeenOnboarding)
        palettes = Self.decode([SavedPalette].self, from: defaults.string(forKey: Key.palettes), decoder: decoder) ?? []
        paletteHistory = Self.decode([SavedPalette].self, from: defaults.string(forKey: Key.paletteHistory), decoder: decoder) ?? []
        recentlyUsedColors = Self.decode([String].self, from: defaults.string(forKey: Key.recentlyUsedColors), decoder: decoder) ?? []
        favoriteColorHex = defaults.string(forKey: Key.favoriteColorHex) ?? "FFFFFF"
        trendingColors = Self.decode([ColorTrend].self, from: defaults.string(forKey: Key.trendingColors), decoder: decoder) ?? []
        if let idString = defaults.string(forKey: Key.lastSelectedPaletteId), let id = UUID(uuidString: idString) {
            lastSelectedPaletteId = id
        } else {
            lastSelectedPaletteId = nil
        }
        totalSessionsCompleted = defaults.integer(forKey: Key.totalSessionsCompleted)
        totalMinutesUsed = defaults.integer(forKey: Key.totalMinutesUsed)
        streakDays = defaults.integer(forKey: Key.streakDays)
        lastActivityDate = defaults.object(forKey: Key.lastActivityDate) as? Date
        achievementsUnlocked = Self.decode([String: Date].self, from: defaults.string(forKey: Key.achievementsUnlocked), decoder: decoder) ?? [:]
        trendInsightsViews = defaults.integer(forKey: Key.trendInsightsViews)
        perfectHarmonyPaletteCount = defaults.integer(forKey: Key.perfectHarmonyPaletteCount)
        duplicatePalettesCount = defaults.integer(forKey: Key.duplicatePalettesCount)
        snapshotsCreatedCount = defaults.integer(forKey: Key.snapshotsCreatedCount)

        bannerController.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)

        evaluateAchievements()
    }

    private static func decode<T: Decodable>(_ type: T.Type, from string: String?, decoder: JSONDecoder) -> T? {
        guard let string, let data = string.data(using: .utf8) else { return nil }
        return try? decoder.decode(T.self, from: data)
    }

    private func persist() {
        defaults.set(hasSeenOnboarding, forKey: Key.hasSeenOnboarding)
        if let data = try? encoder.encode(palettes), let str = String(data: data, encoding: .utf8) {
            defaults.set(str, forKey: Key.palettes)
        }
        if let data = try? encoder.encode(paletteHistory), let str = String(data: data, encoding: .utf8) {
            defaults.set(str, forKey: Key.paletteHistory)
        }
        if let data = try? encoder.encode(recentlyUsedColors), let str = String(data: data, encoding: .utf8) {
            defaults.set(str, forKey: Key.recentlyUsedColors)
        }
        defaults.set(favoriteColorHex, forKey: Key.favoriteColorHex)
        if let data = try? encoder.encode(trendingColors), let str = String(data: data, encoding: .utf8) {
            defaults.set(str, forKey: Key.trendingColors)
        }
        if let lastSelectedPaletteId {
            defaults.set(lastSelectedPaletteId.uuidString, forKey: Key.lastSelectedPaletteId)
        } else {
            defaults.removeObject(forKey: Key.lastSelectedPaletteId)
        }
        defaults.set(totalSessionsCompleted, forKey: Key.totalSessionsCompleted)
        defaults.set(totalMinutesUsed, forKey: Key.totalMinutesUsed)
        defaults.set(streakDays, forKey: Key.streakDays)
        if let lastActivityDate {
            defaults.set(lastActivityDate, forKey: Key.lastActivityDate)
        } else {
            defaults.removeObject(forKey: Key.lastActivityDate)
        }
        if let data = try? encoder.encode(achievementsUnlocked), let str = String(data: data, encoding: .utf8) {
            defaults.set(str, forKey: Key.achievementsUnlocked)
        }
        defaults.set(trendInsightsViews, forKey: Key.trendInsightsViews)
        defaults.set(perfectHarmonyPaletteCount, forKey: Key.perfectHarmonyPaletteCount)
        defaults.set(duplicatePalettesCount, forKey: Key.duplicatePalettesCount)
        defaults.set(snapshotsCreatedCount, forKey: Key.snapshotsCreatedCount)
    }

    func finishOnboarding() {
        hasSeenOnboarding = true
        persist()
        objectWillChange.send()
    }

    func registerActivity() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        if let last = lastActivityDate {
            let lastDay = calendar.startOfDay(for: last)
            if lastDay == today {
                persist()
                objectWillChange.send()
                evaluateAchievements()
                return
            }
            let dayDiff = calendar.dateComponents([.day], from: lastDay, to: today).day ?? 0
            if dayDiff == 1 {
                streakDays = max(1, streakDays + 1)
            } else {
                streakDays = 1
            }
        } else {
            streakDays = max(1, streakDays)
            if streakDays == 0 {
                streakDays = 1
            }
        }
        lastActivityDate = Date()
        persist()
        objectWillChange.send()
        evaluateAchievements()
    }

    func incrementMinuteUsed() {
        totalMinutesUsed += 1
        persist()
        objectWillChange.send()
    }

    func recordTrendInsightsView() {
        trendInsightsViews += 1
        totalSessionsCompleted += 1
        registerActivity()
        objectWillChange.send()
    }

    func recordSessionCompleted() {
        totalSessionsCompleted += 1
        registerActivity()
    }

    func addPalette(title: String, colors: [PaletteColorItem], recordSession: Bool) {
        let normalized = colors.map { item -> PaletteColorItem in
            let hex = HexColorCodec.normalizedHex(from: item.hex) ?? item.hex
            return PaletteColorItem(id: item.id, hex: hex, name: item.name)
        }
        let harmony = HarmonyEvaluator.isPerfectHarmony(normalizedHexes: normalized.map(\.hex))
        let palette = SavedPalette(title: title, colors: normalized, createdAt: Date(), harmonyIsPerfect: harmony)
        palettes.insert(palette, at: 0)
        paletteHistory.insert(palette, at: 0)
        mergeTrends(from: normalized.map(\.hex))
        bumpRecentlyUsed(from: normalized.map(\.hex))
        if let first = normalized.first?.hex {
            favoriteColorHex = first
        }
        if harmony {
            perfectHarmonyPaletteCount += 1
        }
        if recordSession {
            totalSessionsCompleted += 1
        }
        registerActivity()
    }

    func updatePalette(_ palette: SavedPalette) {
        guard let idx = palettes.firstIndex(where: { $0.id == palette.id }) else { return }
        var updated = palette
        updated.colors = updated.colors.map { item in
            let hex = HexColorCodec.normalizedHex(from: item.hex) ?? item.hex
            return PaletteColorItem(id: item.id, hex: hex, name: item.name)
        }
        updated.harmonyIsPerfect = HarmonyEvaluator.isPerfectHarmony(normalizedHexes: updated.colors.map(\.hex))
        palettes[idx] = updated
        if let hIdx = paletteHistory.firstIndex(where: { $0.id == palette.id }) {
            paletteHistory[hIdx] = updated
        }
        mergeTrends(from: updated.colors.map(\.hex))
        bumpRecentlyUsed(from: updated.colors.map(\.hex))
        registerActivity()
    }

    func duplicatePalette(from source: SavedPalette) {
        let titles = Set(palettes.map(\.title))
        let newTitle = Self.makeDuplicateTitle(from: source.title, existingTitles: titles)
        let newColors = source.colors.map { PaletteColorItem(hex: $0.hex, name: $0.name) }
        let normalized = newColors.map { item -> PaletteColorItem in
            let hex = HexColorCodec.normalizedHex(from: item.hex) ?? item.hex
            return PaletteColorItem(id: item.id, hex: hex, name: item.name)
        }
        let harmony = HarmonyEvaluator.isPerfectHarmony(normalizedHexes: normalized.map(\.hex))
        let copy = SavedPalette(
            title: newTitle,
            colors: normalized,
            createdAt: Date(),
            harmonyIsPerfect: harmony,
            folder: source.folder,
            tags: source.tags,
            isFavorite: false,
            versions: []
        )
        palettes.insert(copy, at: 0)
        paletteHistory.insert(copy, at: 0)
        mergeTrends(from: normalized.map(\.hex))
        bumpRecentlyUsed(from: normalized.map(\.hex))
        duplicatePalettesCount += 1
        registerActivity()
    }

    func togglePaletteFavorite(id: UUID) {
        guard let idx = palettes.firstIndex(where: { $0.id == id }) else { return }
        palettes[idx].isFavorite.toggle()
        if let hIdx = paletteHistory.firstIndex(where: { $0.id == id }) {
            paletteHistory[hIdx].isFavorite = palettes[idx].isFavorite
        }
        persist()
        objectWillChange.send()
        evaluateAchievements()
    }

    func setPaletteFavorite(id: UUID, isFavorite: Bool) {
        guard let idx = palettes.firstIndex(where: { $0.id == id }) else { return }
        guard palettes[idx].isFavorite != isFavorite else { return }
        palettes[idx].isFavorite = isFavorite
        if let hIdx = paletteHistory.firstIndex(where: { $0.id == id }) {
            paletteHistory[hIdx].isFavorite = isFavorite
        }
        persist()
        objectWillChange.send()
        evaluateAchievements()
    }

    /// Stores the current swatch list as a recoverable snapshot (capped per palette).
    func savePaletteSnapshot(paletteId: UUID, title: String, colors: [PaletteColorItem]) {
        guard let idx = palettes.firstIndex(where: { $0.id == paletteId }) else { return }
        let snapshotColors = colors.map { item in
            let hex = HexColorCodec.normalizedHex(from: item.hex) ?? item.hex
            return PaletteColorItem(hex: hex, name: item.name)
        }
        let snap = PaletteVersionSnapshot(title: title, colors: snapshotColors)
        var p = palettes[idx]
        p.versions.insert(snap, at: 0)
        if p.versions.count > 24 {
            p.versions = Array(p.versions.prefix(24))
        }
        palettes[idx] = p
        if let hIdx = paletteHistory.firstIndex(where: { $0.id == paletteId }) {
            paletteHistory[hIdx] = p
        }
        snapshotsCreatedCount += 1
        persist()
        objectWillChange.send()
        evaluateAchievements()
    }

    func restorePaletteFromSnapshot(paletteId: UUID, snapshotId: UUID) {
        guard let idx = palettes.firstIndex(where: { $0.id == paletteId }),
              let snap = palettes[idx].versions.first(where: { $0.id == snapshotId }) else { return }
        var p = palettes[idx]
        p.title = snap.title
        p.colors = snap.colors.map { item in
            let hex = HexColorCodec.normalizedHex(from: item.hex) ?? item.hex
            return PaletteColorItem(hex: hex, name: item.name)
        }
        p.harmonyIsPerfect = HarmonyEvaluator.isPerfectHarmony(normalizedHexes: p.colors.map(\.hex))
        palettes[idx] = p
        if let hIdx = paletteHistory.firstIndex(where: { $0.id == paletteId }) {
            paletteHistory[hIdx] = p
        }
        mergeTrends(from: p.colors.map(\.hex))
        bumpRecentlyUsed(from: p.colors.map(\.hex))
        registerActivity()
        persist()
        objectWillChange.send()
    }

    private static func makeDuplicateTitle(from title: String, existingTitles: Set<String>) -> String {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let base = trimmed.isEmpty ? "Palette" : trimmed
        var candidate = "\(base) Copy"
        var n = 2
        while existingTitles.contains(candidate) {
            candidate = "\(base) Copy \(n)"
            n += 1
        }
        return candidate
    }

    func deletePalette(id: UUID) {
        palettes.removeAll { $0.id == id }
        if lastSelectedPaletteId == id {
            lastSelectedPaletteId = nil
        }
        registerActivity()
    }

    func deleteHistoryEntry(id: UUID) {
        paletteHistory.removeAll { $0.id == id }
        if lastSelectedPaletteId == id {
            lastSelectedPaletteId = nil
        }
        registerActivity()
    }

    func selectPalette(id: UUID?) {
        lastSelectedPaletteId = id
        persist()
        objectWillChange.send()
    }

    func restoreSelectedPalette() {
        guard let id = lastSelectedPaletteId,
              let palette = paletteHistory.first(where: { $0.id == id }) else { return }
        if palettes.contains(where: { $0.id == palette.id }) == false {
            palettes.insert(palette, at: 0)
        }
        totalSessionsCompleted += 1
        registerActivity()
    }

    func resetAll() {
        let keys: [String] = [
            Key.hasSeenOnboarding,
            Key.palettes,
            Key.paletteHistory,
            Key.recentlyUsedColors,
            Key.favoriteColorHex,
            Key.trendingColors,
            Key.lastSelectedPaletteId,
            Key.totalSessionsCompleted,
            Key.totalMinutesUsed,
            Key.streakDays,
            Key.lastActivityDate,
            Key.achievementsUnlocked,
            Key.trendInsightsViews,
            Key.perfectHarmonyPaletteCount,
            Key.duplicatePalettesCount,
            Key.snapshotsCreatedCount
        ]
        keys.forEach { defaults.removeObject(forKey: $0) }
        hasSeenOnboarding = false
        palettes = []
        paletteHistory = []
        recentlyUsedColors = []
        favoriteColorHex = "FFFFFF"
        trendingColors = []
        lastSelectedPaletteId = nil
        totalSessionsCompleted = 0
        totalMinutesUsed = 0
        streakDays = 0
        lastActivityDate = nil
        achievementsUnlocked = [:]
        trendInsightsViews = 0
        perfectHarmonyPaletteCount = 0
        duplicatePalettesCount = 0
        snapshotsCreatedCount = 0
        persist()
        objectWillChange.send()
        NotificationCenter.default.post(name: .dataReset, object: nil)
    }

    private func bumpRecentlyUsed(from hexes: [String]) {
        var merged = hexes + recentlyUsedColors
        var unique: [String] = []
        for hex in merged {
            let norm = HexColorCodec.normalizedHex(from: hex) ?? hex
            if unique.contains(norm) == false {
                unique.append(norm)
            }
            if unique.count >= 24 {
                break
            }
        }
        recentlyUsedColors = unique
    }

    private func mergeTrends(from hexes: [String]) {
        let now = Date()
        let additions = hexes.map { ColorTrend(colorHex: $0, date: now) }
        trendingColors = additions + trendingColors
        if trendingColors.count > 400 {
            trendingColors = Array(trendingColors.prefix(400))
        }
    }

    func colorUsageCounts() -> [(hex: String, count: Int)] {
        var counts: [String: Int] = [:]
        for palette in palettes {
            for c in palette.colors {
                let key = HexColorCodec.normalizedHex(from: c.hex) ?? c.hex
                counts[key, default: 0] += 1
            }
        }
        return counts.map { ($0.key, $0.value) }.sorted { $0.count > $1.count }
    }

    func evaluateAchievements() {
        var unlockedNow: [AchievementDefinition] = []
        var next = achievementsUnlocked
        for def in AchievementCatalog.all {
            let should = def.isUnlocked(
                itemsCreated: itemsCreated,
                totalSessionsCompleted: totalSessionsCompleted,
                streakDays: streakDays,
                duplicatePalettesCount: duplicatePalettesCount,
                snapshotsCreatedCount: snapshotsCreatedCount,
                palettesWithTagsCount: palettesWithTagsCount,
                favoritePaletteCount: favoritePaletteCount
            )
            if should, next[def.id] == nil {
                next[def.id] = Date()
                unlockedNow.append(def)
            }
        }
        if unlockedNow.isEmpty == false {
            achievementsUnlocked = next
            persist()
            objectWillChange.send()
            HapticFeedback.success()
            SystemSound.play(1057)
            for item in unlockedNow {
                bannerController.enqueue(title: item.title)
            }
        }
    }

    func aggregatedSuccessPing() {
        HapticFeedback.success()
        SystemSound.play(1057)
    }
}
