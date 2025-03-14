//
//  InputView.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 13/3/25.
//

import SwiftUI

struct InputView: View {
    
    @Binding var text: String
    let title: String
    let placeholder: String
    var isSecureField = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .fontWeight(.semibold)
                .font(.footnote)
            
            if isSecureField {
                SecureField(placeholder, text: $text)
                    .font(.system(size: 14))
                    .textFieldStyle(.roundedBorder)
            } else {
                TextField(placeholder, text: $text)
                    .font(.system(size: 14))
                    .textFieldStyle(.roundedBorder)
            }
        }
    }
}

#Preview {
    InputView(text: .constant(""), title: "Email adress", placeholder: "name@example.com")
}
