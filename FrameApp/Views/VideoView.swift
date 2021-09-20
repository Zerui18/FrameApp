//
//  VideoView.swift
//  Frame
//
//  Created by Zerui Chen on 14/7/21.
//

import SwiftUI
import UIKit
import AVFoundation

class AVPlayerLoopView: UIView {
    
    let playerLayer: AVPlayerLayer
    var playerLooper: AVPlayerLooper
    
    init(item: AVPlayerItem) {
        let player = AVQueuePlayer()
        player.isMuted = true
        self.playerLooper = AVPlayerLooper(player: player, templateItem: item)
        self.playerLayer = .init(player: player)
        super.init(frame: .zero)
        layer.addSublayer(playerLayer)
        layer.cornerRadius = 10
        layer.borderColor = UIColor.secondaryLabel.cgColor
        layer.borderWidth = 3
        layer.masksToBounds = true
        player.play()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = layer.bounds
    }
    
    func set(playerItem: AVPlayerItem) {
        let player = AVQueuePlayer()
        player.isMuted = true
        self.playerLooper = AVPlayerLooper(player: player, templateItem: playerItem)
        self.playerLayer.player = player
        player.play()
    }

}

struct VideoView: UIViewRepresentable {
    
    init(item: AVPlayerItem) {
        self.item = item
    }
    
    private let item: AVPlayerItem
    
    func makeUIView(context: Context) -> AVPlayerLoopView {
        AVPlayerLoopView(item: item)
    }
    
    func updateUIView(_ uiView: AVPlayerLoopView, context: Context) {
        uiView.set(playerItem: self.item)
    }
}
