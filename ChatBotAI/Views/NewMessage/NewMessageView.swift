//
//  NewMessageView.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 20/3/25.
//

import SwiftUI
import SDWebImageSwiftUI

struct NewMessageView: View {
    
    let didSelectNewUser: (User) -> ()
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                
            }.navigationTitle("New Message")
                .toolbar {
                    ToolbarItemGroup(placement: .navigationBarLeading) {
                        Button {
                            presentationMode.wrappedValue.dismiss()
                        } label: {
                            Text("Cancel")
                        }
                    }
                }
        }
    }
}

