//
//  PaletteHistoryView.swift
//  172MirevonaDailyspace
//

import Combine
import SwiftUI

struct PaletteHistoryView: View {
    @EnvironmentObject private var store: AppStorageStore
    @StateObject private var viewModel = PaletteHistoryViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                if store.paletteHistory.isEmpty {
                    ScrollView {
                        emptyState
                            .padding(.vertical, 48)
                    }
                    .scrollContentBackground(.hidden)
                } else {
                    List {
                        ForEach(viewModel.filtered(from: store.paletteHistory)) { palette in
                            NavigationLink(value: palette) {
                                HistoryRow(palette: palette, isSelected: store.lastSelectedPaletteId == palette.id)
                            }
                            .listRowBackground(ListRowChromeBackground(cornerRadius: 12))
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(role: .destructive) {
                                    HapticFeedback.tap()
                                    store.deleteHistoryEntry(id: palette.id)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                                Button {
                                    HapticFeedback.tap()
                                    store.selectPalette(id: palette.id)
                                    viewModel.editorPalette = palette
                                } label: {
                                    Label("Edit", systemImage: "pencil")
                                }
                                .tint(Color.appPrimary)
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                    .scrollContentBackground(.hidden)
                    .searchable(text: $viewModel.searchText, prompt: Text("Search by name or hex"))
                }
            }
            .navigationTitle("Palette History")
            .navigationDestination(for: SavedPalette.self) { palette in
                PaletteHistoryDetailView(palette: palette)
                    .onAppear {
                        store.selectPalette(id: palette.id)
                    }
            }
            .safeAreaInset(edge: .bottom, spacing: 0) {
                restoreBar
            }
            .sheet(item: $viewModel.editorPalette) { palette in
                PaletteEditorSheetView(existing: palette) {
                    HapticFeedback.actionComplete()
                    SystemSound.play(1057)
                }
                .environmentObject(store)
                .appPresentationChrome()
            }
            .transparentAppNavigation()
            .appScreenAtmosphere()
        }
    }

    private var restoreBar: some View {
        VStack(spacing: 0) {
            Button {
                HapticFeedback.tap()
                store.restoreSelectedPalette()
                triggerRestoreSuccess()
            } label: {
                Text("Restore")
                    .font(.headline)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(PrimaryProminentButtonStyle())
            .disabled(store.lastSelectedPaletteId == nil)
            .opacity(store.lastSelectedPaletteId == nil ? 0.45 : 1)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .appElevatedCard(cornerRadius: 22, shadowRadius: 10, shadowY: 5)
            .padding(.horizontal, 8)
        }
    }

    private func triggerRestoreSuccess() {
        HapticFeedback.actionComplete()
        SystemSound.play(1102)
        withAnimation(.easeInOut(duration: 0.35)) {
            viewModel.restorePulse = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            withAnimation(.easeOut(duration: 0.45)) {
                viewModel.restorePulse = false
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 18) {
            Image(systemName: "paintpalette.fill")
                .font(.system(size: 64))
                .foregroundStyle(Color.appPrimary)
            Text("No palettes yet, create your first masterpiece!")
                .font(.headline)
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.appTextPrimary)
                .padding(.horizontal, 24)
        }
        .frame(maxWidth: .infinity)
    }
}

private struct HistoryRow: View {
    let palette: SavedPalette
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color.appSurface.opacity(0.95), Color.appSurface.opacity(0.62)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .strokeBorder(Color.appTextPrimary.opacity(0.1), lineWidth: 1)
                }
                .frame(width: 72, height: 72)
                .overlay {
                    HStack(spacing: 3) {
                        ForEach(palette.colors.prefix(4)) { color in
                            if let norm = HexColorCodec.normalizedHex(from: color.hex),
                               let preview = HexColorCodec.swiftUIColor(fromNormalizedHex: norm) {
                                preview
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                            }
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    .padding(6)
                }
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    Text(palette.title)
                        .font(.headline)
                        .foregroundStyle(Color.appTextPrimary)
                    if palette.isFavorite {
                        Image(systemName: "heart.fill")
                            .font(.caption)
                            .foregroundStyle(Color.appAccent)
                    }
                }
                Text(palette.createdAt.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundStyle(Color.appTextSecondary)
                let folder = palette.folder.trimmingCharacters(in: .whitespacesAndNewlines)
                if folder.isEmpty == false {
                    Text(folder)
                        .font(.caption2)
                        .foregroundStyle(Color.appTextSecondary)
                }
                if palette.tags.isEmpty == false {
                    Text(palette.tags.joined(separator: " · "))
                        .font(.caption2)
                        .foregroundStyle(Color.appTextSecondary)
                        .lineLimit(1)
                }
            }
            Spacer()
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(Color.appAccent)
            }
        }
        .padding(.vertical, 4)
    }
}

struct PaletteHistoryDetailView: View {
    let palette: SavedPalette

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(palette.title)
                    .font(.title2.bold())
                    .foregroundStyle(Color.appTextPrimary)
                Text(palette.createdAt.formatted(date: .long, time: .shortened))
                    .font(.subheadline)
                    .foregroundStyle(Color.appTextSecondary)
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 120), spacing: 12)], spacing: 12) {
                    ForEach(palette.colors) { color in
                        VStack(alignment: .leading, spacing: 8) {
                            if let norm = HexColorCodec.normalizedHex(from: color.hex),
                               let preview = HexColorCodec.swiftUIColor(fromNormalizedHex: norm) {
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(preview)
                                    .frame(height: 90)
                            }
                            Text(color.name)
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(Color.appTextPrimary)
                            Text(color.hex.uppercased())
                                .font(.caption2.monospaced())
                                .foregroundStyle(Color.appTextSecondary)
                        }
                        .padding(10)
                        .background(Color.appSurface.opacity(0.75))
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }
                }
            }
            .padding(20)
        }
        .scrollContentBackground(.hidden)
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
        .transparentAppNavigation()
    }
}
