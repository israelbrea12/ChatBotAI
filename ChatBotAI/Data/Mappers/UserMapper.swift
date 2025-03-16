//
//  UserMapper.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 14/3/25.
//

import Foundation

extension UserModel {
    func toDomain() -> User {
        return User(id: self.uid, fullName: self.fullName, email: self.email)
    }
}
