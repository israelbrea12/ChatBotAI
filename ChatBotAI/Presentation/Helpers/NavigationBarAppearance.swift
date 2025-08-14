//
//  NavigationBarAppearance.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 2/6/25.
//

import SwiftUI

func applyOpaqueNavigationBar(opacity: CGFloat = 0.9) {
    let appearance = UINavigationBarAppearance()
    appearance.configureWithOpaqueBackground()
    appearance.backgroundColor = UIColor.systemBackground.withAlphaComponent(opacity)
    appearance.titleTextAttributes = [.foregroundColor: UIColor.label]
    appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.label]
    
    let navigationBar = UINavigationBar.appearance()
    navigationBar.standardAppearance = appearance
    navigationBar.scrollEdgeAppearance = appearance
    navigationBar.compactAppearance = appearance
}

