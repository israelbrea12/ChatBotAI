//
//  PresenceManager.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 2/7/25.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth

class PresenceManager {
    
    static let shared = PresenceManager()
    
    private let databaseRef = Database.database().reference()
    private var presenceRef: DatabaseReference?
    private var connectedHandle: DatabaseHandle?
    
    private init() {}
    
    func setupPresence() {
        guard presenceRef == nil, let currentUserID = Auth.auth().currentUser?.uid else { return }
        
        self.presenceRef = databaseRef.child("\(Constants.Database.users)/\(currentUserID)/\(Constants.Database.Presence.root)")
        
        let onDisconnectData: [String: Any] = [
            Constants.Database.Presence.isOnline: false,
            Constants.Database.Presence.lastSeen: ServerValue.timestamp()
        ]
        presenceRef?.onDisconnectUpdateChildValues(onDisconnectData)
        
        let connectedRef = databaseRef.child(Constants.Database.infoConnected)
        
        connectedHandle = connectedRef.observe(.value, with: { [weak self] snapshot in
            guard let self = self, let isConnected = snapshot.value as? Bool, isConnected else {
                return
            }
            
            let presenceData: [String: Any] = [
                Constants.Database.Presence.isOnline: true,
                Constants.Database.Presence.lastSeen: ServerValue.timestamp()
            ]
            self.presenceRef?.setValue(presenceData)
        })
    }
    
    func goOffline() {
        guard let presenceRef = self.presenceRef else { return }
        
        let offlineData: [String: Any] = [
            Constants.Database.Presence.isOnline: false,
            Constants.Database.Presence.lastSeen: ServerValue.timestamp()
        ]
        presenceRef.setValue(offlineData)
        
        presenceRef.cancelDisconnectOperations()
        
        if let connectedHandle = connectedHandle {
            databaseRef.child(Constants.Database.infoConnected).removeObserver(withHandle: connectedHandle)
            self.connectedHandle = nil
        }
        self.presenceRef = nil
    }
}
