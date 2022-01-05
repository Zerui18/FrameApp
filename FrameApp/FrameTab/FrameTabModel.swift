//
//  FrameTabModel.swift
//  Frame
//
//  Created by Zerui Chen on 14/7/21.
//

import Foundation
import Combine

class FrameTabModel: ObservableObject {
    
    static let shared: FrameTabModel = .init()
    
    // MARK: Privates
    @Setting(domain: .both, key: .videoPath, defaultValue: nil) private var videoPathShared: String?
    @Setting(domain: .homescreen, key: .videoPath, defaultValue: nil) private var videoPathHomescreen: String?
    @Setting(domain: .lockscreen, key: .videoPath, defaultValue: nil) private var videoPathLockscreen: String?
    
    // MARK: Public Properties
//    var videoPathShared: String? {
//        _videoPathShared.isEmpty ? nil:_videoPathShared
//    }
//
//    var videoPathHomescreen: String? {
//        _videoPathHomescreen.isEmpty ? nil:_videoPathHomescreen
//    }
//
//    var videoPathLockscreen: String? {
//        _videoPathLockscreen.isEmpty ? nil:_videoPathLockscreen
//    }
    
    func setVideo(_ video: SavedVideo?, forDomain domain: SettingDomain) {
        let path = video?.localURL.path
        switch domain {
        case .both:
            videoPathHomescreen = nil
            videoPathLockscreen = nil
            videoPathShared = path
        case .homescreen:
            if videoPathShared != nil {
                videoPathLockscreen = videoPathShared
                videoPathShared = nil
            }
            videoPathHomescreen = path
        case .lockscreen:
            if videoPathShared != nil {
                videoPathHomescreen = videoPathShared
                videoPathShared = nil
            }
            videoPathLockscreen = path
        case .global:
            fatalError("\"videoPath\" cannot be set on the global domain!")
        }
        notifyTweak()
    }
    
    /// Notify the tweak of video change.
    private func notifyTweak() {
        let center = CFNotificationCenterGetDarwinNotifyCenter()
        let name = CFNotificationName("com.zx02.frame.videoChanged" as CFString)
        CFNotificationCenterPostNotification(center, name, nil, nil, true)
    }
    
}
