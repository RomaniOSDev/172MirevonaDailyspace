//
//  SettingsViewModel.swift
//  172MirevonaDailyspace
//

import Combine
import Foundation

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var showResetAlert = false
}
