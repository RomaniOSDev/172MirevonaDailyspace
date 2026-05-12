//
//  HarmonyEvaluator.swift
//  172MirevonaDailyspace
//

import UIKit

enum HarmonyEvaluator {
    static func isPerfectHarmony(normalizedHexes: [String]) -> Bool {
        let hues = normalizedHexes.compactMap { hueDegrees(fromNormalizedHex: $0) }
        guard hues.count >= 2 else {
            return hues.count == 1
        }
        if hues.count == 2 {
            let diff = angularDifference(hues[0], hues[1])
            return abs(diff - 180) < 22 || diff < 28
        }
        let sorted = hues.sorted()
        var maxGap: CGFloat = 0
        for idx in sorted.indices {
            let a = sorted[idx]
            let b = sorted[(idx + 1) % sorted.count]
            var gap = b - a
            if idx == sorted.count - 1 {
                gap = 360 - a + b
            }
            maxGap = max(maxGap, gap)
        }
        let spread = 360 - maxGap
        return spread < 42
    }

    private static func angularDifference(_ a: CGFloat, _ b: CGFloat) -> CGFloat {
        let d = abs(a - b)
        return min(d, 360 - d)
    }

    private static func hueDegrees(fromNormalizedHex hex: String) -> CGFloat? {
        guard let ui = HexColorCodec.uiColor(fromNormalizedHex: hex) else { return nil }
        var h: CGFloat = 0
        var s: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        guard ui.getHue(&h, saturation: &s, brightness: &b, alpha: &a) else { return nil }
        return h * 360
    }
}
