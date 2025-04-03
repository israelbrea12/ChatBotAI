//
//  Extensions.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 3/4/25.
//

import Foundation

extension Date {
    func formattedDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium  // Formato: Apr 3, 2025
        formatter.timeStyle = .short   // Formato: 10:30 AM
        return formatter.string(from: self)
    }
}
