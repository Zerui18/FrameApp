//
//  FrameTabPage.swift
//  Frame
//
//  Created by Zerui Chen on 15/7/21.
//

import SwiftUI
import CoreData

struct FrameTabPage: View {
    
    let domain: SettingDomain
    
    init(domain: SettingDomain) {
        self.domain = domain
        self.model = .init(domain: domain)
        self._videoPath = .init(domain: domain, key: .videoPath, defaultValue: nil)
    }
    
    @ObservedObject private var model: FrameTabPageModel
    @Setting private var videoPath: String?
    @State private var isLibraryOpened = false

    var body: some View {
        VStack(spacing: 5) {
//                ZStack(alignment: .topLeading) {
//                    VideoView(videoPath: model.videoPath)
//                    if UIDevice.current.userInterfaceIdiom == .phone {
//                        CropOverlayView(model: model)
//                    }
//                }
//                .aspectRatio(model.videoSize, contentMode: .fit)
            if let videoPath = videoPath {
                GeometryReader { proxy in
                    VideoView(videoPath: videoPath)
                        .aspectRatio(model.videoSize, contentMode: .fit)
                        .overlay(
                            TinyToggle(setting:
                                            .init(domain: domain, key: .isMuted, defaultValue: true),
                                       onImage: Image(systemName: "speaker.slash.fill"),
                                       offImage: Image(systemName: "speaker.wave.2.fill"))
                                .padding()
                                .frame(maxWidth: .infinity,
                                       maxHeight: .infinity,
                                       alignment: .bottomTrailing)
                        )
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .transition(.opacity.animation(.easeIn))
            }
            else {
                Spacer()
                Text("~ Empty ~")
            }
            
            Spacer()
            
            Button {
                isLibraryOpened = true
            } label: {
                Text("Choose Video")
                    .bold()
                    .foregroundColor(Color(.white))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill()
                    )
            }
            .sheet(isPresented: $isLibraryOpened) {
                LibraryView(domain: domain)
                    .environment(\.managedObjectContext, CDManager.moc)
            }
            
            Spacer()
            
            if videoPath != nil {
                Button {
                    FrameTabModel.shared.setVideo(nil, forDomain: domain)
                } label: {
                    Text("Unset")
                        .bold()
                        .foregroundColor(Color(.white))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.gray)
                        )
                }
            }
        }
        .padding([.leading, .trailing], 30)
        .padding([.top, .bottom], 15)
    }
}

struct FrameTabPage_Previews: PreviewProvider {
    static var previews: some View {
        FrameTabPage(domain: .homescreen)
    }
}
