//
//  RootModel.swift
//  Frame
//
//  Created by Zerui Chen on 15/7/21.
//

import Foundation

class RootModel: ObservableObject {
    
    static let shared: RootModel = .init()
    
    @Published var tweakVersion = ""
    let appVersion: String = {
        let versionNumber = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        let buildNumber = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
        return "v\(versionNumber) (\(buildNumber))"
    }()
    
    @Published var showTweakAlert = false
    @Published var errorText: String?
    
    private var hasShownTweakAlert = false
    private let timer = DispatchSource.makeTimerSource()
        
    fileprivate init() {
        // Use DispatchSourceTimer to run check on background queue.
        // If run on main queue the initial run will cause crash.
        timer.setEventHandler {
            guard let tweakVersion = getFrameTweakVersion() else {
                DispatchQueue.main.async {
                    self.tweakVersion = "(Not Installed)"
                    if !self.hasShownTweakAlert {
                        self.showTweakAlert = true
                        self.hasShownTweakAlert = true
                    }
                }
                return
            }
            DispatchQueue.main.async {
                self.tweakVersion = "v" + tweakVersion
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
