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
    private var bag = [AnyCancellable]()
    @Setting(key: .videoURLShared, defaultValue: nil) private var _videoURLShared: String?
    @Setting(key: .videoURLHomescreen, defaultValue: nil) private var _videoURLHomescreen: String?
    @Setting(key: .videoURLLockscreen, defaultValue: nil) private var _videoURLLockscreen: String?
    
    // MARK: Public Properties
    var videoPathShared: String? {
        get {
            _videoURLShared
        }
        set {
            _videoURLHomescreen = nil
            _videoURLLockscreen = nil
            _videoURLShared = newValue
        }
    }
    
    var videoPathHomescreen: String? {
        get {
            _videoURLHomescreen
        }
        set {
            if _videoURLShared != nil {
                _videoURLLockscreen = _videoURLShared
                _videoURLShared = nil
            }
            _videoURLHomescreen = newValue
        }
    }
    
    var videoPathLockscreen: String? {
        get {
            _videoURLHomescreen
        }
        set {
            if _videoURLShared != nil {
                _videoURLHomescreen = _videoURLShared
                _videoURLShared = nil
            }
            _videoURLLockscreen = newValue
        }
    }
    
    fileprivate init() {
        // Forward objectWillChange.
        bag.append($_videoURLShared.objectWillChange.sink(receiveValue: objectWillChange.send))
        bag.append($_videoURLHomescreen.objectWillChange.sink(receiveValue: objectWillChange.send))
        bag.append($_videoURLLockscreen.objectWillChange.sink(receiveValue: objectWillChange.send))
    }
    
}
