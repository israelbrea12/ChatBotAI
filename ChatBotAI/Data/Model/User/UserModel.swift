//
//  UserModel.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 14/3/25.
//

import Foundation

struct UserModel: Codable {
    let uid: String
    let email: String?
    let fullName: String?
    let profileImageUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case uid
        case email
        case fullName
        case profileImageUrl
    }
    
    init(uid: String, email: String?, fullName: String?, profileImageUrl: String?) {
        self.uid = uid
        self.email = email
        self.fullName = fullName
        self.profileImageUrl = profileImageUrl
    }
}
