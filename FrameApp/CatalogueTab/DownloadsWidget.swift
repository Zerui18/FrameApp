//
//  DownloadsWidget.swift
//  FrameApp
//
//  Created by Zerui Chen on 25/9/21.
//

import SwiftUI
import Combine

class DownloadsWidgetModel: ObservableObject {
    
    @Published var downloadingVideosCount: Int = 0
    
    private var cancellable: AnyCancellable! = nil
    
    init() {
        cancellable = SavedVideoStore.shared.$savedVideos.sink { savedVideos in
            withAnimation {
                self.downloadingVideosCount = savedVideos.filter { !$0.isDownloaded }.count
            }
        }
    }
    
}

struct DownloadsWidget: View {
    
    @State private var downloadingOpened = false
    @ObservedObject private var model = DownloadsWidgetModel()
    
    var body: some View {
        Button {
            downloadingOpened = true
        } label: {
            VStack {
                Image(systemName: "square.and.arrow.down.on.square")
                if model.downloadingVideosCount > 0 {
                    Text("\(model.downloadingVideosCount)")
                        .font(.caption)
                        .transition(.slide.combined(with: .opacity))
                        
                }
            }
        }
        .sheet(isPresented: $downloadingOpened) {
            DownloadsList()
                .environment(\.managedObjectContext, CDManager.moc)
        }
    }
}
