//
//  PaletteModels.swift
//  172MirevonaDailyspace
//

import Foundation

struct PaletteColorItem: Codable, Identifiable, Hashable {
    var id: UUID
    var hex: String
    var name: String

    init(id: UUID = UUID(), hex: String, name: String) {
        self.id = id
        self.hex = hex
        self.name = name
    }
}

/// Point-in-time copy of a palette for undo / comparison (kept on the owning `SavedPalette`).
struct PaletteVersionSnapshot: Codable, Identifiable, Hashable {
    var id: UUID
    var createdAt: Date
    var title: String
    var colors: [PaletteColorItem]

    init(id: UUID = UUID(), createdAt: Date = Date(), title: String, colors: [PaletteColorItem]) {
        self.id = id
        self.createdAt = createdAt
        self.title = title
        self.colors = colors
    }
}

struct SavedPalette: Identifiable, Hashable {
    var id: UUID
    var title: String
    var colors: [PaletteColorItem]
    var createdAt: Date
    var harmonyIsPerfect: Bool
    /// Virtual folder name (empty = uncategorized).
    var folder: String
    var tags: [String]
    var isFavorite: Bool
    var versions: [PaletteVersionSnapshot]

    init(
        id: UUID = UUID(),
        title: String,
        colors: [PaletteColorItem],
        createdAt: Date = Date(),
        harmonyIsPerfect: Bool,
        folder: String = "",
        tags: [String] = [],
        isFavorite: Bool = false,
        versions: [PaletteVersionSnapshot] = []
    ) {
        self.id = id
        self.title = title
        self.colors = colors
        self.createdAt = createdAt
        self.harmonyIsPerfect = harmonyIsPerfect
        self.folder = folder
        self.tags = tags
        self.isFavorite = isFavorite
        self.versions = versions
    }
}

extension SavedPalette: Codable {
    enum CodingKeys: String, CodingKey {
        case id, title, colors, createdAt, harmonyIsPerfect, folder, tags, isFavorite, versions
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(UUID.self, forKey: .id)
        title = try c.decode(String.self, forKey: .title)
        colors = try c.decode([PaletteColorItem].self, forKey: .colors)
        createdAt = try c.decode(Date.self, forKey: .createdAt)
        harmonyIsPerfect = try c.decodeIfPresent(Bool.self, forKey: .harmonyIsPerfect) ?? false
        folder = try c.decodeIfPresent(String.self, forKey: .folder) ?? ""
        tags = try c.decodeIfPresent([String].self, forKey: .tags) ?? []
        isFavorite = try c.decodeIfPresent(Bool.self, forKey: .isFavorite) ?? false
        versions = try c.decodeIfPresent([PaletteVersionSnapshot].self, forKey: .versions) ?? []
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(id, forKey: .id)
        try c.encode(title, forKey: .title)
        try c.encode(colors, forKey: .colors)
        try c.encode(createdAt, forKey: .createdAt)
        try c.encode(harmonyIsPerfect, forKey: .harmonyIsPerfect)
        try c.encode(folder, forKey: .folder)
        try c.encode(tags, forKey: .tags)
        try c.encode(isFavorite, forKey: .isFavorite)
        try c.encode(versions, forKey: .versions)
    }
}

struct ColorTrend: Codable, Identifiable, Hashable {
    var id: UUID
    var colorHex: String
    var date: Date

    init(id: UUID = UUID(), colorHex: String, date: Date = Date()) {
        self.id = id
        self.colorHex = colorHex
        self.date = date
    }
}

struct AchievementDefinition: Identifiable, Hashable {
    let id: String
    let title: String
    let description: String

    func isUnlocked(
        itemsCreated: Int,
        totalSessionsCompleted: Int,
        streakDays: Int,
        duplicatePalettesCount: Int,
        snapshotsCreatedCount: Int,
        palettesWithTagsCount: Int,
        favoritePaletteCount: Int
    ) -> Bool {
        switch id {
        case "first_palette":
            return itemsCreated >= 1
        case "palette_enthusiast":
            return itemsCreated >= 10
        case "dedicated_designer":
            return streakDays >= 3
        case "trend_setter":
            return totalSessionsCompleted >= 5
        case "color_goals":
            return totalSessionsCompleted >= 5
        case "harmony_master":
            return itemsCreated >= 3
        case "weekly_streak":
            return streakDays >= 7
        case "palette_maestro":
            return itemsCreated >= 50
        case "tagged_curator":
            return palettesWithTagsCount >= 5
        case "version_archivist":
            return snapshotsCreatedCount >= 8
        case "duplicate_explorer":
            return duplicatePalettesCount >= 5
        case "heart_collector":
            return favoritePaletteCount >= 6
        default:
            return false
        }
    }
}

enum AchievementCatalog {
    static let all: [AchievementDefinition] = [
        AchievementDefinition(id: "first_palette", title: "First Palette", description: "Created your first color palette."),
        AchievementDefinition(id: "palette_enthusiast", title: "Palette Enthusiast", description: "Created 10 unique palettes."),
        AchievementDefinition(id: "dedicated_designer", title: "Dedicated Designer", description: "Used the app for three consecutive days."),
        AchievementDefinition(id: "trend_setter", title: "Trend Setter", description: "Accessed trend insights five times."),
        AchievementDefinition(id: "color_goals", title: "#ColorGoals", description: "Saved and customized five or more colors in a single session."),
        AchievementDefinition(id: "harmony_master", title: "Harmony Master", description: "Achieved perfect harmony status in at least three saved palettes."),
        AchievementDefinition(id: "weekly_streak", title: "Weekly Streak", description: "Opened the app every day for seven days."),
        AchievementDefinition(id: "palette_maestro", title: "Palette Maestro", description: "Reached an overall milestone of creating fifty or more palettes."),
        AchievementDefinition(id: "tagged_curator", title: "Tagged Curator", description: "Added tags to at least five different palettes."),
        AchievementDefinition(id: "version_archivist", title: "Version Archivist", description: "Saved eight or more palette snapshots."),
        AchievementDefinition(id: "duplicate_explorer", title: "Duplicate Explorer", description: "Duplicated palettes five times."),
        AchievementDefinition(id: "heart_collector", title: "Heart Collector", description: "Marked six palettes as favorites.")
    ]
}
