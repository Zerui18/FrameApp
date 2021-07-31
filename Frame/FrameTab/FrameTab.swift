//
//  FrameTab.swift
//  Frame
//
//  Created by Zerui Chen on 14/7/21.
//

import SwiftUI

struct FrameTab: View {
    
    @ObservedObject var rootModel: RootModel = .shared
    @State var domain: SettingDomain = .homescreen
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // MARK: Title
            VStack(alignment: .leading, spacing: 20) {
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
                Picker(selection: $domain.animation(.easeIn), label: Text(""), content: {
                    Text("Both").tag(SettingDomain.both)
                    Text("Home").tag(SettingDomain.homescreen)
                    Text("Lock").tag(SettingDomain.lockscreen)
                })
                .pickerStyle(SegmentedPickerStyle())
                .padding(.bottom)
            }
            .padding([.leading, .trailing], 30)
            .padding(.top, 15)
            
            FrameTabPage(domain: domain)
        }
    }
}

struct FrameTab_Previews: PreviewProvider {
    static var previews: some View {
        FrameTab()
            .colorScheme(.light)
    }
}
