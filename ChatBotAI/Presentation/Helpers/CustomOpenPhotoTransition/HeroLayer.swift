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
            
            // Durante el arrastre para cerrar, el tamaño de destino debe escalar hacia abajo.
            let scale = animateView ? (1 - coordinator.dragProgress) : 1
            let dRect = CGRect(
                x: dAnchorRect.origin.x,
                y: dAnchorRect.origin.y,
                width: dAnchorRect.width * scale,
                height: dAnchorRect.height * scale
            )

            let viewSize: CGSize = .init(
                width: animateView ? dRect.width : sRect.width,
                height: animateView ? dRect.height : sRect.height
            )
            
            let viewPosition: CGSize = .init(
                width: animateView ? dRect.minX : sRect.minX,
                height: animateView ? dRect.minY : sRect.minY
            )
            
            if let urlString = message.imageURL, let url = URL(string: urlString), !coordinator.showDetailView {
                WebImage(url: url)
                    .resizable()
                    // --- LA SOLUCIÓN ESTÁ AQUÍ ---
                    // Anima el modo de contenido de .fill a .fit
                    .aspectRatio(contentMode: animateView ? .fit : .fill)
                    .frame(width: viewSize.width, height: viewSize.height)
                    .clipped()
                    .offset(viewPosition)
                    .transition(.identity)
            }
        }
    }
}
