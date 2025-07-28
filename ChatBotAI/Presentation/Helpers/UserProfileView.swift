//
//  UserProfileView.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 26/3/25.
//

import SwiftUI
import SDWebImageSwiftUI

struct UserProfileView: View {
    let user: User?
    
    var body: some View {
        HStack {
            WebImage(
                url: URL(string: user?.profileImageUrl ?? "")
            ) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .frame(width: 36, height: 36)
                        .overlay(RoundedRectangle(cornerRadius: 44 )
                            .stroke(Color.gray, lineWidth: 0.5))
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 36, height: 36)
                        .clipShape(Circle())
                        .overlay(RoundedRectangle(cornerRadius: 44 )
                            .stroke(Color.gray, lineWidth: 0.5))
                case .failure:
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 36, height: 36)
                        .foregroundColor(.gray)
                        .overlay(RoundedRectangle(cornerRadius: 44 )
                            .stroke(Color.gray, lineWidth: 0.5))
                @unknown default:
                    EmptyView()
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(user?.fullName ?? LocalizedKeys.Placeholder.fullnamePlaceholder)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(Color(.label))
                HStack {
                    Circle()
                        .foregroundColor(.green)
                        .frame(width: 10, height: 10)
                    Text(LocalizedKeys.Common.online)
                        .font(.system(size: 12))
                        .foregroundColor(Color(.lightGray))
                }
            }
        }
    }
}

