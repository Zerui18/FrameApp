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
        HStack(spacing: 20) {
            Image(uiImage: record.thumbnailImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 80)
                .cornerRadius(10)
                        
            VStack(alignment: .leading) {
                Text(record.name)
                
                Spacer()
                
                let state = task.state
                switch state {
                case .downloading(let progress):
                    ProgressBar(value: progress, maxValue: 1)
                        .frame(height: 3)
                case .success:
                    Text("It shouldn't be here!")
                case .failure(let error):
                    Text("Error: \(error.localizedDescription)")
                        .font(.caption)
                        .foregroundColor(Color(.secondaryLabel))
                case .paused:
                    Text("Paused")
                        .font(.caption)
                        .foregroundColor(Color(.secondaryLabel))
                case .preparing:
                    Text("Preparing...")
                        .font(.caption)
                        .foregroundColor(Color(.secondaryLabel))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding([.top, .bottom])
            
            VStack(spacing: 10) {
                let retryButton = Image(systemName: "arrow.clockwise").onTapGesture {
                    record.beginDownload()
                }
                
                let deleteButton = Image(systemName: "trash.fill").onTapGesture {
                    record.delete()
                }
                
                switch task.state {
                case .failure:
                    retryButton
                    deleteButton
                default:
                    deleteButton
                }
            }
        }
    }
}

//struct DownloadsListRow_Previews: PreviewProvider {
//    static var previews: some View {
//        DownloadsListRow()
//    }
//}
