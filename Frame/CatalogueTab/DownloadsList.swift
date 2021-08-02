//
//  DownloadsList.swift
//  Frame
//
//  Created by Zerui Chen on 2/8/21.
//

import SwiftUI

struct DownloadsList: View {
    
    @FetchRequest(entity: VideoRecord.entity(),
                  sortDescriptors: [.init(key: "timestamp", ascending: false)],
                  predicate: NSPredicate(format: "isDownloaded == NO"))
    private var videoRecords: FetchedResults<VideoRecord>
    
    var body: some View {
        ScrollView {
            List {
                ForEach(videoRecords) { record in
                    DownloadsListRow(forRecord: record)
                }
            }
        }
    }
}

struct DownloadsList_Previews: PreviewProvider {
    static var previews: some View {
        DownloadsList()
    }
}
