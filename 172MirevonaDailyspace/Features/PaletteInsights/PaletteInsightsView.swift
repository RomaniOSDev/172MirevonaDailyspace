//
//  PaletteInsightsView.swift
//  172MirevonaDailyspace
//

import Combine
import SwiftUI

struct PaletteInsightsView: View {
    @EnvironmentObject private var store: AppStorageStore
    @StateObject private var viewModel = PaletteInsightsViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("", selection: $viewModel.segment) {
                    ForEach(InsightsSegment.allCases) { item in
                        Text(item.title).tag(item)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [Color.appSurface.opacity(0.92), Color.appSurface.opacity(0.62)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay {
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .strokeBorder(Color.appTextPrimary.opacity(0.1), lineWidth: 1)
                        }
                        .shadow(color: Color.black.opacity(0.12), radius: 6, x: 0, y: 3)
                }
                .padding(.horizontal, 12)
                .padding(.top, 6)

                Group {
                    if viewModel.segment == .history {
                        historyList
                    } else {
                        ScrollView {
                            VStack(spacing: 18) {
                                switch viewModel.segment {
                                case .summary:
                                    summarySection
                                case .trends:
                                    trendsSection
                                case .history:
                                    EmptyView()
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .animation(.easeInOut(duration: 0.3), value: viewModel.segment)
                        }
                        .scrollContentBackground(.hidden)
                        .scrollIndicators(.visible)
                    }
                }

                Button {
                    HapticFeedback.tap()
                    viewModel.showComposer = true
                } label: {
                    Text("Create New Palette")
                        .font(.headline)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(PrimaryProminentButtonStyle())
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .appElevatedCard(cornerRadius: 20, shadowRadius: 8, shadowY: 4)
                .padding(.horizontal, 10)
                .padding(.bottom, 4)
        }
            .navigationTitle("Palette Insights")
            .navigationDestination(for: SavedPalette.self) { palette in
                PaletteHistoryDetailView(palette: palette)
            }
            .sheet(isPresented: $viewModel.showComposer) {
                PaletteEditorSheetView(existing: nil) {
                    HapticFeedback.actionComplete()
                    SystemSound.vibrate()
                    withAnimation(.spring(response: 0.45, dampingFraction: 0.75)) {
                        viewModel.chartPulse.toggle()
                    }
                }
                .environmentObject(store)
                .appPresentationChrome()
            }
            .onChange(of: viewModel.segment) { newValue in
                if newValue == .trends {
                    store.recordTrendInsightsView()
                    HapticFeedback.actionComplete()
                    SystemSound.vibrate()
                    withAnimation(.spring(response: 0.45, dampingFraction: 0.75)) {
                        viewModel.chartPulse.toggle()
                    }
                }
            }
            .transparentAppNavigation()
            .appScreenAtmosphere()
        }
    }

    private var historyList: some View {
        let items = store.paletteHistory.sorted { $0.createdAt > $1.createdAt }
        return Group {
            if items.isEmpty {
                ScrollView {
                    emptyInsightsCard(
                        title: "No Data Available",
                        subtitle: "Start creating your first palette!",
                        symbol: "paintpalette.fill"
                    )
                    .padding(16)
                }
                .scrollContentBackground(.hidden)
            } else {
                List {
                    Section {
                        ForEach(items) { palette in
                            NavigationLink(value: palette) {
                                HistoryInsightRow(palette: palette)
                            }
                            .listRowBackground(ListRowChromeBackground(cornerRadius: 12))
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    HapticFeedback.tap()
                                    store.deleteHistoryEntry(id: palette.id)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    } header: {
                        Text("Recent palettes")
                            .foregroundStyle(Color.appTextSecondary)
                    }
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
            }
        }
    }

    private var summarySection: some View {
        VStack(alignment: .leading, spacing: 14) {
            if store.palettes.isEmpty == false {
                organizationInsightsCard
            }
            let counts = store.colorUsageCounts()
            if counts.isEmpty {
                emptyInsightsCard(
                    title: "No Data Available",
                    subtitle: "Start creating your first palette!",
                    symbol: "paintpalette.fill"
                )
            } else {
                Text("Color usage")
                    .font(.headline)
                    .foregroundStyle(Color.appTextPrimary)
                DonutChartView(entries: counts, pulse: viewModel.chartPulse)
                    .frame(height: 260)
                    .padding()
                    .appElevatedCard(cornerRadius: 20)
                favoriteCard
            }
        }
    }

    private var organizationInsightsCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Library organization")
                .font(.headline)
                .foregroundStyle(Color.appTextPrimary)
            HStack(spacing: 10) {
                insightPill(title: "Favorites", value: store.favoritePaletteCount, symbol: "heart.fill")
                insightPill(title: "Tagged", value: store.palettesWithTagsCount, symbol: "tag.fill")
                insightPill(title: "Snapshots", value: store.snapshotsCreatedCount, symbol: "arrow.down.doc")
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .appElevatedCard(cornerRadius: 20)
    }

    private func insightPill(title: String, value: Int, symbol: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Label(title, systemImage: symbol)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(Color.appTextSecondary)
            Text("\(value)")
                .font(.title3.bold())
                .foregroundStyle(Color.appAccent)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color.appSurface.opacity(0.55), Color.appSurface.opacity(0.35)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(Color.appTextPrimary.opacity(0.08), lineWidth: 1)
                }
        }
    }

    private var trendsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            let aggregated = trendAggregates()
            if aggregated.isEmpty {
                emptyInsightsCard(
                    title: "No Data Available",
                    subtitle: "Start creating your first palette!",
                    symbol: "paintpalette.fill"
                )
            } else {
                Text("Popular colors")
                    .font(.headline)
                    .foregroundStyle(Color.appTextPrimary)
                HorizontalBarChartView(entries: aggregated, pulse: viewModel.chartPulse)
                    .frame(height: min(CGFloat(aggregated.count) * 44 + 40, 360))
                    .padding()
                    .appElevatedCard(cornerRadius: 20)
            }
        }
    }

    private var favoriteCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Favorite color")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.appTextSecondary)
            HStack(spacing: 12) {
                if let norm = HexColorCodec.normalizedHex(from: store.favoriteColorHex),
                   let preview = HexColorCodec.swiftUIColor(fromNormalizedHex: norm) {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(preview)
                        .frame(width: 54, height: 54)
                }
                Text("#\(store.favoriteColorHex.uppercased())")
                    .font(.title3.monospaced())
                    .foregroundStyle(Color.appTextPrimary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .appElevatedCard(cornerRadius: 20)
    }

    private func trendAggregates() -> [(hex: String, count: Int)] {
        var dict: [String: Int] = [:]
        for trend in store.trendingColors {
            let key = HexColorCodec.normalizedHex(from: trend.colorHex) ?? trend.colorHex
            dict[key, default: 0] += 1
        }
        return Array(dict.map { ($0.key, $0.value) }.sorted { $0.count > $1.count }.prefix(8))
    }

    private func emptyInsightsCard(title: String, subtitle: String, symbol: String) -> some View {
        VStack(spacing: 14) {
            PastelBadgeIllustration()
                .frame(height: 120)
            Text(title)
                .font(.title3.bold())
                .foregroundStyle(Color.appTextPrimary)
            Label(subtitle, systemImage: symbol)
                .font(.subheadline)
                .foregroundStyle(Color.appTextSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .appElevatedCard(cornerRadius: 20)
    }
}

private struct PastelBadgeIllustration: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.appPrimary.opacity(0.25))
                .frame(width: 160, height: 110)
                .rotationEffect(.degrees(-6))
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.appAccent.opacity(0.35))
                .frame(width: 150, height: 100)
                .rotationEffect(.degrees(8))
        }
    }
}

private struct HistoryInsightRow: View {
    let palette: SavedPalette

    var body: some View {
        HStack {
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
            Image(systemName: "chevron.right")
                .foregroundStyle(Color.appTextSecondary)
        }
        .padding(.vertical, 4)
    }
}

private struct DonutChartView: View {
    let entries: [(hex: String, count: Int)]
    let pulse: Bool

    var body: some View {
        Canvas { context, size in
            let total = entries.reduce(0) { $0 + $1.count }
            guard total > 0 else { return }
            let lineWidth = min(size.width, size.height) * 0.18
            let radius = min(size.width, size.height) / 2 - lineWidth / 2
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            var start = Angle.degrees(-90)
            for entry in entries {
                let sweep = Angle.degrees(360 * Double(entry.count) / Double(total))
                var path = Path()
                path.addArc(center: center, radius: radius, startAngle: start, endAngle: start + sweep, clockwise: false)
                start += sweep
                let norm = HexColorCodec.normalizedHex(from: entry.hex) ?? entry.hex
                let strokeColor: Color = {
                    if let ui = HexColorCodec.uiColor(fromNormalizedHex: norm) {
                        return Color(uiColor: ui)
                    }
                    return Color.appAccent
                }()
                context.stroke(path, with: .color(strokeColor), style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
            }
        }
        .scaleEffect(pulse ? 1.03 : 1)
        .animation(.spring(response: 0.45, dampingFraction: 0.75), value: pulse)
    }
}

private struct HorizontalBarChartView: View {
    let entries: [(hex: String, count: Int)]
    let pulse: Bool

    var body: some View {
        let maxValue = max(entries.map(\.count).max() ?? 1, 1)
        Canvas { context, size in
            let rowHeight = size.height / CGFloat(max(entries.count, 1))
            for (idx, entry) in entries.enumerated() {
                let y = CGFloat(idx) * rowHeight + rowHeight * 0.2
                let barWidth = CGFloat(entry.count) / CGFloat(maxValue) * (size.width - 80)
                let rect = CGRect(x: 70, y: y, width: max(barWidth, 6), height: rowHeight * 0.55)
                let norm = HexColorCodec.normalizedHex(from: entry.hex) ?? entry.hex
                let fill: Color = {
                    if let ui = HexColorCodec.uiColor(fromNormalizedHex: norm) {
                        return Color(uiColor: ui)
                    }
                    return Color.appPrimary
                }()
                context.fill(Path(roundedRect: rect, cornerRadius: 6), with: .color(fill.opacity(0.85)))
            }
        }
        .scaleEffect(pulse ? 1.02 : 1)
        .animation(.spring(response: 0.45, dampingFraction: 0.75), value: pulse)
    }
}
