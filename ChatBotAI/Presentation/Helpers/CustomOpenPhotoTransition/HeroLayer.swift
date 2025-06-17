//
//  HeroLayer.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 17/6/25.
//


import SwiftUI
import SDWebImageSwiftUI

/// Dibuja la imagen que se anima entre la burbuja del chat y la vista de detalle.
struct HeroLayer: View {
    @Environment(UICoordinator.self) private var coordinator
    
    var message: Message
    var sAnchor: Anchor<CGRect> // Ancla de Origen (Source)
    var dAnchor: Anchor<CGRect> // Ancla de Destino (Destination)
    
    var body: some View {
        GeometryReader { proxy in
            let sRect = proxy[sAnchor]
            let dRect = proxy[dAnchor]
            
            // Calcula el tamaño y la posición de la imagen en cada frame de la animación.
            let viewSize: CGSize = .init(
                width: coordinator.animateView ? dRect.width : sRect.width,
                height: coordinator.animateView ? dRect.height : sRect.height
            )
            let viewPosition: CGSize = .init(
                width: coordinator.animateView ? dRect.minX : sRect.minX,
                height: coordinator.animateView ? dRect.minY : sRect.minY
            )
            
            // Solo mostramos esta capa si la vista de detalle no es visible todavía.
            if let urlString = message.imageURL, let url = URL(string: urlString), !coordinator.showDetailView {
                WebImage(url: url)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: viewSize.width, height: viewSize.height)
                    .clipped()
                    .offset(viewPosition)
                    .transition(.identity) // Evita animaciones de fade no deseadas.
            }
        }
    }
}