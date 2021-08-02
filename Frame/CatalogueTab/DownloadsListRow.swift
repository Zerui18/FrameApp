//
//  DownloadsListRow.swift
//  Frame
//
//  Created by Zerui Chen on 2/8/21.
//

import SwiftUI
import Tetra

struct DownloadsListRow: View {
    
    init(forRecord record: VideoRecord) {
        self.record = record
        self.task = record.downloadTask
    }
    
    private let record: VideoRecord
    @ObservedObject private var task: TTask
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(record.name)
            if case .downloading(let progress) = task.state {
                ProgressBar(value: progress, maxValue: 1)
                    .frame(height: 3)
            }
        }
    }
}

//struct DownloadsListRow_Previews: PreviewProvider {
//    static var previews: some View {
//        DownloadsListRow()
//    }
//}
