//
//  CatalogueTab.swift
//  Frame
//
//  Created by Zerui Chen on 15/7/21.
//

import SwiftUI

struct CatalogueTab: View {
    
    @ObservedObject private var model: CatalogueModel = .shared
    @State private var selectedVideo: CatalogueModel.Item?
    @State private var previewingVideo: CatalogueModel.Item?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center) {
                Text("Catalogue")
                    .fontWeight(.bold)
                    .font(.largeTitle)
                
                VStack(alignment: .leading) {
                    Text(model.selectedCategoryName)
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text("\(model.listingItems.count) videos")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding(.leading, 5)
            }
            .padding([.leading, .trailing], 30)
            .padding(.bottom, 15)
            
            GalleryGridView(items: model.listingItems,
                            selectedItem: $selectedVideo,
                            edgeInsets: .init(top: 0, left: 20, bottom: 0, right: 20))
                .onAppear {
                    WebPImageDecoder.enable()
                    model.fetchIndexIfNecessary()
                }
        }
        .padding(.top, 15)
        .actionSheet(item: $selectedVideo) { video in
            ActionSheet(title: Text(video.name),
                        buttons: [.default(Text("Preview")) {
                            previewingVideo = video
                          }, .cancel()])
        }
        .sheet(item: $previewingVideo) { video in
            AVPlayerVCView(videoURL: video.videoURL)
        }
    }
}

struct CatalogueTab_Previews: PreviewProvider {
    static var previews: some View {
        CatalogueTab()
            .colorScheme(.light)
    }
}
