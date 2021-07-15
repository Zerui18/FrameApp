//
//  LibraryView.swift
//  Frame
//
//  Created by Zerui Chen on 15/7/21.
//

import SwiftUI
import CoreData
import QGrid

struct LibraryView: View {
    
    @FetchRequest(entity: VideoRecord.entity(), sortDescriptors: [.init(key: "timestamp", ascending: false)]) var videoRecords: FetchedResults<VideoRecord>
    
    @State private var selectedVideo: VideoRecord?
    @State private var previewingVideo: VideoRecord?
    
    let page: FrameTab.Page
    
    var body: some View {
        QGrid(videoRecords, columns: 2) { video in
            ZStack(alignment: .init(horizontal: .leading, vertical: .bottom)) {
                Image(uiImage: video.thumbnailImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .cornerRadius(10)
                
                VStack(alignment: .leading) {
                    Text(video.name!)
                        .font(.caption)
                    
                    Text(video.sizeString)
                        .font(.caption)
                }
                .padding(5)
                .background(Blur().cornerRadius(5))
                .padding([.leading, .bottom], 5)
            }
            .onTapGesture {
                selectedVideo = video
            }
        }
        .actionSheet(item: $selectedVideo) { video in
            ActionSheet(title: Text(video.name!),
                        buttons: [.default(Text("Set").bold()) {
                            let model = FrameTabModel.shared
                            switch page {
                            case .both:
                                model.videoPathShared = video.videoURL!.path
                            case .homescreen:
                                model.videoPathHomescreen = video.videoURL!.path
                            case .lockscreen:
                                model.videoPathLockscreen = video.videoURL!.path
                            }
                          }, .default(Text("Preview")) {
                            previewingVideo = video
                          }, .cancel()])
        }
        .sheet(item: $previewingVideo) { video in
            AVPlayerVCView(videoURL: video.videoURL!)
        }
    }
}

//struct LibraryView_Previews: PreviewProvider {
//    static var previews: some View {
//        LibraryView()
//    }
//}
