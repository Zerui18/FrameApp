//
//  CatalogueTab.swift
//  Frame
//
//  Created by Zerui Chen on 15/7/21.
//

import SwiftUI
import Tetra
import NukeWebPPlugin

struct CatalogueTab: View {
    
    @ObservedObject private var model: CatalogueModel = .shared
    @State private var selectedVideo: CatalogueModel.VideoItem?
    @State private var previewingVideoURL: URL?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack(alignment: .center, spacing: 10) {
                Text("Catalogue")
                    .fontWeight(.bold)
                    .font(.largeTitle)
                    .layoutPriority(1)
                
                VStack(alignment: .leading) {
                    Text(model.selectedCategoryName)
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text("\(model.listingItems.count) videos")
                        .font(.caption)
                        .foregroundColor(.gray)
                }.layoutPriority(1)
                .transition(.opacity.animation(.easeIn))
                // Force SwiftUI to always treat this as a new View, triggering the transition.
                .id(arc4random())
                
                Spacer()
                
                DownloadsWidget()
            }
            .padding([.leading, .trailing], 30)
            
            ScrollSelector(items: model.categoryNames, selectedIndex: $model.selectedCategoryIndex)
                .padding([.leading, .trailing], 30)
            
            VideoGalleryView(items: model.listingItems,
                            selectedItem: $selectedVideo,
                            edgeInsets: .init(top: 0, left: 20, bottom: 0, right: 20),
                            refreshHandler: model.refreshListing)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .onAppear {
                    WebPImageDecoder.enable()
                    model.fetchIndexIfNecessary()
                }
                .sheet(item: $previewingVideoURL) { url in
                    AVPlayerVCView(videoURL: url)
                }
        }
        .padding(.top, 15)
        .actionSheet(item: $selectedVideo) { selectedVideo in
            var buttons: [ActionSheet.Button] = [.default(Text("Preview")) {
                previewingVideoURL = model.getPreviewURL(forVideo: selectedVideo)
              }, .cancel()]
            switch selectedVideo.downloadTask.state {
            case .paused:
                buttons.insert(.default(Text("Download")) {
                    model.addToSavedVideos(selectedVideo)
                }, at: 1)
            default: break
            }
            return ActionSheet(title: Text(selectedVideo.name), buttons: buttons)
        }
    }
}

struct CatalogueTab_Previews: PreviewProvider {
    static var previews: some View {
        CatalogueTab()
            .colorScheme(.dark)
    }
}
