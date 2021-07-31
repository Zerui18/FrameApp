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
    @Setting(domain: .both, key: .videoPath, defaultValue: "") private var _videoPathShared: String
    @Setting(domain: .homescreen, key: .videoPath, defaultValue: "") private var _videoPathHomescreen: String
    @Setting(domain: .lockscreen, key: .videoPath, defaultValue: "") private var _videoPathLockscreen: String
    
    // MARK: Public Properties
    var videoPathShared: String? {
        _videoPathShared.isEmpty ? nil:_videoPathShared
    }
    
    var videoPathHomescreen: String? {
        _videoPathHomescreen.isEmpty ? nil:_videoPathHomescreen
    }
    
    var videoPathLockscreen: String? {
        _videoPathLockscreen.isEmpty ? nil:_videoPathLockscreen
    }
    
    func setVideo(_ video: VideoRecord, forDomain domain: SettingDomain) {
        let path = video.videoURL.path
        switch domain {
        case .both:
            _videoPathHomescreen = ""
            _videoPathLockscreen = ""
            _videoPathShared = path
        case .homescreen:
            if !_videoPathShared.isEmpty {
                _videoPathLockscreen = _videoPathShared
                _videoPathShared = ""
            }
            _videoPathHomescreen = path
        case .lockscreen:
            if !_videoPathShared.isEmpty {
                _videoPathHomescreen = _videoPathShared
                _videoPathShared = ""
            }
            _videoPathLockscreen = path
        }
        notifyTweak()
    }
    
    /// Notify the tweak of video change.
    private func notifyTweak() {
//        #if !targetEnvironment(simulator)
        let center = CFNotificationCenterGetDarwinNotifyCenter()
        let name = CFNotificationName("com.zx02.frame.videoChanged" as CFString)
        CFNotificationCenterPostNotification(center, name, nil, nil, true)
//        #endif
    }
    
}
