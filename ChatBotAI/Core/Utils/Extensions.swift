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
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: self)
    }
    
    func timeAgoSinceNow() -> String {
        let now = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.minute, .hour, .day, .weekOfYear], from: self, to: now)
        
        if let minutes = components.minute, minutes < 1 {
            return LocalizedKeys.TimeAgo.justNow
        }
        if let minutes = components.minute, minutes < 60 {
            return LocalizedKeys.TimeAgo.minutes(minutes)
        }
        if let hours = components.hour, hours < 24 {
            return LocalizedKeys.TimeAgo.hours(hours)
        }
        if let days = components.day, days < 7 {
            return LocalizedKeys.TimeAgo.days(days)
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
            return LocalizedKeys.Common.yesterday
        }
        
        if let days = components.day, days < 7 {
            formatter.dateFormat = "EEEE"
            return formatter.string(from: self)
        }
        
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter.string(from: self)
    }
    
    func BublesFormattedTime() -> String {
        let formatter = DateFormatter()
        
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: self)
    }
    
    func whatsappFormattedTimeAgoWithoutAMOrPM() -> String {
        let formatter = DateFormatter()
        formatter.locale = .current
        
        if Calendar.current.isDateInToday(self) {
            return LocalizedKeys.Common.today
        }
        
        if Calendar.current.isDateInYesterday(self) {
            return LocalizedKeys.Common.yesterday
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

extension View {
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
    
    @ViewBuilder
    func disableWithOpacity(_ condition: Bool) -> some View {
        self
            .disabled(condition)
            .opacity(condition ? 0.5 : 1)
    }
    
    @ViewBuilder
    func blurSlide(_ show: Bool) -> some View {
        self
            .opacity(show ? 1 : 0)
            .offset(y: show ? 0 : 10)
            .blur(radius: show ? 0 : 5)
    }
}
