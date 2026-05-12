//
//  LayeredBackgroundView.swift
//  172MirevonaDailyspace
//

import SwiftUI

/// Full-screen decorative background: soft depth, warm light pools, line art, subtle grid.
/// Use once at the root (e.g. `ContentView`) so every screen shares the same look.
struct LayeredBackgroundView: View {
    var body: some View {
        GeometryReader { geo in
            let cornerRadius = hypot(geo.size.width, geo.size.height) * 0.72
            ZStack {
                baseAtmosphere
                warmGlowTopTrailing
                accentGlowBottomLeading
                topLightWash
                sheenHighlight
                linePatternOverlay
                dotGridOverlay
                softEdgeDepth(cornerRadius: cornerRadius)
            }
        }
        .ignoresSafeArea()
    }

    /// Softer than a flat fill: lighter toward the top, richer toward corners (no harsh multiply).
    private var baseAtmosphere: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color.appSurface.opacity(0.42),
                    Color.appBackground.opacity(0.92),
                    Color.appBackground,
                    Color.appSurface.opacity(0.28)
                ],
                startPoint: .top,
                endPoint: .bottomTrailing
            )
            LinearGradient(
                colors: [
                    Color.appPrimary.opacity(0.14),
                    Color.clear,
                    Color.appAccent.opacity(0.10)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .blendMode(.softLight)
            .opacity(0.75)
        }
    }

    private var warmGlowTopTrailing: some View {
        RadialGradient(
            colors: [
                Color.appPrimary.opacity(0.32),
                Color.appPrimary.opacity(0.10),
                Color.clear
            ],
            center: UnitPoint(x: 0.92, y: 0.08),
            startRadius: 4,
            endRadius: 340
        )
        .blendMode(.screen)
        .opacity(0.9)
    }

    private var accentGlowBottomLeading: some View {
        RadialGradient(
            colors: [
                Color.appAccent.opacity(0.26),
                Color.appAccent.opacity(0.08),
                Color.clear
            ],
            center: UnitPoint(x: 0.1, y: 0.92),
            startRadius: 2,
            endRadius: 300
        )
        .blendMode(.screen)
        .opacity(0.85)
    }

    /// Keeps the center of the screen from feeling like a “black hole”.
    private var topLightWash: some View {
        RadialGradient(
            colors: [
                Color.appPrimary.opacity(0.12),
                Color.appPrimary.opacity(0.04),
                Color.clear
            ],
            center: UnitPoint(x: 0.5, y: 0.02),
            startRadius: 40,
            endRadius: 380
        )
        .blendMode(.screen)
        .opacity(0.95)
    }

    private var sheenHighlight: some View {
        LinearGradient(
            colors: [
                Color.appTextPrimary.opacity(0.09),
                Color.clear,
                Color.clear
            ],
            startPoint: .top,
            endPoint: .center
        )
        .blendMode(.screen)
        .opacity(0.7)
    }

    private var linePatternOverlay: some View {
        Canvas { context, size in
            let step: CGFloat = 34
            var path = Path()
            var y: CGFloat = -step
            while y < size.height + step * 2 {
                path.move(to: CGPoint(x: 0, y: y))
                path.addLine(to: CGPoint(x: size.width, y: y + step * 0.38))
                y += step
            }
            let stroke = Color.appPrimary.opacity(0.09)
            context.stroke(path, with: .color(stroke), lineWidth: 1)

            var cross = Path()
            let crossStep: CGFloat = 80
            var cx: CGFloat = 0
            while cx < size.width + crossStep {
                cross.move(to: CGPoint(x: cx, y: 0))
                cross.addLine(to: CGPoint(x: cx - size.height * 0.35, y: size.height))
                cx += crossStep
            }
            context.stroke(cross, with: .color(Color.appAccent.opacity(0.055)), lineWidth: 0.8)
        }
        .allowsHitTesting(false)
    }

    private var dotGridOverlay: some View {
        Canvas { context, size in
            let spacing: CGFloat = 26
            let dotR: CGFloat = 1.1
            var y: CGFloat = spacing * 0.5
            while y < size.height {
                var x: CGFloat = spacing * 0.5
                while x < size.width {
                    let rect = CGRect(x: x - dotR, y: y - dotR, width: dotR * 2, height: dotR * 2)
                    context.fill(Path(ellipseIn: rect), with: .color(Color.appTextPrimary.opacity(0.055)))
                    x += spacing
                }
                y += spacing
            }
        }
        .allowsHitTesting(false)
    }

    private func softEdgeDepth(cornerRadius: CGFloat) -> some View {
        ZStack {
            RadialGradient(
                colors: [
                    Color.clear,
                    Color.appBackground.opacity(0.22)
                ],
                center: .center,
                startRadius: cornerRadius * 0.22,
                endRadius: cornerRadius
            )
            .blendMode(.normal)
            LinearGradient(
                colors: [
                    Color.appSurface.opacity(0.18),
                    Color.clear
                ],
                startPoint: .bottom,
                endPoint: .center
            )
            .blendMode(.softLight)
            .opacity(0.5)
        }
        .allowsHitTesting(false)
    }
}
