//
//  LibraryView.swift
//  Frame
//
//  Created by Zerui Chen on 15/7/21.
//

import SwiftUI
import CoreData

struct LibraryView: View {
    
    @FetchRequest(entity: VideoRecord.entity(), sortDescriptors: [.init(key: "timestamp", ascending: false)]) var videoRecords: FetchedResults<VideoRecord>
    
    @State private var selectedVideo: VideoRecord?
    @State private var previewingVideo: VideoRecord?
    
    let domain: SettingDomain
    
    var body: some View {
        GalleryGridView(items: Array(videoRecords),
                        selectedItem: $selectedVideo,
                        edgeInsets: .init(top: 20, left: 20, bottom: 20, right: 20))
            .actionSheet(item: $selectedVideo) { video in
                ActionSheet(title: Text(video.name),
                            buttons: [.default(Text("Set").bold()) {
                                FrameTabModel.shared.setVideo(video, forDomain: domain)
                              }, .default(Text("Preview")) {
                                previewingVideo = video
                              }, .cancel()])
            }
            .sheet(item: $previewingVideo) { video in
                AVPlayerVCView(videoURL: video.videoURL)
            }
    }
}

extension VideoRecord: GalleryGridItemRepresentable {
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
