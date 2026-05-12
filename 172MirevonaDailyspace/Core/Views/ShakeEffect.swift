//
//  ShakeEffect.swift
//  172MirevonaDailyspace
//

import Combine
import SwiftUI

struct ShakeEffect: GeometryEffect {
    var amount: CGFloat = 8
    var shakes: CGFloat
    var animatableData: CGFloat {
        get { shakes }
        set { shakes = newValue }
    }

    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(CGAffineTransform(translationX: amount * sin(shakes * .pi * 2), y: 0))
    }
}

extension View {
    func shake(trigger: CGFloat) -> some View {
        modifier(ShakeEffect(shakes: trigger))
    }
}
