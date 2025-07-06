//
//  PresenceRepositoryImpl.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 6/7/25.
//

import Foundation

class PresenceRepositoryImpl: PresenceRepository {
    private let presenceDataSource: PresenceDataSource
    
    init(presenceDataSource: PresenceDataSource) {
        self.presenceDataSource = presenceDataSource
    }
    
    func observePresence(for userId: String, completion: @escaping (Result<Presence, AppError>) -> Void) {
        presenceDataSource.observePresence(for: userId, completion: completion)
    }
    
    func stopObservingPresence(for userId: String) {
        presenceDataSource.stopObservingPresence(for: userId)
    }
}
