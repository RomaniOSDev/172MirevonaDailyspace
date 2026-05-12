//
//  SettingsView.swift
//  172MirevonaDailyspace
//

import Combine
import StoreKit
import SwiftUI
import UIKit

struct SettingsView: View {
    @EnvironmentObject private var store: AppStorageStore
    @StateObject private var viewModel = SettingsViewModel()

    private var versionString: String {
        let value = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        return value ?? "1.0"
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Stats")
                            .font(.headline)
                            .foregroundStyle(Color.appTextPrimary)
                        HStack {
                            statColumn(title: "Entries", value: "\(store.itemsCreated)")
                            statColumn(title: "Minutes", value: "\(store.totalMinutesUsed)")
                            statColumn(title: "Streak", value: "\(store.streakDays) days")
                        }
                    }
                    .padding(.vertical, 6)
                    .listRowBackground(ListRowChromeBackground(cornerRadius: 12))
                }

                Section {
                    Button {
                        HapticFeedback.tap()
                        rateApp()
                    } label: {
                        settingsRowLabel(title: "Rate Us", systemImage: "star.fill")
                    }
                    .listRowBackground(ListRowChromeBackground(cornerRadius: 12))

                    Button {
                        HapticFeedback.tap()
                        openPolicyURL()
                    } label: {
                        settingsRowLabel(title: "Privacy Policy", systemImage: "hand.raised.fill")
                    }
                    .listRowBackground(ListRowChromeBackground(cornerRadius: 12))

                    Button {
                        HapticFeedback.tap()
                        openTermsURL()
                    } label: {
                        settingsRowLabel(title: "Terms of Use", systemImage: "doc.text.fill")
                    }
                    .listRowBackground(ListRowChromeBackground(cornerRadius: 12))
                } header: {
                    Text("App")
                        .foregroundStyle(Color.appTextSecondary)
                }

                Section {
                    Button {
                        HapticFeedback.tap()
                        openSupportEmail()
                    } label: {
                        HStack {
                            Text("Support")
                                .foregroundStyle(Color.appTextPrimary)
                            Spacer()
                            Image(systemName: "envelope")
                                .foregroundStyle(Color.appTextSecondary)
                        }
                        .contentShape(Rectangle())
                    }
                    .listRowBackground(ListRowChromeBackground(cornerRadius: 12))

                    Button(role: .destructive) {
                        HapticFeedback.tap()
                        viewModel.showResetAlert = true
                    } label: {
                        Text("Reset All Data")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .listRowBackground(ListRowChromeBackground(cornerRadius: 12))
                } header: {
                    Text("Data")
                        .foregroundStyle(Color.appTextSecondary)
                }

                Section {
                    Text("Version \(versionString)")
                        .font(.footnote)
                        .foregroundStyle(Color.appTextSecondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .listRowBackground(Color.clear)
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .navigationTitle("Settings")
            .alert("Reset all data?", isPresented: $viewModel.showResetAlert) {
                Button("Cancel", role: .cancel) {
                    HapticFeedback.tap()
                }
                Button("Reset", role: .destructive) {
                    HapticFeedback.warning()
                    store.resetAll()
                }
            } message: {
                Text("This removes palettes, history, achievements, and settings from this device.")
            }
            .transparentAppNavigation()
            .appScreenAtmosphere()
        }
    }

    private func settingsRowLabel(title: String, systemImage: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: systemImage)
                .font(.body.weight(.medium))
                .foregroundStyle(Color.appPrimary)
                .frame(width: 24, alignment: .center)
            Text(title)
                .foregroundStyle(Color.appTextPrimary)
            Spacer()
            Image(systemName: "arrow.up.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color.appTextSecondary)
        }
        .contentShape(Rectangle())
    }

    private func statColumn(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title.uppercased())
                .font(.caption2.weight(.semibold))
                .foregroundStyle(Color.appTextSecondary)
            Text(value)
                .font(.body.weight(.bold))
                .foregroundStyle(Color.appAccent)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func openPolicyURL() {
        if let url = AppSettingsLink.privacyPolicy.url {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }

    private func openTermsURL() {
        if let url = AppSettingsLink.termsOfUse.url {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }

    private func rateApp() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }

    private func openSupportEmail() {
        guard let url = URL(string: "mailto:support@example.com") else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}
