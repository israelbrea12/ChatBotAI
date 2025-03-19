//
//  UploadImageUseCase.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 19/3/25.
//

import Foundation
import UIKit

struct UploadImageUseCase {
    private let repository: StorageRepository
    
    init(repository: StorageRepository) {
        self.repository = repository
    }
    
    func execute(image: UIImage, userId: String) async -> Result<String, AppError> {
        await repository.uploadImage(image: image, userId: userId)
    }
}
