//
//  HomeViewModel.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 12/3/25.
//

import Foundation

@MainActor
final class HomeViewModel: ObservableObject {
    
    @Published var state: ViewState = .success
}

