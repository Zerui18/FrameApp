//
//  FrameTab.swift
//  Frame
//
//  Created by Zerui Chen on 14/7/21.
//

import SwiftUI

struct FrameTab: View {
    
    enum Page {
        case both, homescreen, lockscreen
    }
    
    @ObservedObject var rootModel: RootModel = .shared
    @State var page: Page = .homescreen
    
    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // MARK: Title
                    HStack(alignment: .center) {
                        Text("Frame")
                            .fontWeight(.bold)
                            .font(.largeTitle)
                        
                        VStack(alignment: .leading) {
                            Text("App     \(rootModel.appVersion)")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Text("Tweak \(rootModel.tweakVersion)")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .padding(.leading, 5)
                    }
                    
                    // MARK: Content
                    Picker(selection: $page, label: Text(""), content: {
                        Text("Both").tag(Page.both)
                        Text("Home").tag(Page.homescreen)
                        Text("Lock").tag(Page.lockscreen)
                    })
                    .pickerStyle(SegmentedPickerStyle())
                    
                    FrameTabPage(page: page)
                }
                .padding()
                .padding([.leading, .trailing])
            }
        }
    }
}

struct FrameTab_Previews: PreviewProvider {
    static var previews: some View {
        FrameTab()
    }
}
