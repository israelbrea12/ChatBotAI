//
//  User.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 13/3/25.
//

import Foundation

struct User: Identifiable, Codable, Hashable {
    let id: String
    let fullName: String?
    let email: String?
    let profileImageUrl: String?
    var learningLanguage: String?
    
    var initials: String {
        let formatter = PersonNameComponentsFormatter()
        if let components = formatter.personNameComponents(from: fullName ?? "") {
            formatter.style = .abbreviated
            return formatter.string(from: components)
        }
        return ""
    }
}

