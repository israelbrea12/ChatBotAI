//
//  PresenceDataSource.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 2/7/25.
//

import Foundation
import FirebaseDatabase

protocol PresenceDataSource {
    func observePresence(for userId: String, completion: @escaping (Result<Presence, AppError>) -> Void)
    func stopObservingPresence(for userId: String)
}

class PresenceDataSourceImpl: PresenceDataSource {
    private let databaseRef = Database.database().reference()
    private var presenceHandles: [String: DatabaseHandle] = [:]
    
    func observePresence(for userId: String, completion: @escaping (Result<Presence, AppError>) -> Void) {
        let presenceRef = databaseRef.child("users/\(userId)/presence")
        
        if presenceHandles[userId] != nil {
            stopObservingPresence(for: userId)
        }
        
        let handle = presenceRef.observe(.value) { snapshot in
            guard let value = snapshot.value as? [String: Any],
                  let isOnline = value["isOnline"] as? Bool,
                  let lastSeen = value["lastSeen"] as? TimeInterval else {
                
                let defaultPresence = Presence(isOnline: false, lastSeen: Date().timeIntervalSince1970 * 1000)
                completion(.success(defaultPresence))
                return
            }
            
            let presence = Presence(isOnline: isOnline, lastSeen: lastSeen / 1000)
            completion(.success(presence))
        }
        
        presenceHandles[userId] = handle
    }
    
    func stopObservingPresence(for userId: String) {
        if let handle = presenceHandles[userId] {
            let presenceRef = databaseRef.child("users/\(userId)/presence")
            presenceRef.removeObserver(withHandle: handle)
            presenceHandles.removeValue(forKey: userId)
        }
    }
}
