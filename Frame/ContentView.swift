//
//  ContentView.swift
//  Frame
//
//  Created by Zerui Chen on 9/7/21.
//

import SwiftUI

extension String: Identifiable {
    public var id: String { self }
}

struct ContentView: View {
    
    @ObservedObject var model: RootModel = .shared
    
    var body: some View {
        TabView {
            FrameTab()
                .tabItem {
                    Image("icon_opaque")
                    Text("Frame")
                }
                .alert(item: $model.errorText) { message in
                    Alert(title: Text("Encountered Error"),
                          message: Text(message),
                          dismissButton: .cancel(Text("Dismiss")))
                }
            
            CatalogueTab()
                .tabItem {
                    Image(systemName: "tray.full")
                    Text("Catalogue")
                }
            
            MoreTab()
                .tabItem {
                    Image(systemName: "gearshape.2")
                    Text("More")
                }
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
        .accentColor(Color("AccentColor"))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .colorScheme(.dark)
    }
}
