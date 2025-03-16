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
    
    enum CodingKeys: String, CodingKey {
        case uid
        case email
        case fullName
    }
    
    init(uid: String, email: String?, fullName: String?) {
        self.uid = uid
        self.email = email
        self.fullName = fullName
    }
}
