//
//  PaletteHistoryViewModel.swift
//  172MirevonaDailyspace
//

import Combine
import Foundation

@MainActor
final class PaletteHistoryViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var restorePulse = false
    @Published var editorPalette: SavedPalette?

    func filtered(from palettes: [SavedPalette]) -> [SavedPalette] {
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.isEmpty == false else { return palettes }
        let needle = trimmed.lowercased()
        return palettes.filter { palette in
            if palette.title.lowercased().contains(needle) {
                return true
            }
            let folder = palette.folder.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            if folder.isEmpty == false, folder.contains(needle) {
                return true
            }
            if palette.tags.contains(where: { $0.lowercased().contains(needle) }) {
                return true
            }
            return palette.colors.contains { color in
                let hex = color.hex.lowercased().replacingOccurrences(of: "#", with: "")
                return hex.contains(needle)
            }
        }
    }
}
