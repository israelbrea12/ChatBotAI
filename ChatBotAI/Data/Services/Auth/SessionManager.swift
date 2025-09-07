//
//  SessionManager.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 14/3/25.
//

import FirebaseAuth
import Combine
import Firebase
import FirebaseStorage
import FirebaseDatabase

@MainActor
class SessionManager: NSObject, ObservableObject {
    
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: User?
    
    let auth: Auth
    let storage: Storage
    
    static let shared = SessionManager()
    
    override init() {
        FirebaseApp.configure()
        
        self.auth = Auth.auth()
        self.storage = Storage.storage()
        
        self.userSession = auth.currentUser
        super.init()
        
    }
}
