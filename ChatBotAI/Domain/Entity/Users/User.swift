//
//  User.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 13/3/25.
//

// Modelos

import Foundation

struct User: Identifiable, Codable {
    let id: String
    let fullName: String?
    let email: String?
    
    var initials: String {
        let formatter = PersonNameComponentsFormatter()
        if let components = formatter.personNameComponents(from: fullName ?? "") {
            formatter.style = .abbreviated
            return formatter.string(from: components)
        }
        
        return ""
    }
}
