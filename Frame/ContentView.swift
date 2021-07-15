//
//  ContentView.swift
//  Frame
//
//  Created by Zerui Chen on 9/7/21.
//

import SwiftUI

struct ContentView: View {
    
    @ObservedObject var model: RootModel = .shared
    
    var body: some View {
        TabView {
            FrameTab()
                .tabItem {
                    Image("icon_opaque")
                    Text("Frame")
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
                  message: Text("No compatible frame tweak found. Please check that you have installed the latest version of the frame tweak."),
                  primaryButton: .cancel(Text("Install/Upgrade Frame")) {
//                    UIApplication.shared.open(URL, options: [:], completionHandler: nil)
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
