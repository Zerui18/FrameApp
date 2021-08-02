//
//  DownloadsModel.swift
//  Frame
//
//  Created by Zerui Chen on 2/8/21.
//

import Tetra

class DownloadsModel {
    
    static let shared = DownloadsModel()
    
    private init() {}
    
    func downloadVideo(withItem item: CatalogueModel.Item) {
        let record = VideoRecord(withName: item.name, remoteURL: item.videoURL)
        try! persistentContainer.viewContext.save()
//        record.downloadTask.download(item.videoURL) {
//            record.isDownloaded = true
//            record.processVideo()
//        }
    }
    
}
