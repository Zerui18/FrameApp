//
//  FrameTabPage.swift
//  Frame
//
//  Created by Zerui Chen on 15/7/21.
//

import SwiftUI
import CoreData

struct FrameTabPage: View {
    
    @ObservedObject var model: FrameTabModel = .shared
    @State private var isLibraryOpened = false
    let page: FrameTab.Page
    
    var videoPath: Binding<String?> {
        switch page {
        case .both:
            return $model.videoPathShared
        case .homescreen:
            return $model.videoPathHomescreen
        case .lockscreen:
            return $model.videoPathLockscreen
        }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            ParallexCropView(videoPath: videoPath)
                .frame(minHeight: 100)
                .padding(.bottom)
            
            Button {
                isLibraryOpened = true
            } label: {
                Text("Choose Video")
                    .bold()
                    .foregroundColor(Color(.label))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill()
                    )
            }
            .sheet(isPresented: $isLibraryOpened) {
                LibraryView(page: page)
                    .environment(\.managedObjectContext, persistentContainer.viewContext)
            }
        }
    }
}

//struct FrameTabPage_Previews: PreviewProvider {
//    static var previews: some View {
//        FrameTabPage(page: .homescreen)
//    }
//}
