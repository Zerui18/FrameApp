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
    
    let player: AVPlayer
    let playerLayer: AVPlayerLayer
    
    init(player: AVPlayer) {
        self.player = player
        self.playerLayer = .init(player: player)
        super.init(frame: .zero)
        layer.addSublayer(playerLayer)
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
    
    @Binding var videoPath: String?
    let player = AVQueuePlayer()
    
    func makeUIView(context: Context) -> AVPlayerView {
        return AVPlayerView(player: player)
    }
    
    func updateUIView(_ uiView: AVPlayerView, context: Context) {
        // Reset player, removing looper if exists.
        objc_removeAssociatedObjects(uiView)
        player.removeAllItems()
        // Try to init new item and looper.
        guard let videoPath = videoPath else {
            return
        }
        let item = AVPlayerItem(url: .init(fileURLWithPath: videoPath))
        let looper = AVPlayerLooper(player: player, templateItem: item)
        objc_setAssociatedObject(uiView, &looperKey, looper, .OBJC_ASSOCIATION_RETAIN)
    }
}
