//
//  UserMapper.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 14/3/25.
//

import Foundation

extension UserModel {
    func toDomain() -> User {
        return User(id: self.uid, fullName: self.fullName, email: self.email, profileImageUrl: self.profileImageUrl, learningLanguage: self.learningLanguage)
    }
    
    func toDictionary() -> [String: Any] {
        var dictionary: [String: Any] = [
            Constants.Database.User.uid: uid,
            Constants.Database.User.email: email ?? "",
            Constants.Database.User.fullName: fullName ?? ""
        ]
        
        if let url = profileImageUrl {
            dictionary[Constants.Database.User.profileImageUrl] = url
        }
        
        if let lang = learningLanguage {
            dictionary[Constants.Database.User.learningLanguage] = lang
        }
        
        return dictionary
    }
    
}
