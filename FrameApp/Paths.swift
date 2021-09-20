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
    //    let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        if !FileManager.default.fileExists(atPath: url.path) {
            try! FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: [.posixPermissions:511])
        }
        let videosPath = url.appendingPathComponent("videos").path
        if !FileManager.default.fileExists(atPath: videosPath) {
            try! FileManager.default.createDirectory(atPath: videosPath, withIntermediateDirectories: false, attributes: [.posixPermissions:511])
        }
        return url
    }()
    
    static func urlFor(videoName: String) -> URL {
        rootDocumentsFolder.appendingPathComponent("videos/\(videoName).mp4")
    }
}
