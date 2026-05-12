//
//  AchievementBannerController.swift
//  172MirevonaDailyspace
//

import Combine
import SwiftUI

final class AchievementBannerController: ObservableObject {
    @Published private(set) var currentTitle: String?
    @Published private(set) var isVisible = false

    private var queue: [String] = []
    private var dismissWorkItem: DispatchWorkItem?

    func enqueue(title: String) {
        queue.append(title)
        if !isVisible {
            showNext()
        }
    }

    private func showNext() {
        guard let next = queue.first else { return }
        queue.removeFirst()
        dismissWorkItem?.cancel()
        currentTitle = next
        withAnimation(.spring(response: 0.45, dampingFraction: 0.82)) {
            isVisible = true
        }
        let work = DispatchWorkItem { [weak self] in
            self?.hideAndContinue()
        }
        dismissWorkItem = work
        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: work)
    }

    private func hideAndContinue() {
        withAnimation(.easeInOut(duration: 0.28)) {
            isVisible = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.32) { [weak self] in
            guard let self else { return }
            self.currentTitle = nil
            if !self.queue.isEmpty {
                self.showNext()
            }
        }
    }
}
