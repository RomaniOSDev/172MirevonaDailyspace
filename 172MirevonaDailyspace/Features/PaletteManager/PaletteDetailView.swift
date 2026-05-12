//
//  PaletteDetailView.swift
//  172MirevonaDailyspace
//

import Combine
import SwiftUI

struct PaletteDetailView: View {
    @EnvironmentObject private var store: AppStorageStore
    @State private var draft: SavedPalette
    @State private var pendingRestoreSnapshotId: UUID?

    init(palette: SavedPalette) {
        _draft = State(initialValue: palette)
    }

    var body: some View {
        List {
            Section {
                TextField("Title", text: $draft.title)
                    .foregroundStyle(Color.appTextPrimary)
            } header: {
                Text("Details")
                    .foregroundStyle(Color.appTextSecondary)
            }

            Section {
                TextField("Folder (optional)", text: $draft.folder)
                    .foregroundStyle(Color.appTextPrimary)
                TextField("Tags (comma separated)", text: tagsField)
                    .foregroundStyle(Color.appTextPrimary)
                Toggle(
                    "Favorite",
                    isOn: Binding(
                        get: { draft.isFavorite },
                        set: { newValue in
                            store.setPaletteFavorite(id: draft.id, isFavorite: newValue)
                            draft.isFavorite = newValue
                        }
                    )
                )
                .tint(Color.appAccent)
            } header: {
                Text("Organization")
                    .foregroundStyle(Color.appTextSecondary)
            } footer: {
                Text("Folders group palettes in My Palettes filters. Tags help search here and in History.")
                    .foregroundStyle(Color.appTextSecondary)
            }

            Section {
                Button {
                    HapticFeedback.tap()
                    store.savePaletteSnapshot(paletteId: draft.id, title: draft.title, colors: draft.colors)
                    syncDraftFromStore()
                    HapticFeedback.actionComplete()
                } label: {
                    Label("Save snapshot of current swatches", systemImage: "arrow.down.doc")
                }
                Button {
                    HapticFeedback.tap()
                    store.duplicatePalette(from: draft)
                    HapticFeedback.actionComplete()
                } label: {
                    Label("Duplicate palette", systemImage: "doc.on.doc")
                }
            } header: {
                Text("Actions")
                    .foregroundStyle(Color.appTextSecondary)
            } footer: {
                Text("Snapshots keep a recoverable copy on this device. Duplicates appear at the top of My Palettes.")
                    .foregroundStyle(Color.appTextSecondary)
            }

            if draft.versions.isEmpty == false {
                Section {
                    ForEach(draft.versions) { snap in
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text(snap.title)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(Color.appTextPrimary)
                                Spacer()
                                Button("Restore") {
                                    HapticFeedback.tap()
                                    pendingRestoreSnapshotId = snap.id
                                }
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(Color.appPrimary)
                            }
                            Text(snap.createdAt.formatted(date: .abbreviated, time: .shortened))
                                .font(.caption)
                                .foregroundStyle(Color.appTextSecondary)
                            Text("\(snap.colors.count) swatches")
                                .font(.caption2)
                                .foregroundStyle(Color.appTextSecondary)
                        }
                        .padding(.vertical, 4)
                    }
                } header: {
                    Text("Snapshots")
                        .foregroundStyle(Color.appTextSecondary)
                }
            }

            Section {
                ForEach(draft.colors) { item in
                    HStack(spacing: 12) {
                        if let norm = HexColorCodec.normalizedHex(from: item.hex),
                           let preview = HexColorCodec.swiftUIColor(fromNormalizedHex: norm) {
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(preview)
                                .frame(width: 44, height: 44)
                        }
                        VStack(alignment: .leading, spacing: 6) {
                            TextField("Name", text: bindingName(for: item.id))
                                .foregroundStyle(Color.appTextPrimary)
                            TextField("Hex", text: bindingHex(for: item.id))
                                .textInputAutocapitalization(.characters)
                                .autocorrectionDisabled()
                                .foregroundStyle(Color.appTextSecondary)
                            Text(item.hex.uppercased())
                                .font(.caption2.monospaced())
                                .foregroundStyle(Color.appTextSecondary)
                        }
                    }
                    .listRowBackground(ListRowChromeBackground(cornerRadius: 12))
                }
                .onMove(perform: move)
            } header: {
                Text("Swatches (drag to reorder)")
                    .foregroundStyle(Color.appTextSecondary)
            }
        }
        .scrollContentBackground(.hidden)
        .listStyle(.insetGrouped)
        .navigationTitle("Edit Palette")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                EditButton()
                    .foregroundStyle(Color.appPrimary)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    store.updatePalette(draft)
                    store.recordSessionCompleted()
                    store.aggregatedSuccessPing()
                }
                .font(.body.weight(.semibold))
                .foregroundStyle(Color.appPrimary)
            }
        }
        .onAppear {
            syncDraftFromStore()
        }
        .onReceive(NotificationCenter.default.publisher(for: .dataReset)) { _ in
            syncDraftFromStore()
        }
        .alert(
            "Restore snapshot?",
            isPresented: Binding(
                get: { pendingRestoreSnapshotId != nil },
                set: { if !$0 { pendingRestoreSnapshotId = nil } }
            )
        ) {
            Button("Cancel", role: .cancel) {
                pendingRestoreSnapshotId = nil
            }
            Button("Restore", role: .destructive) {
                if let sid = pendingRestoreSnapshotId {
                    store.restorePaletteFromSnapshot(paletteId: draft.id, snapshotId: sid)
                    syncDraftFromStore()
                    HapticFeedback.actionComplete()
                }
                pendingRestoreSnapshotId = nil
            }
        } message: {
            Text("This replaces the current title and swatches. Save a new snapshot first if you want to keep today’s version.")
        }
        .transparentAppNavigation()
    }

    private var tagsField: Binding<String> {
        Binding(
            get: { draft.tags.joined(separator: ", ") },
            set: { draft.tags = Self.normalizedTagList(from: $0) }
        )
    }

    private static func normalizedTagList(from raw: String) -> [String] {
        raw.split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { $0.isEmpty == false }
    }

    private func syncDraftFromStore() {
        if let latest = store.palettes.first(where: { $0.id == draft.id }) {
            draft = latest
        }
    }

    private func move(from source: IndexSet, to destination: Int) {
        HapticFeedback.tap()
        draft.colors.move(fromOffsets: source, toOffset: destination)
    }

    private func bindingName(for id: UUID) -> Binding<String> {
        Binding(
            get: { draft.colors.first(where: { $0.id == id })?.name ?? "" },
            set: { newValue in
                guard let idx = draft.colors.firstIndex(where: { $0.id == id }) else { return }
                draft.colors[idx].name = newValue
            }
        )
    }

    private func bindingHex(for id: UUID) -> Binding<String> {
        Binding(
            get: { draft.colors.first(where: { $0.id == id })?.hex ?? "" },
            set: { newValue in
                guard let idx = draft.colors.firstIndex(where: { $0.id == id }) else { return }
                draft.colors[idx].hex = newValue
            }
        )
    }
}
