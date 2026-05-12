//
//  HapticFeedback.swift
//  172MirevonaDailyspace
//

import UIKit

enum HapticFeedback {
    private static let lightImpact = UIImpactFeedbackGenerator(style: .light)
    private static let mediumImpact = UIImpactFeedbackGenerator(style: .medium)
    private static let notification = UINotificationFeedbackGenerator()

    static func tap() {
        lightImpact.prepare()
        lightImpact.impactOccurred()
    }

    static func actionComplete() {
        mediumImpact.prepare()
        mediumImpact.impactOccurred()
    }

    static func success() {
        notification.prepare()
        notification.notificationOccurred(.success)
    }

    static func warning() {
        notification.prepare()
        notification.notificationOccurred(.warning)
    }
}
