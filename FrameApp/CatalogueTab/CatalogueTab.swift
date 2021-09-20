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
    @State private var selectedVideo: CatalogueModel.Item?
    @State private var previewingVideoURL: URL?
    @State private var downloadingOpened = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
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
            .sheet(item: $previewingVideoURL) { url in
                AVPlayerVCView(videoURL: url)
            }

            Button {
                downloadingOpened = true
            } label: {
                Image(systemName: "square.and.arrow.down.on.square")
                Text("Downloading")
                Spacer()
                Image(systemName: "chevron.forward")
            }
            .padding([.leading, .trailing], 30)
            .sheet(isPresented: $downloadingOpened) {
                DownloadsList()
                    .environment(\.managedObjectContext, CDManager.moc)
            }
            
            GalleryGridView(items: model.listingItems,
                            selectedItem: $selectedVideo,
                            edgeInsets: .init(top: 0, left: 20, bottom: 0, right: 20), onRefresh: { handler in
                                model.refreshListing(with: handler)
                            })
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .onAppear {
                    WebPImageDecoder.enable()
                    model.fetchIndexIfNecessary()
                }
        }
        .padding(.top, 15)
        .actionSheet(item: $selectedVideo) { item in
            var buttons: [ActionSheet.Button] = [.default(Text("Preview")) {
                if let record = RecordsModel.shared.record(forVideoURL: item.videoURL), record.isDownloaded {
                    previewingVideoURL = record.localURL
                }
                else {
                    previewingVideoURL = item.videoURL
                }
              }, .cancel()]
            switch item.downloadTask.state {
            case .paused:
                buttons.insert(.default(Text("Download")) {
                    RecordsModel.shared.downloadVideo(withItem: item)
                }, at: 1)
            default: break
            }
            return ActionSheet(title: Text(item.name), buttons: buttons)
        }
    }
}

struct CatalogueTab_Previews: PreviewProvider {
    static var previews: some View {
        CatalogueTab()
            .colorScheme(.light)
    }
}
