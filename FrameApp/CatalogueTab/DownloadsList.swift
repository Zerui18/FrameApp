//
//  DownloadsList.swift
//  Frame
//
//  Created by Zerui Chen on 2/8/21.
//

import SwiftUI

struct DownloadsList: View {
    
    @FetchRequest(entity: SavedVideo.entity(),
                  sortDescriptors: [.init(key: "timestamp", ascending: false)],
                  predicate: NSPredicate(format: "isDownloaded == NO"))
    var savedVideos: FetchedResults<SavedVideo>
        
    var body: some View {
        Group {
            if savedVideos.isEmpty {
                Text("There is no download currently.")
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            }
            else {
                List {
                    ForEach(savedVideos) { record in
                        DownloadsListRow(forRecord: record)
                    }
                }
            }
        }
        .transition(.opacity)
        .animation(.easeIn)
    }
}

extension SavedVideo: Identifiable {}

struct DownloadsList_Previews: PreviewProvider {
    static var previews: some View {
        DownloadsList()
    }
}
