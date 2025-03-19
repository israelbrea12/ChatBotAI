//
//  StorageRepositoryImpl.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 19/3/25.
//

import Foundation
import UIKit

class StorageRepositoryImpl: StorageRepository {
    
    private let dataSource: StorageDataSource
    
    init(dataSource: StorageDataSource) {
        self.dataSource = dataSource
    }
    
    func uploadImage(image: UIImage, userId: String) async -> Result<String, AppError> {
        do {
            let imageUrl = try await dataSource.uploadImage(image: image, userId: userId)
            return .success(imageUrl)
        } catch {
            return .failure(error.toAppError())
        }
    }
}
