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
    
    let domain: SettingDomain
    
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
                            FrameTabModel.shared.setVideo(video, forDomain: domain)
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
