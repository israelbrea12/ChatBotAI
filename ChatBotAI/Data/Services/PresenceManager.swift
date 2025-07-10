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
        
        self.presenceRef = databaseRef.child("users/\(currentUserID)/presence")
 
        let onDisconnectData: [String: Any] = [
            "isOnline": false,
            "lastSeen": ServerValue.timestamp()
        ]
        presenceRef?.onDisconnectUpdateChildValues(onDisconnectData)

        let connectedRef = databaseRef.child(".info/connected")
        
        connectedHandle = connectedRef.observe(.value, with: { [weak self] snapshot in
            guard let self = self, let isConnected = snapshot.value as? Bool, isConnected else {
                return
            }
            
            let presenceData: [String: Any] = [
                "isOnline": true,
                "lastSeen": ServerValue.timestamp()
            ]
            self.presenceRef?.setValue(presenceData)
        })
    }
    
    func goOffline() {
        guard let presenceRef = self.presenceRef else { return }
        
        let offlineData: [String: Any] = [
            "isOnline": false,
            "lastSeen": ServerValue.timestamp()
        ]
        presenceRef.setValue(offlineData)
        
        presenceRef.cancelDisconnectOperations()
        
        if let connectedHandle = connectedHandle {
            databaseRef.child(".info/connected").removeObserver(withHandle: connectedHandle)
            self.connectedHandle = nil
        }
        self.presenceRef = nil
    }
}
