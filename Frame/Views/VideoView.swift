//
//  VideoView.swift
//  Frame
//
//  Created by Zerui Chen on 14/7/21.
//

import SwiftUI
import UIKit
import AVFoundation

class AVPlayerView: UIView {
    
    let playerLayer: AVPlayerLayer
    
    init() {
        self.playerLayer = .init()
        super.init(frame: .zero)
        layer.addSublayer(playerLayer)
        layer.cornerRadius = 10
        layer.borderColor = UIColor.secondaryLabel.cgColor
        layer.borderWidth = 3
        layer.masksToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = layer.bounds
    }
}

fileprivate var looperKey = 0

struct VideoView: UIViewRepresentable {
    
    init(item: AVPlayerItem) {
        self.item = item
    }
    
    private let item: AVPlayerItem
    
    func makeUIView(context: Context) -> AVPlayerView {
        return AVPlayerView()
    }
    
    func updateUIView(_ uiView: AVPlayerView, context: Context) {
        let player = AVQueuePlayer()
        player.isMuted = true
        let looper = AVPlayerLooper(player: player, templateItem: item)
        objc_setAssociatedObject(player, &looperKey, looper, .OBJC_ASSOCIATION_RETAIN)
        uiView.playerLayer.player = player
        uiView.widthAnchor.constraint(equalTo: uiView.heightAnchor).isActive = true
        player.play()
    }
}
