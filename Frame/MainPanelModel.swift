//
//  MainPanelModel.swift
//  Frame
//
//  Created by Zerui Chen on 14/7/21.
//

import Foundation
import Combine

class MainPanelModel: ObservableObject {
    
    // MARK: Privates
    private var bag = [AnyCancellable]()
    @Setting(key: .videoURLShared, defaultValue: nil) private var videoURLShared: URL?
    @Setting(key: .videoURLHomescreen, defaultValue: nil) private var videoURLHomescreen: URL?
    @Setting(key: .videoURLLockscreen, defaultValue: nil) private var videoURLLockscreen: URL?
    
    // MARK: Public Properties
    var videoPathShared: String? {
        get {
            videoURLShared.flatMap { $0.path }
        }
        set {
            videoURLHomescreen = nil
            videoURLLockscreen = nil
            videoURLShared = newValue.flatMap(URL.init(fileURLWithPath:))
        }
    }
    
    var videoPathHomescreen: String? {
        get {
            videoURLHomescreen.flatMap { $0.path }
        }
        set {
            if videoURLShared != nil {
                videoURLLockscreen = videoURLShared
                videoURLShared = nil
            }
            videoURLHomescreen = newValue.flatMap(URL.init(fileURLWithPath:))
        }
    }
    
    var videoPathLockscreen: String? {
        get {
            videoURLHomescreen.flatMap { $0.path }
        }
        set {
            if videoURLShared != nil {
                videoURLHomescreen = videoURLShared
                videoURLShared = nil
            }
            videoURLLockscreen = newValue.flatMap(URL.init(fileURLWithPath:))
        }
    }
    
    init() {
        // Forward objectWillChange.
        bag.append($videoURLShared.objectWillChange.sink(receiveValue: objectWillChange.send))
        bag.append($videoURLHomescreen.objectWillChange.sink(receiveValue: objectWillChange.send))
        bag.append($videoURLLockscreen.objectWillChange.sink(receiveValue: objectWillChange.send))
    }
    
    
}
