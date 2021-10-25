//
//  MigrationManager.swift
//  Frame
//
//  Created by Zerui Chen on 20/9/21.
//

import Foundation
import NukeWebPPlugin
import AVFoundation

struct MigrationManager {
    
    private init() {}
    
    static func migrateOldFrameIfNecessary() {
        // Files
        let oldFolder = URL(fileURLWithPath: "/var/mobile/Documents/com.ZX02.Frame")
        let newFolder = Paths.rootDocumentsFolder
        if FileManager.default.fileExists(atPath: oldFolder.path) {
            // Migration needed.
            do {
                // Move videos.
                let oldVideoFolder = oldFolder.appendingPathComponent("Cache/Videos")
                let newVideoFolder = newFolder.appendingPathComponent("videos")
                for name in try FileManager.default.contentsOfDirectory(atPath: oldVideoFolder.path) where name.hasSuffix(".mp4") {
                    let old = oldVideoFolder.appendingPathComponent(name)
                    let new = newVideoFolder.appendingPathComponent(name)
                    try FileManager.default.moveItem(at: old, to: new)
                }
                // Scan and create records.
                let videoNames = try FileManager.default.contentsOfDirectory(atPath: newVideoFolder.path).map { String($0.prefix($0.count-4)) }
                let oldThumbsFolder = oldFolder.appendingPathComponent("Cache/Thumbs")
                let webpDecoder = WebPDataDecoder()
                CDManager.performAndSave { _ in
                    for name in videoNames {
                        let videoURL = newVideoFolder.appendingPathComponent(name+".mp4")
                        var thumbnailImage = UIImage()
                        // Try to read existing thumbnail.
                        if let thumbsData = try? Data(contentsOf: oldThumbsFolder.appendingPathComponent(name + ".webp")),
                           let thumbnail = webpDecoder.decode(thumbsData) {
                            thumbnailImage = thumbnail
                        }
                        // Try to generate a thumbnail from the video.
                        else if let thumbnail = try? AVAsset.generateThumbnail(fromAssetAtURL: videoURL) {
                            thumbnailImage = thumbnail
                        }
                        // Create record in db.
                        SavedVideo(withName: name, thumbnail: thumbnailImage, videoURL: videoURL).isDownloaded = true
                    }
                    // Finally, remove the old folder.
                    try? FileManager.default.removeItem(at: oldFolder)
                }
            }
            catch (let error) {
                print("Migration Error: \(error)")
            }
        }
        
        // UserDefaults
        func moveDefaults(fromKey keyOri: String, toKey keyNew: String) {
            if let value = UserDefaults.shared.value(forKey: keyOri) {
                UserDefaults.shared.removeObject(forKey: keyOri)
                UserDefaults.shared.setValue(value, forKey: keyNew)
            }
        }
        moveDefaults(fromKey: "videoURL", toKey: "both.videoPath")
        moveDefaults(fromKey: "videoURLHomescreen", toKey: "homescreen.videoPath")
        moveDefaults(fromKey: "videoURLLockscreen", toKey: "lockscreen.videoPath")
    }

    
}
