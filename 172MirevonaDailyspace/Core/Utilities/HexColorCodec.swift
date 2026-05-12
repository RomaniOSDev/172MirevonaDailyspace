//
//  HexColorCodec.swift
//  172MirevonaDailyspace
//

import SwiftUI
import UIKit

enum HexColorCodec {
    static func normalizedHex(from input: String) -> String? {
        var s = input.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if s.hasPrefix("#") {
            s.removeFirst()
        }
        if s.count == 3 {
            let chars = Array(s)
            s = "\(chars[0])\(chars[0])\(chars[1])\(chars[1])\(chars[2])\(chars[2])"
        }
        guard s.count == 6, s.allSatisfy({ $0.isHexDigit }) else {
            return nil
        }
        return s
    }

    static func uiColor(fromNormalizedHex hex: String) -> UIColor? {
        guard hex.count == 6 else { return nil }
        var value: UInt64 = 0
        guard Scanner(string: hex).scanHexInt64(&value) else { return nil }
        let r = CGFloat((value & 0xFF0000) >> 16) / 255
        let g = CGFloat((value & 0x00FF00) >> 8) / 255
        let b = CGFloat(value & 0x0000FF) / 255
        return UIColor(red: r, green: g, blue: b, alpha: 1)
    }

    static func swiftUIColor(fromNormalizedHex hex: String) -> Color? {
        guard let ui = uiColor(fromNormalizedHex: hex) else { return nil }
        return Color(uiColor: ui)
    }

    static func normalizedHex(fromSwiftUIColor color: Color) -> String? {
        let ui = UIColor(color)
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        guard ui.getRed(&r, green: &g, blue: &b, alpha: &a) else { return nil }
        let ri = Int(round(r * 255))
        let gi = Int(round(g * 255))
        let bi = Int(round(b * 255))
        return String(format: "%02X%02X%02X", ri, gi, bi)
    }
}
