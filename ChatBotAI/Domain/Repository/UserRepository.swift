//
//  UserRepository.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 2/4/25.
//

import Foundation
import UIKit

protocol UserRepository {
    func fetchUser() async -> Result<User?, AppError>
    func fetchAllUsersExceptCurrent() async -> Result<[User?], AppError>
}
