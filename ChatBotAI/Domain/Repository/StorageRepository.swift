//
//  StorageRepository.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 19/3/25.
//

import Foundation
import UIKit

protocol StorageRepository {
    func uploadImage(image: UIImage, userId: String) async -> Result<String, AppError>
}
