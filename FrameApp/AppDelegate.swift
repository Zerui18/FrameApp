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
        SavedVideoStore.shared.restartDownloads()
        WebPImageDecoder.enable()
        MigrationManager.migrateOldFrameIfNecessary()
        return true
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        try? AVAudioSession.sharedInstance().setCategory(.ambient, options: .mixWithOthers)
        try? AVAudioSession.sharedInstance().setActive(true, options: [])
    }

    // MARK: UISceneSession Lifecycle
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }
    
}

