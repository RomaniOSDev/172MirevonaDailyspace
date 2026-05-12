//
//  PaletteEditorSheetView.swift
//  172MirevonaDailyspace
//

import Combine
import SwiftUI

struct PaletteEditorSheetView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var store: AppStorageStore

    private let existing: SavedPalette?
    private let onSaved: () -> Void

    @State private var titleText: String
    @State private var colors: [PaletteColorItem]
    @State private var hexFieldText = ""
    @State private var shakeToken: CGFloat = 0
    @State private var errorMessage: String?

    init(existing: SavedPalette?, onSaved: @escaping () -> Void) {
        self.existing = existing
        self.onSaved = onSaved
        _titleText = State(initialValue: existing?.title ?? "")
        _colors = State(initialValue: existing?.colors ?? [])
    }

    private var presetColors: [Color] {
        [Color.appBackground, Color.appSurface, Color.appPrimary, Color.appAccent, Color.appTextSecondary, Color.appTextPrimary]
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Title")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Color.appTextSecondary)
                        TextField("Palette title", text: $titleText)
                            .textFieldStyle(.plain)
                            .padding(14)
                            .appInsetField(cornerRadius: 14)
                            .foregroundStyle(Color.appTextPrimary)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Quick colors")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Color.appTextSecondary)
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 52), spacing: 12)], spacing: 12) {
                            ForEach(Array(presetColors.enumerated()), id: \.offset) { _, color in
                                Button {
                                    HapticFeedback.tap()
                                    appendPreset(from: color)
                                } label: {
                                    Circle()
                                        .fill(color)
                                        .frame(width: 52, height: 52)
                                        .overlay(
                                            Circle()
                                                .stroke(Color.appTextPrimary.opacity(0.25), lineWidth: 1)
                                        )
                                }
                                .buttonStyle(.plain)
                                .frame(minWidth: 44, minHeight: 44)
                            }
                        }
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Add hex")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Color.appTextSecondary)
                        HStack(spacing: 10) {
                            TextField("#RRGGBB", text: $hexFieldText)
                                .textInputAutocapitalization(.characters)
                                .autocorrectionDisabled()
                                .textFieldStyle(.plain)
                                .padding(14)
                                .appInsetField(cornerRadius: 14)
                                .foregroundStyle(Color.appTextPrimary)
                                .shake(trigger: shakeToken)
                            Button("Add") {
                                HapticFeedback.tap()
                                addFromHexField()
                            }
                            .buttonStyle(PrimaryProminentButtonStyle())
                        }
                        if let errorMessage {
                            Text(errorMessage)
                                .font(.caption)
                                .foregroundStyle(Color.red.opacity(0.85))
                        }
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("Swatches")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(Color.appTextSecondary)
                            Spacer()
                            Button("Add row") {
                                HapticFeedback.tap()
                                colors.append(PaletteColorItem(hex: "FFFFFF", name: "Swatch \(colors.count + 1)"))
                            }
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Color.appPrimary)
                        }
                        ForEach(colors) { item in
                            VStack(alignment: .leading, spacing: 6) {
                                TextField("Name", text: bindingName(for: item.id))
                                    .textFieldStyle(.plain)
                                    .padding(10)
                                    .appInsetField(cornerRadius: 10)
                                    .foregroundStyle(Color.appTextPrimary)
                                TextField("Hex", text: bindingHex(for: item.id))
                                    .textInputAutocapitalization(.characters)
                                    .autocorrectionDisabled()
                                    .textFieldStyle(.plain)
                                    .padding(10)
                                    .appInsetField(cornerRadius: 10)
                                    .foregroundStyle(Color.appTextPrimary)
                                HStack {
                                    if let norm = HexColorCodec.normalizedHex(from: item.hex),
                                       let preview = HexColorCodec.swiftUIColor(fromNormalizedHex: norm) {
                                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                                            .fill(preview)
                                            .frame(width: 44, height: 44)
                                    }
                                    Spacer()
                                    Button(role: .destructive) {
                                        HapticFeedback.tap()
                                        colors.removeAll { $0.id == item.id }
                                    } label: {
                                        Image(systemName: "trash")
                                            .frame(width: 44, height: 44)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(12)
                            .appInsetField(cornerRadius: 14)
                        }
                    }

                    Button {
                        HapticFeedback.tap()
                        savePalette()
                    } label: {
                        Text("Save Palette")
                            .font(.headline)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(PrimaryProminentButtonStyle())
                    .padding(.top, 8)
                }
                .padding(20)
            }
            .scrollContentBackground(.hidden)
            .scrollIndicators(.visible)
            .navigationTitle(existing == nil ? "New Palette" : "Edit Palette")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        HapticFeedback.tap()
                        dismiss()
                    }
                }
            }
        }
        .transparentAppNavigation()
        .background {
            LayeredBackgroundView()
        }
    }

    private func appendPreset(from color: Color) {
        guard let hex = HexColorCodec.normalizedHex(fromSwiftUIColor: color) else { return }
        colors.append(PaletteColorItem(hex: hex, name: "Swatch \(colors.count + 1)"))
        errorMessage = nil
    }

    private func addFromHexField() {
        guard let normalized = HexColorCodec.normalizedHex(from: hexFieldText) else {
            triggerInvalid()
            return
        }
        colors.append(PaletteColorItem(hex: normalized, name: "Swatch \(colors.count + 1)"))
        hexFieldText = ""
        errorMessage = nil
    }

    private func triggerInvalid() {
        HapticFeedback.warning()
        withAnimation(.easeInOut(duration: 0.18)) {
            shakeToken += 1
        }
        errorMessage = "Enter a valid hex value like #FFB700 or FFB700."
    }

    private func savePalette() {
        guard colors.isEmpty == false else {
            HapticFeedback.warning()
            errorMessage = "Add at least one color swatch."
            return
        }
        let normalizedItems = colors.compactMap { item -> PaletteColorItem? in
            guard let hex = HexColorCodec.normalizedHex(from: item.hex) else { return nil }
            return PaletteColorItem(id: item.id, hex: hex, name: item.name)
        }
        guard normalizedItems.count == colors.count else {
            triggerInvalid()
            errorMessage = "Each swatch needs a valid hex code."
            return
        }
        let trimmedTitle = titleText.trimmingCharacters(in: .whitespacesAndNewlines)
        let finalTitle = trimmedTitle.isEmpty ? "Untitled Palette" : trimmedTitle
        if let existing {
            var updated = existing
            updated.title = finalTitle
            updated.colors = normalizedItems
            store.updatePalette(updated)
            store.recordSessionCompleted()
        } else {
            store.addPalette(title: finalTitle, colors: normalizedItems, recordSession: true)
        }
        HapticFeedback.actionComplete()
        SystemSound.play(1104)
        onSaved()
        dismiss()
    }

    private func bindingName(for id: UUID) -> Binding<String> {
        Binding(
            get: { colors.first(where: { $0.id == id })?.name ?? "" },
            set: { newValue in
                guard let idx = colors.firstIndex(where: { $0.id == id }) else { return }
                colors[idx].name = newValue
            }
        )
    }

    private func bindingHex(for id: UUID) -> Binding<String> {
        Binding(
            get: { colors.first(where: { $0.id == id })?.hex ?? "" },
            set: { newValue in
                guard let idx = colors.firstIndex(where: { $0.id == id }) else { return }
                colors[idx].hex = newValue
            }
        )
    }
}