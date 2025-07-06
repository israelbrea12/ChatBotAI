//
//  PresenceRepository.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 6/7/25.
//

import Foundation

protocol PresenceRepository {
    func observePresence(for userId: String, completion: @escaping (Result<Presence, AppError>) -> Void)
    func stopObservingPresence(for userId: String)
}
