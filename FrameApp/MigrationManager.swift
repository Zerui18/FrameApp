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
    
    /// Migrate old Frame files to Frame 3's storage non-destructively.
    static func migrateOldFrameIfNecessary() {
        // Files
        let oldFolder = URL(fileURLWithPath: "/var/mobile/Documents/com.ZX02.Frame")
        let newFolder = Paths.rootDocumentsFolder
        // ONLY migrate if old frame folder exists AND new frame folder doesn't
        if FileManager.default.fileExists(atPath: oldFolder.path)
            && !FileManager.default.fileExists(atPath: newFolder.path) {
            // Migration needed.
            do {
                // Copy videos.
                let oldVideoFolder = oldFolder.appendingPathComponent("Cache/Videos")
                let newVideoFolder = newFolder.appendingPathComponent("videos")
                for name in try FileManager.default.contentsOfDirectory(atPath: oldVideoFolder.path) where name.hasSuffix(".mp4") {
                    let old = oldVideoFolder.appendingPathComponent(name)
                    let new = newVideoFolder.appendingPathComponent(name)
                    try FileManager.default.copyItem(at: old, to: new)
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
                }
            }
            catch (let error) {
                print("Migration Error: \(error)")
            }
        }
        
        // UserDefaults
        func copyDefaults(fromKey keyOri: String, toKey keyNew: String) {
            if let value = UserDefaults.shared.value(forKey: keyOri) {
//                UserDefaults.shared.removeObject(forKey: keyOri)
                UserDefaults.shared.setValue(value, forKey: keyNew)
            }
        }
        // There's no need to manually convert from URL to String
        // as a URL is stored as the String of its path.
        copyDefaults(fromKey: "videoURL", toKey: "both/videoPath")
        copyDefaults(fromKey: "videoURLHomescreen", toKey: "homescreen/videoPath")
        copyDefaults(fromKey: "videoURLLockscreen", toKey: "lockscreen/videoPath")
        
        copyDefaults(fromKey: "mutedHomescreen", toKey: "homescreen/isMuted")
        copyDefaults(fromKey: "mutedLockscreen", toKey: "lockscreen/isMuted")
    }

    
}
