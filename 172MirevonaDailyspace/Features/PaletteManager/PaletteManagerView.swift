//
//  PaletteManagerView.swift
//  172MirevonaDailyspace
//

import Combine
import SwiftUI

struct PaletteManagerView: View {
    @EnvironmentObject private var store: AppStorageStore
    @StateObject private var viewModel = PaletteManagerViewModel()

    private var displayedPalettes: [SavedPalette] {
        viewModel.filteredPalettes(from: store.palettes)
    }

    private var hasActiveFilters: Bool {
        viewModel.favoritesOnly
            || viewModel.folderFilter != .all
            || viewModel.tagFilter.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
            || viewModel.searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
    }

    var body: some View {
        NavigationStack {
            ZStack {
                if store.palettes.isEmpty {
                    ScrollView {
                        emptyState
                            .padding(.vertical, 40)
                    }
                    .scrollContentBackground(.hidden)
                } else {
                    VStack(alignment: .leading, spacing: 0) {
                        paletteFilterStrip
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                        List {
                            if displayedPalettes.isEmpty {
                                Text("No palettes match your filters.")
                                    .font(.subheadline)
                                    .foregroundStyle(Color.appTextSecondary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.vertical, 8)
                                    .listRowBackground(Color.clear)
                            } else {
                                ForEach(displayedPalettes) { palette in
                                    NavigationLink(value: palette) {
                                        PaletteCardRow(palette: palette)
                                    }
                                    .listRowBackground(ListRowChromeBackground(cornerRadius: 12))
                                    .swipeActions(edge: .leading, allowsFullSwipe: false) {
                                        Button {
                                            HapticFeedback.tap()
                                            store.togglePaletteFavorite(id: palette.id)
                                        } label: {
                                            Label(
                                                palette.isFavorite ? "Unfavorite" : "Favorite",
                                                systemImage: palette.isFavorite ? "heart.slash.fill" : "heart.fill"
                                            )
                                        }
                                        .tint(Color.appAccent)
                                    }
                                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                        Button(role: .destructive) {
                                            HapticFeedback.tap()
                                            store.deletePalette(id: palette.id)
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                                }
                            }
                        }
                        .listStyle(.insetGrouped)
                        .scrollContentBackground(.hidden)
                    }
                }

                if viewModel.showSuccessBadge {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 64))
                        .foregroundStyle(Color.appAccent)
                        .shadow(radius: 8)
                        .transition(.scale.combined(with: .opacity))
                        .allowsHitTesting(false)
                }
            }
            .navigationDestination(for: SavedPalette.self) { palette in
                PaletteDetailView(palette: palette)
            }
            .navigationTitle("My Palettes")
            .searchable(text: $viewModel.searchText, prompt: "Title, hex, folder, or tags")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        HapticFeedback.tap()
                        viewModel.showComposer = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.body.weight(.semibold))
                            .frame(width: 44, height: 44)
                            .contentShape(Rectangle())
                    }
                    .accessibilityLabel("Add palette")
                }
            }
            .sheet(isPresented: $viewModel.showComposer) {
                PaletteEditorSheetView(existing: nil) {
                    viewModel.flashSaveSuccess()
                }
                .environmentObject(store)
                .appPresentationChrome()
            }
            .transparentAppNavigation()
            .appScreenAtmosphere()
        }
    }

    private var paletteFilterStrip: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                filterChip(
                    title: "Favorites",
                    icon: "heart.fill",
                    isOn: viewModel.favoritesOnly
                ) {
                    HapticFeedback.tap()
                    viewModel.favoritesOnly.toggle()
                }

                Menu {
                    Button("All folders") {
                        viewModel.folderFilter = .all
                    }
                    Button("Uncategorized") {
                        viewModel.folderFilter = .uncategorized
                    }
                    if viewModel.folderNames(from: store.palettes).isEmpty == false {
                        Divider()
                        ForEach(viewModel.folderNames(from: store.palettes), id: \.self) { name in
                            Button(name) {
                                viewModel.folderFilter = .named(name)
                            }
                        }
                    }
                } label: {
                    filterChipLabel(title: folderMenuTitle, icon: "folder.fill", highlighted: viewModel.folderFilter != .all)
                }

                Menu {
                    Button("Any tag") {
                        viewModel.tagFilter = ""
                    }
                    if viewModel.tagSuggestions(from: store.palettes).isEmpty == false {
                        Divider()
                        ForEach(viewModel.tagSuggestions(from: store.palettes), id: \.self) { tag in
                            Button(tag) {
                                viewModel.tagFilter = tag
                            }
                        }
                    }
                } label: {
                    filterChipLabel(
                        title: viewModel.tagFilter.isEmpty ? "Tag" : viewModel.tagFilter,
                        icon: "tag.fill",
                        highlighted: viewModel.tagFilter.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
                    )
                }

                if hasActiveFilters {
                    Button {
                        HapticFeedback.tap()
                        viewModel.favoritesOnly = false
                        viewModel.folderFilter = .all
                        viewModel.tagFilter = ""
                        viewModel.searchText = ""
                    } label: {
                        Text("Reset")
                            .font(.caption.weight(.semibold))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background {
                                Capsule()
                                    .fill(
                                        LinearGradient(
                                            colors: [Color.appSurface.opacity(0.92), Color.appSurface.opacity(0.62)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .overlay {
                                        Capsule()
                                            .strokeBorder(Color.appTextPrimary.opacity(0.1), lineWidth: 1)
                                    }
                            }
                            .clipShape(Capsule())
                            .foregroundStyle(Color.appPrimary)
                    }
                }
            }
        }
    }

    private var folderMenuTitle: String {
        switch viewModel.folderFilter {
        case .all:
            return "Folder"
        case .uncategorized:
            return "None"
        case .named(let name):
            return name
        }
    }

    private func filterChip(title: String, icon: String, isOn: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                Text(title)
                    .font(.caption.weight(.semibold))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background {
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: isOn
                                ? [Color.appPrimary.opacity(0.55), Color.appPrimary.opacity(0.28)]
                                : [Color.appSurface.opacity(0.92), Color.appSurface.opacity(0.58)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay {
                        Capsule()
                            .strokeBorder(Color.appTextPrimary.opacity(isOn ? 0.14 : 0.09), lineWidth: 1)
                    }
            }
            .clipShape(Capsule())
            .foregroundStyle(Color.appTextPrimary)
        }
        .buttonStyle(.plain)
    }

    private func filterChipLabel(title: String, icon: String, highlighted: Bool) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
            Text(title)
                .font(.caption.weight(.semibold))
                .lineLimit(1)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background {
            Capsule()
                .fill(
                    LinearGradient(
                        colors: highlighted
                            ? [Color.appPrimary.opacity(0.55), Color.appPrimary.opacity(0.28)]
                            : [Color.appSurface.opacity(0.92), Color.appSurface.opacity(0.58)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay {
                    Capsule()
                        .strokeBorder(Color.appTextPrimary.opacity(highlighted ? 0.14 : 0.09), lineWidth: 1)
                }
        }
        .clipShape(Capsule())
        .foregroundStyle(Color.appTextPrimary)
    }

    private var emptyState: some View {
        VStack(spacing: 18) {
            ZStack {
                Image(systemName: "paintpalette.fill")
                    .font(.system(size: 56))
                    .foregroundStyle(Color.appPrimary.opacity(0.85))
                    .offset(x: 10, y: 6)
                Image(systemName: "paintbrush.pointed.fill")
                    .font(.system(size: 52))
                    .foregroundStyle(Color.appAccent)
                    .offset(x: -18, y: -10)
            }
            Text("No Palettes Yet! Tap + to create your first palette.")
                .font(.headline)
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.appTextPrimary)
                .padding(.horizontal, 24)
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .appElevatedCard(cornerRadius: 24, shadowRadius: 12, shadowY: 6)
        .padding(.horizontal, 8)
    }
}

private struct PaletteCardRow: View {
    let palette: SavedPalette

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                Text(palette.title)
                    .font(.headline)
                    .foregroundStyle(Color.appTextPrimary)
                Spacer(minLength: 8)
                if palette.isFavorite {
                    Image(systemName: "heart.fill")
                        .font(.subheadline)
                        .foregroundStyle(Color.appAccent)
                }
                if palette.harmonyIsPerfect {
                    Text("Harmony")
                        .font(.caption2.weight(.bold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background {
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.appAccent.opacity(0.38), Color.appAccent.opacity(0.18)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .overlay {
                                    Capsule()
                                        .strokeBorder(Color.appAccent.opacity(0.35), lineWidth: 1)
                                }
                        }
                        .clipShape(Capsule())
                        .foregroundStyle(Color.appAccent)
                }
            }
            let folder = palette.folder.trimmingCharacters(in: .whitespacesAndNewlines)
            if folder.isEmpty == false {
                Label(folder, systemImage: "folder")
                    .font(.caption)
                    .foregroundStyle(Color.appTextSecondary)
            }
            if palette.tags.isEmpty == false {
                Text(palette.tags.joined(separator: " · "))
                    .font(.caption2)
                    .foregroundStyle(Color.appTextSecondary)
                    .lineLimit(2)
            }
            HStack(spacing: 8) {
                ForEach(palette.colors.prefix(6)) { color in
                    VStack(spacing: 4) {
                        if let norm = HexColorCodec.normalizedHex(from: color.hex),
                           let preview = HexColorCodec.swiftUIColor(fromNormalizedHex: norm) {
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(preview)
                                .frame(height: 36)
                        }
                        Text(color.hex.uppercased())
                            .font(.caption2.monospaced())
                            .foregroundStyle(Color.appTextSecondary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.6)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(.vertical, 6)
    }
}
