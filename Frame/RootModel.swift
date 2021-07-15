//
//  RootModel.swift
//  Frame
//
//  Created by Zerui Chen on 15/7/21.
//

import Foundation

class RootModel: ObservableObject {
    
    static let shared: RootModel = .init()
    
    @Published var tweakVersion = "(Not Installed)"
    let appVersion: String = {
        let versionNumber = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        let buildNumber = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
        return "v\(versionNumber) (\(buildNumber))"
    }()
    
    @Published var showTweakAlert = false
    
    fileprivate init() {
        Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { _ in
            #if !targetEnvironment(simulator)
            guard let tweakVersion = getFrameTweakVersion() else {
                self.tweakVersion = "(Not Installed)"
                if !self.showTweakAlert {
                    self.showTweakAlert = true
                }
                return
            }
            self.tweakVersion = tweakVersion
            #endif
        }.fire()
    }
    
}

fileprivate func getFrameTweakVersion() -> String? {
    let expr = try! NSRegularExpression(pattern: "^Version: (.+)$", options: .anchorsMatchLines)
    let output = runCommandInPath("dpkg -s com.zx02.frame")
    guard let match = expr.firstMatch(in: output, options: [], range: NSRange(location: 0, length: output.count)) else { return nil }
    return (output as NSString).substring(with: match.range(at: 1)) as String
}
