//
//  InfoView.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 12/3/25.
//

import SwiftUI

struct InfoView: View {
    let message: String
    
    var body: some View {
        VStack {
            Spacer()
            Text(message)
                .font(.title)
                .fontWeight(.bold)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity) // 👉 Este es el cambio importante
        .background(Color(.systemGray6))
    }
}

struct InfoView_Previews: PreviewProvider {
    static var previews: some View {
        InfoView(message: "Info message")
    }
}
