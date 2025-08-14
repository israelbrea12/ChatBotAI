//
//  HeroLayer.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 17/6/25.
//

import SwiftUI
import SDWebImageSwiftUI

struct HeroLayer: View {
    @Environment(UICoordinator.self) private var coordinator
    
    var message: Message
    var sAnchor: Anchor<CGRect>
    var dAnchor: Anchor<CGRect>
    
    var body: some View {
        GeometryReader { proxy in
            let sRect = proxy[sAnchor]
            let dAnchorRect = proxy[dAnchor]
            let animateView = coordinator.animateView
            
            let viewSize: CGSize = .init(
                width: animateView ? dAnchorRect.width : sRect.width,
                height: animateView ? dAnchorRect.height : sRect.height
            )
            
            let viewPosition: CGSize = .init(
                width: animateView ? dAnchorRect.minX : sRect.minX,
                height: animateView ? dAnchorRect.minY : sRect.minY
            )
            
            let cornerRadius = animateView ? 0 : 16.0
            
            if let urlString = message.imageURL, let url = URL(string: urlString), !coordinator.showDetailView {
                WebImage(url: url)
                    .resizable()
                    .aspectRatio(contentMode: animateView ? .fit : .fill)
                    .frame(width: viewSize.width, height: viewSize.height)
                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                    .offset(viewPosition)
                    .transition(.identity)
                
            }
        }
    }
}
