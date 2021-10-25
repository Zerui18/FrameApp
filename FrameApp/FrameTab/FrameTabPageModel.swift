//
//  FrameTabPageModel.swift
//  Frame
//
//  Created by Zerui Chen on 19/7/21.
//

import SwiftUI
import Combine
import AVFoundation

struct Rect: Equatable {
    var minX: CGFloat = 0
    var minY: CGFloat = 0
    var maxX: CGFloat = 1
    var maxY: CGFloat = 1
}

struct ParallexTrail: EncodedSetting {
    struct Rect: EncodedSetting {
        var centerX: Double = 0.5
        var centerY: Double = 0.5
        var width: Double = 1
        var height: Double = 1
    }
    var rects: [Rect] = [.init()]
}

class FrameTabPageModel: ObservableObject {
    
    private let domain: SettingDomain
    private var bag = Set<AnyCancellable>()
    
    @Published var videoSize: CGSize = .init(width: 1, height: 1)
    
    @Setting private(set) var videoPath: String
    @Setting var videoVolume: Double
    @Setting private(set) var parallexTrail: ParallexTrail
    @Setting var parallexNPages: Int
    
    @Published var cropRect: Rect = .init()
    
    init(domain: SettingDomain) {
        self.domain = domain
        
        // Init settings.
        self._videoPath = .init(domain: domain, key: .videoPath, defaultValue: "")
        self._videoVolume = .init(domain: domain, key: .videoVolume, defaultValue: 0)
        self._parallexTrail = .init(domain: domain, key: .parallexTrail, defaultValue: .init())
        self._parallexNPages = .init(domain: domain, key: .parallexNPages, defaultValue: 1)
        
        // Keep track of size of current video.
        self._videoPath.setChangeHandler { [weak self] videoPath in
            self?.videoSize = AVAsset(url: URL(fileURLWithPath: videoPath)).tracks(withMediaType: .video)[0].naturalSize
        }
        
        // Handle cropRect to parallexTrail translation.
        // Calculations assume iPhone in portrait.
//        $cropRect
//            .debounce(for: 0.5, scheduler: RunLoop.main)
//            .removeDuplicates()
//            .sink { cropRect in
//                let deviceSize = UIScreen.main.bounds.size
//                let minX = self.videoSize.width * cropRect.minX
//                let maxX = self.videoSize.width * cropRect.maxX
//                let minY = self.videoSize.height * cropRect.minY
//                let maxY = self.videoSize.height * cropRect.maxY
//                let deviceWidthScaled = deviceSize.width * (deviceSize.height / (maxY - minY))
//
//            }
//            .store(in: &bag)
    }
    
}
