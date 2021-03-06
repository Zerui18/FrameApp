//
//  AppDelegate.swift
//  Frame
//
//  Created by Zerui Chen on 9/7/21.
//

import UIKit
import AVFoundation
import NukeWebPPlugin

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        try? AVAudioSession.sharedInstance().setCategory(.ambient, options: .mixWithOthers)
        WebPImageDecoder.enable()
        MigrationManager.migrateOldFrameIfNecessary()
        Paths.mkdirIfNecessary() // must be after migration to not interfere with the decision to migrate
        SavedVideoStore.shared.restartDownloads()
        return true
    }

    // MARK: UISceneSession Lifecycle
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }
    
}

