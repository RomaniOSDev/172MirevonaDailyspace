//
//  OnboardingView.swift
//  172MirevonaDailyspace
//

import Combine
import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject private var store: AppStorageStore
    @StateObject private var viewModel = OnboardingViewModel()
    @State private var appearAnimation = false

    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $viewModel.pageIndex) {
                onboardingPage(
                    headline: "Create Palettes",
                    message: "Build palettes with swatches, folders, and tags—then refine them anytime.",
                    illustration: { SwatchBurstIllustration() },
                    tag: 0
                )
                onboardingPage(
                    headline: "Studio & History",
                    message: "Browse history, insights, and snapshots so your colors stay organized.",
                    illustration: { SparkGridIllustration() },
                    tag: 1
                )
                onboardingPage(
                    headline: "You’re Ready",
                    message: "Jump into Home for a quick overview, or open Palettes to create your first masterpiece.",
                    illustration: { RibbonCircleIllustration() },
                    tag: 2
                )
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut(duration: 0.3), value: viewModel.pageIndex)

            bottomChrome
        }
        .onAppear {
            withAnimation(.spring(response: 0.45, dampingFraction: 0.75)) {
                appearAnimation = true
            }
        }
        .onChange(of: viewModel.pageIndex) { _ in
            appearAnimation = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                withAnimation(.spring(response: 0.45, dampingFraction: 0.75)) {
                    appearAnimation = true
                }
            }
        }
    }

    private var bottomChrome: some View {
        VStack(spacing: 16) {
            pageDots
            stepLabel
            actionButton
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 18)
        .appElevatedCard(cornerRadius: 24, shadowRadius: 14, shadowY: 8)
        .padding(.horizontal, 16)
        .padding(.bottom, 24)
    }

    private var stepLabel: some View {
        Text("Step \(viewModel.pageIndex + 1) of \(viewModel.totalPages)")
            .font(.caption.weight(.semibold))
            .foregroundStyle(Color.appTextSecondary)
    }

    private var pageDots: some View {
        HStack(spacing: 10) {
            ForEach(0 ..< viewModel.totalPages, id: \.self) { idx in
                Capsule()
                    .fill(
                        idx == viewModel.pageIndex
                            ? LinearGradient(
                                colors: [Color.appAccent, Color.appPrimary.opacity(0.85)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                            : LinearGradient(
                                colors: [
                                    Color.appTextSecondary.opacity(0.25),
                                    Color.appTextSecondary.opacity(0.15)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                    )
                    .frame(width: idx == viewModel.pageIndex ? 28 : 8, height: 8)
                    .overlay {
                        Capsule()
                            .strokeBorder(Color.appTextPrimary.opacity(idx == viewModel.pageIndex ? 0.12 : 0.06), lineWidth: 1)
                    }
                    .animation(.spring(response: 0.4, dampingFraction: 0.72), value: viewModel.pageIndex)
            }
        }
    }

    private var actionButton: some View {
        Button {
            HapticFeedback.tap()
            if viewModel.pageIndex < viewModel.totalPages - 1 {
                withAnimation(.easeInOut(duration: 0.3)) {
                    viewModel.next()
                }
            } else {
                HapticFeedback.actionComplete()
                store.finishOnboarding()
            }
        } label: {
            Text(viewModel.pageIndex == viewModel.totalPages - 1 ? "Get Started" : "Next")
                .font(.headline)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(PrimaryProminentButtonStyle())
    }

    private func onboardingPage(
        headline: String,
        message: String,
        @ViewBuilder illustration: @escaping () -> some View,
        tag: Int
    ) -> some View {
        ScrollView {
            VStack(spacing: 20) {
                illustrationStage(illustration: illustration)

                VStack(spacing: 14) {
                    Text(headline)
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.appTextPrimary)
                        .multilineTextAlignment(.center)
                        .minimumScaleFactor(0.85)

                    Text(message)
                        .font(.body)
                        .foregroundStyle(Color.appTextSecondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(3)
                        .padding(.horizontal, 6)
                }
            }
            .padding(.vertical, 20)
            .padding(.horizontal, 8)
            .appElevatedCard(cornerRadius: 26, shadowRadius: 14, shadowY: 8)
            .padding(.horizontal, 14)
            .padding(.top, 16)
            .padding(.bottom, 12)
        }
        .scrollContentBackground(.hidden)
        .scrollIndicators(.hidden)
        .tag(tag)
    }

    private func illustrationStage(@ViewBuilder illustration: @escaping () -> some View) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.appPrimary.opacity(0.22),
                            Color.appSurface.opacity(0.55),
                            Color.appAccent.opacity(0.18)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay {
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .strokeBorder(
                            LinearGradient(
                                colors: [
                                    Color.appTextPrimary.opacity(0.14),
                                    Color.appTextPrimary.opacity(0.05)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                }
            illustration()
                .frame(height: 220)
                .scaleEffect(appearAnimation ? 1 : 0.72)
                .opacity(appearAnimation ? 1 : 0)
                .animation(.spring(response: 0.48, dampingFraction: 0.74), value: appearAnimation)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 248)
        .padding(.top, 8)
    }
}

// MARK: - Illustrations (lightweight shapes, no Canvas)

private struct SwatchBurstIllustration: View {
    var body: some View {
        ZStack {
            ForEach(0 ..< 6, id: \.self) { idx in
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.appPrimary.opacity(0.45 + Double(idx) * 0.04),
                                Color.appAccent.opacity(0.25 + Double(idx % 3) * 0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 68, height: 68)
                    .overlay {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .strokeBorder(Color.appTextPrimary.opacity(0.12), lineWidth: 1)
                    }
                    .rotationEffect(.degrees(Double(idx) * 16))
                    .offset(x: CGFloat(idx) * 5 - 14, y: CGFloat(idx % 3) * 8 - 8)
            }
            Image(systemName: "paintbrush.pointed.fill")
                .font(.system(size: 52, weight: .semibold))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.appAccent, Color.appPrimary],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: Color.black.opacity(0.18), radius: 6, y: 3)
        }
    }
}

private struct SparkGridIllustration: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color.appSurface.opacity(0.35))
                .frame(width: 236, height: 168)
                .overlay {
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .strokeBorder(Color.appAccent.opacity(0.35), lineWidth: 1.5)
                }
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                ForEach(0 ..< 6, id: \.self) { idx in
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: idx % 2 == 0
                                        ? [Color.appPrimary.opacity(0.85), Color.appPrimary.opacity(0.45)]
                                        : [Color.appSurface.opacity(0.95), Color.appSurface.opacity(0.55)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 40, height: 40)
                            .overlay {
                                Circle()
                                    .strokeBorder(Color.appTextPrimary.opacity(0.1), lineWidth: 1)
                            }
                        Image(systemName: "sparkles")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Color.appTextPrimary.opacity(0.85))
                    }
                }
            }
            .padding(.horizontal, 36)
        }
    }
}

private struct RibbonCircleIllustration: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.appAccent.opacity(0.35),
                            Color.appSurface.opacity(0.25),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 20,
                        endRadius: 100
                    )
                )
                .frame(width: 176, height: 176)
            Circle()
                .strokeBorder(
                    AngularGradient(
                        colors: [
                            Color.appPrimary,
                            Color.appAccent,
                            Color.appPrimary.opacity(0.6),
                            Color.appPrimary
                        ],
                        center: .center
                    ),
                    lineWidth: 5
                )
                .frame(width: 168, height: 168)
            Path { path in
                path.move(to: CGPoint(x: 44, y: 118))
                path.addQuadCurve(to: CGPoint(x: 198, y: 42), control: CGPoint(x: 132, y: 148))
            }
            .stroke(
                LinearGradient(
                    colors: [Color.appPrimary.opacity(0.9), Color.appAccent.opacity(0.85)],
                    startPoint: .leading,
                    endPoint: .trailing
                ),
                style: StrokeStyle(lineWidth: 4, lineCap: .round)
            )
            Image(systemName: "hand.tap.fill")
                .font(.system(size: 42, weight: .medium))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.appTextPrimary, Color.appTextSecondary],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .offset(y: 20)
        }
    }
}
