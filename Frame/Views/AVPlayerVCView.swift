//
//  AVPlayerVCView.swift
//  Frame
//
//  Created by Zerui Chen on 16/7/21.
//

import SwiftUI
import AVKit

struct AVPlayerVCView: UIViewControllerRepresentable {
    let videoURL: URL
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        AVPlayerViewController()
    }
    
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        uiViewController.player = AVPlayer(url: videoURL)
    }
}
