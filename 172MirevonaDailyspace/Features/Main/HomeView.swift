//
//  HomeView.swift
//  172MirevonaDailyspace
//

import Combine
import SwiftUI

struct HomeView: View {
    @Binding var selectedTab: RootTab
    @EnvironmentObject private var store: AppStorageStore

    private var accentHexes: [String] {
        var seen = Set<String>()
        var out: [String] = []
        for p in store.palettes.prefix(8) {
            for c in p.colors {
                let n = HexColorCodec.normalizedHex(from: c.hex) ?? c.hex
                if seen.insert(n).inserted {
                    out.append(n)
                    if out.count >= 14 { return out }
                }
            }
        }
        for h in store.recentlyUsedColors {
            let n = HexColorCodec.normalizedHex(from: h) ?? h
            if seen.insert(n).inserted {
                out.append(n)
                if out.count >= 14 { return out }
            }
        }
        let fallback = ["FFB347", "FF6B9D", "845EC2", "4E8397", "FFC75F", "F9F871"]
        var i = 0
        while out.count < 6 {
            out.append(fallback[i % fallback.count])
            i += 1
        }
        return out
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    heroHeader
                    visualGalleryStrip
                    quickActionsRow
                    HStack(alignment: .top, spacing: 12) {
                        palettesStatWidget
                        streakWidget
                    }
                    HStack(alignment: .top, spacing: 12) {
                        studioWidget
                        achievementsWidget
                    }
                    if store.palettes.isEmpty == false {
                        recentPalettesStrip
                    }
                    inspirationMosaic
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 28)
            }
            .scrollIndicators(.visible)
            .scrollContentBackground(.hidden)
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.large)
            .transparentAppNavigation()
            .appScreenAtmosphere()
        }
    }

    private var heroHeader: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.appPrimary.opacity(0.45),
                            Color.appSurface.opacity(0.9),
                            Color.appAccent.opacity(0.35)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay {
                    HeroSymbolCollage()
                        .opacity(0.95)
                }
                .frame(height: 200)
                .overlay(alignment: .topTrailing) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.9))
                        .padding(16)
                }

            VStack(alignment: .leading, spacing: 6) {
                Text(greetingLine)
                    .font(.title2.weight(.bold))
                    .foregroundStyle(Color.appTextPrimary)
                Text(Date.now.formatted(.dateTime.weekday(.wide).month(.abbreviated).day()))
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Color.appTextSecondary)
                Text("Your color studio at a glance.")
                    .font(.caption)
                    .foregroundStyle(Color.appTextSecondary.opacity(0.95))
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                LinearGradient(
                    colors: [Color.appBackground.opacity(0.92), Color.clear],
                    startPoint: .bottom,
                    endPoint: .top
                )
                .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
            )
        }
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .strokeBorder(Color.appTextPrimary.opacity(0.12), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.22), radius: 18, x: 0, y: 10)
    }

    private var greetingLine: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5 ..< 12: return "Good morning"
        case 12 ..< 17: return "Good afternoon"
        case 17 ..< 22: return "Good evening"
        default: return "Welcome back"
        }
    }

    private var visualGalleryStrip: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Color moodboard")
                .font(.headline)
                .foregroundStyle(Color.appTextPrimary)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(Array(accentHexes.enumerated()), id: \.offset) { idx, hex in
                        HomeGeneratedArtTile(hex: hex, variant: idx)
                            .frame(width: 96, height: 112)
                    }
                    ForEach(0 ..< 6, id: \.self) { i in
                        gallerySymbolTile(index: i)
                            .frame(width: 88, height: 112)
                    }
                }
                .padding(.vertical, 4)
            }
        }
    }

    private func gallerySymbolTile(index: Int) -> some View {
        let symbols = ["photo.on.rectangle.angled", "camera.filters", "paintbrush.pointed.fill", "square.grid.3x3.fill", "eyedropper.halffull", "wand.and.stars"]
        let symbol = symbols[index % symbols.count]
        return ZStack {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.appSurface.opacity(0.95),
                            Color.appPrimary.opacity(0.25)
                        ],
                        startPoint: .top,
                        endPoint: .bottomTrailing
                    )
                )
            Image(systemName: symbol)
                .font(.system(size: 36, weight: .medium))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(Color.appTextPrimary.opacity(0.85))
        }
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(Color.appTextPrimary.opacity(0.1), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.14), radius: 6, x: 0, y: 3)
    }

    private var quickActionsRow: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Quick actions")
                .font(.headline)
                .foregroundStyle(Color.appTextPrimary)
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                homeActionTile(
                    title: "Palettes",
                    subtitle: "Browse & edit",
                    icon: "paintpalette.fill",
                    tab: .palettes
                )
                homeActionTile(
                    title: "Studio",
                    subtitle: "History & insights",
                    icon: "rectangle.stack.fill",
                    tab: .studio
                )
                homeActionTile(
                    title: "Achievements",
                    subtitle: "Progress & badges",
                    icon: "trophy.fill",
                    tab: .achievements
                )
                homeActionTile(
                    title: "Settings",
                    subtitle: "Privacy & data",
                    icon: "gearshape.fill",
                    tab: .settings
                )
            }
        }
    }

    private func homeActionTile(title: String, subtitle: String, icon: String, tab: RootTab) -> some View {
        Button {
            HapticFeedback.tap()
            selectedTab = tab
        } label: {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [Color.appPrimary.opacity(0.32), Color.appPrimary.opacity(0.14)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    Image(systemName: icon)
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(Color.appPrimary)
                }
                .frame(width: 52, height: 52)
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(Color.appTextPrimary.opacity(0.12), lineWidth: 1)
                )
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(Color.appTextPrimary)
                    Text(subtitle)
                        .font(.caption2)
                        .foregroundStyle(Color.appTextSecondary)
                        .lineLimit(2)
                }
                Spacer(minLength: 0)
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color.appTextSecondary)
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .appSoftLift(cornerRadius: 18)
        }
        .buttonStyle(TapHapticButtonStyle())
    }

    private var palettesStatWidget: some View {
        Button {
            HapticFeedback.tap()
            selectedTab = .palettes
        } label: {
            VStack(alignment: .leading, spacing: 10) {
                Label("Palettes", systemImage: "square.grid.2x2.fill")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color.appTextSecondary)
                Text("\(store.palettes.count)")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.appAccent)
                Text("saved")
                    .font(.caption)
                    .foregroundStyle(Color.appTextSecondary)
                miniSwatchPreview
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .appElevatedCard(cornerRadius: 20)
        }
        .buttonStyle(TapHapticButtonStyle())
    }

    private var miniSwatchPreview: some View {
        HStack(spacing: 4) {
            ForEach(Array(store.palettes.prefix(4))) { p in
                if let hex = p.colors.first.flatMap({ HexColorCodec.normalizedHex(from: $0.hex) }),
                   let c = HexColorCodec.swiftUIColor(fromNormalizedHex: hex) {
                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .fill(c)
                        .frame(width: 18, height: 22)
                }
            }
        }
        .padding(.top, 4)
    }

    private var streakWidget: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Streak", systemImage: "flame.fill")
                .font(.caption.weight(.bold))
                .foregroundStyle(Color.appTextSecondary)
            Text("\(store.streakDays)")
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundStyle(Color.appPrimary)
            Text("day streak")
                .font(.caption)
                .foregroundStyle(Color.appTextSecondary)
            Image(systemName: "sun.max.fill")
                .font(.title)
                .symbolRenderingMode(.palette)
                .foregroundStyle(Color.appAccent, Color.appPrimary.opacity(0.6))
                .padding(.top, 4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .appElevatedCard(cornerRadius: 20)
    }

    private var studioWidget: some View {
        Button {
            HapticFeedback.tap()
            selectedTab = .studio
        } label: {
            VStack(alignment: .leading, spacing: 10) {
                Label("Studio", systemImage: "rectangle.on.rectangle.angled")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color.appTextSecondary)
                Text("History & insights")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.appTextPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                HStack(spacing: 6) {
                    Image(systemName: "clock.arrow.circlepath")
                    Text("\(store.paletteHistory.count) entries")
                }
                .font(.caption2)
                .foregroundStyle(Color.appTextSecondary)
            }
            .frame(maxWidth: .infinity, minHeight: 120, alignment: .leading)
            .padding(16)
            .appElevatedCard(cornerRadius: 20)
        }
        .buttonStyle(TapHapticButtonStyle())
    }

    private var achievementsWidget: some View {
        Button {
            HapticFeedback.tap()
            selectedTab = .achievements
        } label: {
            let unlocked = store.achievementsUnlocked.count
            let total = AchievementCatalog.all.count
            VStack(alignment: .leading, spacing: 10) {
                Label("Achievements", systemImage: "star.circle.fill")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color.appTextSecondary)
                Text("\(unlocked)/\(total)")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.appAccent)
                ProgressView(value: Double(unlocked), total: Double(max(total, 1)))
                    .tint(Color.appPrimary)
                Text("Keep creating to unlock more.")
                    .font(.caption2)
                    .foregroundStyle(Color.appTextSecondary)
            }
            .frame(maxWidth: .infinity, minHeight: 120, alignment: .leading)
            .padding(16)
            .appElevatedCard(cornerRadius: 20)
        }
        .buttonStyle(TapHapticButtonStyle())
    }

    private var recentPalettesStrip: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Recent palettes")
                    .font(.headline)
                    .foregroundStyle(Color.appTextPrimary)
                Spacer()
                Button("See all") {
                    HapticFeedback.tap()
                    selectedTab = .palettes
                }
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color.appPrimary)
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(store.palettes.prefix(8)) { palette in
                        RecentPalettePolaroidCard(palette: palette)
                    }
                }
            }
        }
    }

    private var inspirationMosaic: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Visual inspiration")
                .font(.headline)
                .foregroundStyle(Color.appTextPrimary)
            let columns = [GridItem(.flexible(), spacing: 8), GridItem(.flexible(), spacing: 8), GridItem(.flexible(), spacing: 8)]
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(0 ..< 9, id: \.self) { i in
                    mosaicCell(index: i)
                }
            }
        }
    }

    private func mosaicCell(index: Int) -> some View {
        let icons = ["leaf.fill", "drop.fill", "circle.hexagongrid.fill", "seal.fill", "moon.stars.fill", "cloud.sun.fill", "hare.fill", "bird.fill", "fish.fill"]
        let icon = icons[index % icons.count]
        return ZStack {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.appAccent.opacity(0.15 + Double(index % 3) * 0.06),
                            Color.appSurface.opacity(0.55)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            Image(systemName: icon)
                .font(.title3.weight(.medium))
                .foregroundStyle(Color.appTextPrimary.opacity(0.5 + Double(index % 4) * 0.1))
        }
        .aspectRatio(1, contentMode: .fit)
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .strokeBorder(Color.appTextPrimary.opacity(0.08), lineWidth: 1)
        )
    }
}

// MARK: - Decorative subviews

private struct HeroSymbolCollage: View {
    var body: some View {
        ZStack {
            Image(systemName: "circle.hexagongrid.fill")
                .font(.system(size: 140, weight: .ultraLight))
                .foregroundStyle(Color.appBackground.opacity(0.35))
                .offset(x: 40, y: -30)
            Image(systemName: "paintpalette.fill")
                .font(.system(size: 100, weight: .regular))
                .foregroundStyle(.white.opacity(0.22))
                .offset(x: -50, y: 20)
            Image(systemName: "scribble.variable")
                .font(.system(size: 72, weight: .light))
                .foregroundStyle(Color.appAccent.opacity(0.35))
                .offset(x: 70, y: 50)
        }
        .allowsHitTesting(false)
    }
}

private struct HomeGeneratedArtTile: View {
    let hex: String
    let variant: Int

    var body: some View {
        let norm = HexColorCodec.normalizedHex(from: hex) ?? hex
        let base = HexColorCodec.swiftUIColor(fromNormalizedHex: norm) ?? Color.appPrimary
        ZStack {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [base.opacity(0.5), base.opacity(0.22)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            ForEach(0 ..< 4, id: \.self) { i in
                Circle()
                    .fill(base.opacity(0.35 - Double(i) * 0.06))
                    .frame(width: 26 + CGFloat(i * 6), height: 26 + CGFloat(i * 6))
                    .offset(
                        x: 18 * sin(CGFloat(variant * 3 + i) * 0.7 + CGFloat(i)),
                        y: 22 * cos(CGFloat(variant * 3 + i) * 0.5 + CGFloat(i) * 0.8)
                    )
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(Color.appTextPrimary.opacity(0.12), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.12), radius: 5, x: 0, y: 2)
    }
}

private struct RecentPalettePolaroidCard: View {
    let palette: SavedPalette

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 3) {
                ForEach(palette.colors.prefix(5)) { item in
                    if let n = HexColorCodec.normalizedHex(from: item.hex),
                       let c = HexColorCodec.swiftUIColor(fromNormalizedHex: n) {
                        Rectangle()
                            .fill(c)
                            .frame(width: 22, height: 52)
                    }
                }
            }
            .frame(height: 52)
            .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
            .padding(.horizontal, 10)
            .padding(.top, 10)
            Text(palette.title)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(Color.appBackground.opacity(0.92))
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .frame(width: 120, height: 32, alignment: .top)
                .padding(.bottom, 8)
        }
        .frame(width: 132)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.appTextPrimary.opacity(0.94))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(Color.appTextPrimary.opacity(0.15), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.2), radius: 6, y: 3)
    }
}
