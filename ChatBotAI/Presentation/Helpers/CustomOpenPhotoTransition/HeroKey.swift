//
//  ChatHeroKey.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 17/6/25.
//


import SwiftUI

/// PreferenceKey para comunicar las anclas (posiciones y tamaños) de las vistas
/// de origen y destino para la animación "Hero".
struct HeroKey: PreferenceKey {
    static var defaultValue: [String: Anchor<CGRect>] = [:]
    
    static func reduce(value: inout [String : Anchor<CGRect>], nextValue: () -> [String : Anchor<CGRect>]) {
        value.merge(nextValue()) { $1 }
    }
}
