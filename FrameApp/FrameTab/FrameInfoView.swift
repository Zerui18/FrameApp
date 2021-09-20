//
//  FrameInfoView.swift
//  Frame
//
//  Created by Zerui Chen on 20/9/21.
//

import SwiftUI

struct FrameInfoView: View {
    
    @ObservedObject var model: FrameInfoModel = .shared
    
    var body: some View {
        HStack(alignment: .center) {
            Text("Frame")
                .fontWeight(.bold)
                .font(.largeTitle)
            
            VStack(alignment: .leading) {
                Text(model.appVersion)
                    .font(.caption)
                    .foregroundColor(.gray)
                Text(model.tweakVersion)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(.leading, 5)
        }
        .alert(isPresented: $model.showTweakAlert) {
            Alert(title: Text("Frame Tweak Not Found"),
                  message: Text("No compatible Frame tweak found. Please check that you have installed the latest version of the Frame tweak."),
                  primaryButton: .cancel(Text("Install/Upgrade Frame")) {
                    let framePackageURLs = [
                        "zbra://packages/com.zx02.frame/?source=https://zerui18.github.io/zx02",
                        "sileo://package/com.zx02.frame",
                        "installer://show/shared=Installer&name=Frame&bundleid=com.zx02.frame&repo=https://zerui18.github.io/zx02",
                        "cydia://url/https://cydia.saurik.com/api/share#?source=https://zerui18.github.io/zx02&package=com.zx02.frame"
                    ].map { URL(string: $0)! }
                    if let url = framePackageURLs.first(where: UIApplication.shared.canOpenURL) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                  },
                  secondaryButton: .default(Text("Dismiss")))
        }
    }
}
