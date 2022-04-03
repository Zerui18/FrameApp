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
                    Image(systemName: "ellipsis")
                    Text("More")
                }
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
