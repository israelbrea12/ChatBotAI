//
//  StorageDataSource.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 19/3/25.
//

import Foundation
import UIKit
import FirebaseStorage

protocol StorageDataSource {
    func uploadImage(image: UIImage, userId: String) async throws -> String
}

class StorageDataSourceImpl: StorageDataSource {
    
    func uploadImage(image: UIImage, userId: String) async throws -> String {
        let ref = await SessionManager.shared.storage.reference().child("profile_images/\(userId).jpg")
        
        guard let imageData = image.jpegData(compressionQuality: 0.5) else {
            throw AppError.unknownError("Error converting image to data")
        }
        
        let _ = try await ref.putDataAsync(imageData)
        let url = try await ref.downloadURL()
        return url.absoluteString
    }
}
