//
//  PaletteInsightsViewModel.swift
//  172MirevonaDailyspace
//

import Combine
import Foundation

enum InsightsSegment: Int, CaseIterable, Identifiable, Hashable {
    case summary = 0
    case trends = 1
    case history = 2

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .summary: return "Summary"
        case .trends: return "Trends"
        case .history: return "History"
        }
    }
}

@MainActor
final class PaletteInsightsViewModel: ObservableObject {
    @Published var segment: InsightsSegment = .summary
    @Published var chartPulse = false
    @Published var showComposer = false
}
