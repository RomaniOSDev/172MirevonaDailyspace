//
//  PaletteManagerViewModel.swift
//  172MirevonaDailyspace
//

import Combine
import Foundation
import SwiftUI

enum PaletteFolderFilter: Equatable, Hashable {
    case all
    case uncategorized
    case named(String)
}

@MainActor
final class PaletteManagerViewModel: ObservableObject {
    @Published var showComposer = false
    @Published var showSuccessBadge = false
    @Published var searchText = ""
    @Published var favoritesOnly = false
    @Published var folderFilter: PaletteFolderFilter = .all
    @Published var tagFilter: String = ""

    func flashSaveSuccess() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.72)) {
            showSuccessBadge = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            withAnimation(.easeOut(duration: 0.35)) {
                self?.showSuccessBadge = false
            }
        }
    }

    func folderNames(from palettes: [SavedPalette]) -> [String] {
        let names = palettes.map(\.folder).map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }
        return Array(Set(names)).sorted { $0.localizedCaseInsensitiveCompare($1) == .orderedAscending }
    }

    func tagSuggestions(from palettes: [SavedPalette]) -> [String] {
        let tags = palettes.flatMap(\.tags).map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }
        return Array(Set(tags)).sorted { $0.localizedCaseInsensitiveCompare($1) == .orderedAscending }
    }

    func filteredPalettes(from palettes: [SavedPalette]) -> [SavedPalette] {
        var list = palettes
        if favoritesOnly {
            list = list.filter(\.isFavorite)
        }
        switch folderFilter {
        case .all:
            break
        case .uncategorized:
            list = list.filter { $0.folder.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        case .named(let name):
            list = list.filter { $0.folder.trimmingCharacters(in: .whitespacesAndNewlines) == name }
        }
        let tagNeedle = tagFilter.trimmingCharacters(in: .whitespacesAndNewlines)
        if tagNeedle.isEmpty == false {
            list = list.filter { palette in
                palette.tags.contains { $0.compare(tagNeedle, options: .caseInsensitive) == .orderedSame }
            }
        }
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.isEmpty == false else { return list }
        let needle = trimmed.lowercased().replacingOccurrences(of: "#", with: "")
        return list.filter { palette in
            if palette.title.lowercased().contains(needle) { return true }
            let folder = palette.folder.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            if folder.isEmpty == false, folder.contains(needle) { return true }
            if palette.tags.contains(where: { $0.lowercased().contains(needle) }) { return true }
            return palette.colors.contains { color in
                let hex = color.hex.lowercased().replacingOccurrences(of: "#", with: "")
                return hex.contains(needle)
            }
        }
    }
}
