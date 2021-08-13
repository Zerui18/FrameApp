//
//  Blur.swift
//  Frame
//
//  Created by Zerui Chen on 16/7/21.
//

import SwiftUI
import UIKit

struct Blur: UIViewRepresentable {
    let style: UIBlurEffect.Style = .systemMaterial

    func makeUIView(context: Context) -> UIVisualEffectView {
        UIVisualEffectView(effect: UIBlurEffect(style: style))
    }

    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.clipsToBounds = true
        uiView.effect = UIBlurEffect(style: style)
    }
}
