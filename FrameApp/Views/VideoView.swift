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
    var currentURL: URL
    var playerLooper: AVPlayerLooper
    
    init(item: AVPlayerItem, withURL url: URL) {
        let player = AVQueuePlayer()
        player.isMuted = true
        self.playerLooper = AVPlayerLooper(player: player, templateItem: item)
        self.currentURL = url
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
    
    func set(playerItem: AVPlayerItem, withURL url: URL) {
        if url != currentURL {
            let player = AVQueuePlayer()
            player.isMuted = true
            playerLooper = AVPlayerLooper(player: player, templateItem: playerItem)
            currentURL = url
            playerLayer.player = player
            player.play()
        }
    }

}

struct VideoView: UIViewRepresentable {
    
    init(videoPath: String) {
        self.url =  .init(fileURLWithPath: videoPath)
        self.item = .init(url: url)
    }
    
    private let url: URL
    private let item: AVPlayerItem
    
    func makeUIView(context: Context) -> AVPlayerLoopView {
        AVPlayerLoopView(item: item, withURL: url)
    }
    
    func updateUIView(_ uiView: AVPlayerLoopView, context: Context) {
        uiView.set(playerItem: self.item, withURL: url)
    }
}
