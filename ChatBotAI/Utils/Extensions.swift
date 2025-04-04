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
    
    func timeAgoSinceNow() -> String {
            let now = Date()
            let calendar = Calendar.current
            let components = calendar.dateComponents([.minute, .hour, .day, .weekOfYear], from: self, to: now)

            if let minutes = components.minute, minutes < 1 {
                return "Justo ahora"
            }
            if let minutes = components.minute, minutes < 60 {
                return "\(minutes) min"
            }
            if let hours = components.hour, hours < 24 {
                return "\(hours) h"
            }
            if let days = components.day, days < 7 {
                return "\(days) días"
            }

            let formatter = DateFormatter()
            formatter.dateFormat = "dd/MM/yyyy"
            return formatter.string(from: self)
        }
    
    func whatsappFormattedTimeAgo() -> String {
            let now = Date()
            let calendar = Calendar.current
            let formatter = DateFormatter()

            let components = calendar.dateComponents([.minute, .hour, .day, .weekOfYear, .year], from: self, to: now)
            
            formatter.dateFormat = "h:mm a" // Ejemplo: 10:30 AM
            if calendar.isDateInToday(self) {
                return formatter.string(from: self)
            }
            
            if calendar.isDateInYesterday(self) {
                return "Yesterday"
            }
            
            if let days = components.day, days < 7 {
                formatter.dateFormat = "EEEE" // Ejemplo: Monday, Tuesday...
                return formatter.string(from: self)
            }

            formatter.dateFormat = "dd/MM/yyyy" // Ejemplo: 03/04/2025
            return formatter.string(from: self)
        }
}
