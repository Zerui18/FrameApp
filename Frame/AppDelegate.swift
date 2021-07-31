//
//  AppDelegate.swift
//  Frame
//
//  Created by Zerui Chen on 9/7/21.
//

import UIKit
import CoreData
import WebP

/// The root folder for all of Frame's documents.
let rootDocumentsFolder: URL = {
    #if !targetEnvironment(simulator)
    let url = URL(fileURLWithPath: "/var/mobile/Documents/com.zx02/frame/")
    #else
    let url = URL(fileURLWithPath: "/Users/zeruichen/Documents/com.zx02/frame/")
    #endif
    if !FileManager.default.fileExists(atPath: url.path) {
        try! FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: [.posixPermissions:511])
    }
    return url
}()

/// A custom subclass that stores the database in `rootDocumentsFolder`.
final class MyPersistentContainer: NSPersistentContainer {
    override class func defaultDirectoryURL() -> URL {
        return rootDocumentsFolder
    }
}

/// The shared persistent container for Frame.
let persistentContainer: MyPersistentContainer = {
    let container = MyPersistentContainer(name: "Frame")
    container.loadPersistentStores(completionHandler: { (storeDescription, error) in
      if let error = error as NSError? {
          fatalError("Unresolved error \(error), \(error.userInfo)")
      }
    })
    return container
}()

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        WebPImageDecoder.enable()
        migrateOldFrameIfNecessary()
        return true
    }
    
    private func migrateOldFrameIfNecessary() {
        // Files
        let documents = URL(fileURLWithPath: "/var/mobile/Documents")
        let oldFolder = documents.appendingPathComponent("com.ZX02.Frame")
        let newFolder = rootDocumentsFolder
        if FileManager.default.fileExists(atPath: oldFolder.path) {
            // Migration needed.
            do {
                // Move videos.
                let oldVideoFolder = oldFolder.appendingPathComponent("Cache/Videos")
                let newVideoFolder = newFolder.appendingPathComponent("videos")
                try FileManager.default.moveItem(at: oldVideoFolder, to: newVideoFolder)
                // Scan and create records.
                let videoNames = try FileManager.default.contentsOfDirectory(atPath: newVideoFolder.path).map { String($0.prefix($0.count-4)) }
                let oldThumbsFolder = oldFolder.appendingPathComponent("Cache/Thumbs")
                let webpDecoder = WebPDecoder()
                for name in videoNames {
                    // Try to get thumbnail, but don't stop if we fail on one.
                    guard let thumbsData = try? Data(contentsOf: oldThumbsFolder.appendingPathComponent(name + ".webp")) else {
                        continue
                    }
                    // Try to read and decode the thumb, if it's nil we can just generate it from the video.
                    let thumbnailImage = (try? webpDecoder.decode(thumbsData, options: WebPDecoderOptions())).flatMap(UIImage.init(cgImage:))
                    // Create record in db.
                    _ = VideoRecord(withName: name, videoURL: newVideoFolder.appendingPathComponent(name+".mp4"), thumbnail: thumbnailImage)
                }
                // Finally, remove the old folder.
                try FileManager.default.removeItem(at: oldFolder)
                try persistentContainer.viewContext.save()
            }
            catch (let error) {
                RootModel.shared.errorText = error.localizedDescription
            }
        }
        
        // UserDefaults
        func moveDefaults(fromKey keyOri: String, toKey keyNew: String) {
            if let value = UserDefaults.shared.value(forKey: keyOri) {
                UserDefaults.shared.removeObject(forKey: keyOri)
                UserDefaults.shared.setValue(value, forKey: keyNew)
            }
        }
        moveDefaults(fromKey: "videoURL", toKey: "videoPath")
        moveDefaults(fromKey: "videoURLHomescreen", toKey: "homescreen.videoPath")
        moveDefaults(fromKey: "videoURLLockscreen", toKey: "lockscreen.videoPath")
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        try? persistentContainer.viewContext.save()
    }

    // MARK: UISceneSession Lifecycle
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }
    
}

