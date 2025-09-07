//
//  LottieView.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 7/9/25.
//


import SwiftUI
import Lottie

struct LottieView: UIViewRepresentable {
    
    var fileName: String

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        let animationView = LottieAnimationView(name: fileName,
                                                configuration: LottieConfiguration(renderingEngine: .mainThread))
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .playOnce
        animationView.animationSpeed = 1
        animationView.play()

        animationView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(animationView)

        NSLayoutConstraint.activate([
            animationView.widthAnchor.constraint(equalTo: view.widthAnchor),
            animationView.heightAnchor.constraint(equalTo: view.heightAnchor)
        ])
        
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}
