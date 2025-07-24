//
//  Extensions.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 3/4/25.
//

import Foundation
import UIKit
import SwiftUI


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
            
            formatter.dateFormat = "h:mm a"
            if calendar.isDateInToday(self) {
                return formatter.string(from: self)
            }
            
            if calendar.isDateInYesterday(self) {
                return NSLocalizedString("Yesterday", comment: "Date label for yesterday")
            }
            
            if let days = components.day, days < 7 {
                formatter.dateFormat = "EEEE"
                return formatter.string(from: self)
            }

            formatter.dateFormat = "dd/MM/yyyy" // Ejemplo: 03/04/2025
            return formatter.string(from: self)
        }
    
    func BublesFormattedTime() -> String {
        let formatter = DateFormatter()
        
        formatter.dateFormat = "HH:mm" // 🔁 Cambiado aquí
            return formatter.string(from: self)
    }
    
    func whatsappFormattedTimeAgoWithoutAMOrPM() -> String {
        let formatter = DateFormatter()
        formatter.locale = .current
        
        if Calendar.current.isDateInToday(self) {
            return NSLocalizedString("Today", comment: "Date label for today")
        }
        
        if Calendar.current.isDateInYesterday(self) {
            return NSLocalizedString("Yesterday", comment: "Date label for yesterday")
        }
        
        let now = Date()
        let calendar = Calendar.current
        if let days = calendar.dateComponents([.day], from: self, to: now).day, days < 7 {
            formatter.dateFormat = "EEEE"
            return formatter.string(from: self)
        }
        
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter.string(from: self)
    }
}

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder),
                   to: nil, from: nil, for: nil)
    }
}

/// Custom SwiftUI View Extensions
extension View {
    /// View Alignments
    @ViewBuilder
    func hSpacing(_ alignment: Alignment = .center) -> some View {
        self
            .frame(maxWidth: .infinity, alignment: alignment)
    }
    
    @ViewBuilder
    func vSpacing(_ alignment: Alignment = .center) -> some View {
        self
            .frame(maxHeight: .infinity, alignment: alignment)
    }
    
    /// Disable With Opacity
    @ViewBuilder
    func disableWithOpacity(_ condition: Bool) -> some View {
        self
            .disabled(condition)
            .opacity(condition ? 0.5 : 1)
    }
}
