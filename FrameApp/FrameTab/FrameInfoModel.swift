//
//  FrameInfoModel.swift
//  Frame
//
//  Created by Zerui Chen on 15/7/21.
//

import Foundation

class FrameInfoModel: ObservableObject {
    
    static let shared: FrameInfoModel = .init()
    
    @Published var tweakVersion = ""
    let appVersion: String = {
        let versionNumber = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        let buildNumber = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
        return "App     v\(versionNumber) (\(buildNumber))"
    }()
    
    @Published var showTweakAlert = false
    
    private var hasShownTweakAlert = false
    private let timer = DispatchSource.makeTimerSource()
        
    fileprivate init() {
        // Use DispatchSourceTimer to run check on background queue.
        // If run on main queue the initial run will cause crash.
        timer.setEventHandler {
            guard let tweakVersion = getFrameTweakVersion() else {
                let updatedVersion = "(Not Installed)"
                if updatedVersion != self.tweakVersion {
                    DispatchQueue.main.async {
                        self.tweakVersion = "Tweak \(updatedVersion)"
                        if !self.hasShownTweakAlert {
                            self.showTweakAlert = true
                            self.hasShownTweakAlert = true
                        }
                    }
                }
                return
            }
            let updatedVersion = "v" + tweakVersion
            if updatedVersion != self.tweakVersion {
                DispatchQueue.main.async {
                    self.tweakVersion = "Tweak \(updatedVersion)"
                }
            }
        }
        timer.schedule(deadline: .now(), repeating: .seconds(5))
        timer.resume()
    }
    
}

fileprivate func getFrameTweakVersion() -> String? {
    #if !targetEnvironment(simulator)
    let expr = try! NSRegularExpression(pattern: "^Version: (.+)$", options: .anchorsMatchLines)
    let output = runCommandInPath("dpkg -s com.zx02.frame")
    guard let match = expr.firstMatch(in: output, options: [], range: NSRange(location: 0, length: output.count)) else { return nil }
    return (output as NSString).substring(with: match.range(at: 1)) as String
    #else
    return ""
    #endif
}
