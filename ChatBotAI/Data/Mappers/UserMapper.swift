//
//  UserMapper.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 14/3/25.
//

import Foundation

extension UserModel {
    func toDomain() -> User {
        return User(id: self.uid, fullName: self.fullName, email: self.email, profileImageUrl: self.profileImageUrl)
    }
    
    func toDictionary() -> [String: Any] {
            var dictionary: [String: Any] = [
                "uid": uid,
                "email": email ?? "",
                "fullName": fullName ?? ""
            ]

            if let url = profileImageUrl {
                dictionary["profileImageUrl"] = url
            }

            return dictionary
        }

}
