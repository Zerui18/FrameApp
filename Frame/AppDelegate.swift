//
//  AppDelegate.swift
//  Frame
//
//  Created by Zerui Chen on 9/7/21.
//

import UIKit
import CoreData

let persistentContainer: NSPersistentContainer = {
    let container = NSPersistentContainer(name: "Frame")
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
        // Force the container to init.
        print(persistentContainer)
//        do {
//            let request = NSBatchDeleteRequest(fetchRequest: VideoRecord.fetchRequest())
//            try persistentContainer.viewContext.execute(request)
//        }
//        catch (let err) {
//            print(err)
//        }
//        for i in 1...6 {
//            let newRecord = VideoRecord(withName: "Test Video \(i)", videoURL: URL(fileURLWithPath: "/Users/zeruichen/Downloads/iOS 13 Apple Store Demo.mp4"))
//            persistentContainer.viewContext.insert(newRecord)
//        }
        return true
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

