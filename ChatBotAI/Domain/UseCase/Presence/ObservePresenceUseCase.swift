//
//  ObservePresenceUseCase.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 2/7/25.
//

import Foundation

class ObservePresenceUseCase {
    private let presenceRepository: PresenceRepository
    
    init(presenceRepository: PresenceRepository) {
        self.presenceRepository = presenceRepository
    }
    
    func execute(for userId: String, completion: @escaping (Result<Presence, AppError>) -> Void) {
        presenceRepository.observePresence(for: userId, completion: completion)
    }
    
    func stop(for userId: String) {
        presenceRepository.stopObservingPresence(for: userId)
    }
}
