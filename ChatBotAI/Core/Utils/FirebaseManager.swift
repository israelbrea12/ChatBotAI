//
//  FirebaseManager.swift
//  LBTASwiftUIFirebaseChat
//
//  Created by Brian Voong on 11/15/21.
//

import Foundation
import FirebaseAuth
import Firebase

class FirebaseManager: NSObject {
    
    let auth: Auth
    let firestore: Firestore
    
    var currentUser: User?
    
    static let shared = FirebaseManager()
    
    override init() {
        FirebaseApp.configure()
        
        self.auth = Auth.auth()
        self.firestore = Firestore.firestore()
        
        super.init()
    }
    
}
