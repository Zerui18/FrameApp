//
//  LibraryView.swift
//  Frame
//
//  Created by Zerui Chen on 15/7/21.
//

import SwiftUI
import CoreData

struct LibraryView: View {
    
    @FetchRequest(entity: SavedVideo.entity(),
                  sortDescriptors: [.init(key: "timestamp", ascending: false)],
                  predicate: NSPredicate(format: "isDownloaded == YES"))
    var videoRecords: FetchedResults<SavedVideo>
    
    @State private var selectedVideo: SavedVideo?
    @State private var previewingVideo: SavedVideo?
    
    let domain: SettingDomain
    
    var body: some View {
        VideoGalleryView(items: Array(videoRecords),
                        selectedItem: $selectedVideo,
                        edgeInsets: .init(top: 20, left: 20, bottom: 20, right: 20))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .actionSheet(item: $selectedVideo) { video in
                ActionSheet(title: Text(video.name),
                            buttons: [.default(Text("Set").bold()) {
                                FrameTabModel.shared.setVideo(video, forDomain: domain)
                              }, .default(Text("Preview")) {
                                previewingVideo = video
                              }, .destructive(Text("Delete")) {
                                video.delete()
                              }, .cancel()])
            }
            .sheet(item: $previewingVideo) { video in
                AVPlayerVCView(videoURL: video.localURL)
            }
    }
}

extension SavedVideo: VideoGalleryItemRepresentable {
    var videoURL: URL {
        localURL
    }
    
    var isLocal: Bool {
        true
    }
    
    var image: UIImage? {
        thumbnailImage
    }
    
    var imageURL: URL {
        URL(fileURLWithPath: "/")
    }
}
