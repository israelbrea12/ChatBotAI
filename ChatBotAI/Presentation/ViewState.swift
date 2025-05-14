//
//  ViewState.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 12/3/25.
//

import Foundation

enum ViewState: Equatable {
    case initial, loading, error(String), success, empty
}
