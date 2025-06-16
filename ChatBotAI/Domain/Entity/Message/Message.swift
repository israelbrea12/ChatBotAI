//
//  Message.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 7/4/25.
//

import Foundation
import UIKit

struct Message: Identifiable, Codable, Equatable {
    var id: String
    var text: String
    var senderId: String
    var senderName: String
    var sentAt: TimeInterval?
    var messageType: MessageType = .text
    var imageURL: String? = nil
    
    var localImageData: Data? = nil
    var isUploading: Bool = false
    var uploadFailed: Bool = false

    enum CodingKeys: String, CodingKey {
        case id, text, senderId, senderName, sentAt, messageType, imageURL
    }

    static func == (lhs: Message, rhs: Message) -> Bool {
            return lhs.id == rhs.id &&
                   lhs.imageURL == rhs.imageURL &&
                   lhs.isUploading == rhs.isUploading &&
                   lhs.uploadFailed == rhs.uploadFailed
        }
}
