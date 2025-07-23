//
//  GradientButton.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 18/6/25.
//


// MARK: GradientButton.swift

import SwiftUI

struct GradientButton: View {
    var title: LocalizedStringKey
    var icon: String
    var onClick: () -> ()
    var body: some View {
        Button(action: onClick, label: {
            HStack(spacing: 15) {
                Text(title)
                Image(systemName: icon)
            }
            .fontWeight(.bold)
            .foregroundStyle(.white)
            .padding(.vertical, 12)
            .padding(.horizontal, 35)
            .background(.linearGradient(colors: [.lightBlue, .appBlue, .darkBlue], startPoint: .top, endPoint: .bottom), in: .capsule)
        })
    }
}

#Preview {
    ContentView()
}
