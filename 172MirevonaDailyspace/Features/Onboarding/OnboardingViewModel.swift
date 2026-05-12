//
//  OnboardingViewModel.swift
//  172MirevonaDailyspace
//

import Combine
import Foundation

@MainActor
final class OnboardingViewModel: ObservableObject {
    @Published var pageIndex = 0
    let totalPages = 3

    func next() {
        if pageIndex < totalPages - 1 {
            pageIndex += 1
        }
    }
}
