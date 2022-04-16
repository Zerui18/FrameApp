//
//  Paths.swift
//  Frame
//
//  Created by Zerui Chen on 20/9/21.
//

import Foundation

struct Paths {
    
    private init() {}
    
    /// The root folder for all of Frame's documents.
    static let rootDocumentsFolder: URL = {
        #if !targetEnvironment(simulator)
        let url = URL(fileURLWithPath: "/var/mobile/Documents/com.zx02/frame/")
        #else
        let url = URL(fileURLWithPath: "/Users/zeruichen/Documents/com.zx02/frame/")
        #endif
        return url
    }()
    
    static func mkdirIfNecessary() {
        let videoFolder = rootDocumentsFolder.appendingPathComponent("videos")
        if !FileManager.default.fileExists(atPath: videoFolder.path) {
            try! FileManager.default.createDirectory(at: videoFolder, withIntermediateDirectories: true)
        }
    }
    
    static func urlFor(videoName: String) -> URL {
        rootDocumentsFolder.appendingPathComponent("videos/\(videoName).mp4")
    }
}
