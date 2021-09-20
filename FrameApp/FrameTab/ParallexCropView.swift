//
//  ParallexCropView.swift
//  Frame
//
//  Created by Zerui Chen on 16/7/21.
//

import SwiftUI
import Combine
import AVFoundation

struct CropOverlayView: View {
    
    @ObservedObject var model: FrameTabPageModel
    
    private let outerRadius: CGFloat = 25
    
    // MARK: Circle Offsets
    func topLeftOffset(inSize size: CGSize) -> CGSize {
        CGSize(width: size.width*model.cropRect.minX - outerRadius,
               height: size.height*model.cropRect.minY - outerRadius)
    }
    
    func topRightOffset(inSize size: CGSize) -> CGSize {
        CGSize(width: size.width*model.cropRect.maxX - outerRadius,
               height: size.height*model.cropRect.minY - outerRadius)
    }
    
    func bottomLeftOffset(inSize size: CGSize) -> CGSize {
        CGSize(width: size.width*model.cropRect.minX - outerRadius,
               height: size.height*model.cropRect.maxY - outerRadius)
    }
    
    func bottomRightOffset(inSize size: CGSize) -> CGSize {
        CGSize(width: size.width*model.cropRect.maxX - outerRadius,
               height: size.height*model.cropRect.maxY - outerRadius)
    }
    
    // MARK: Constraint x&y
    func validX(x: CGFloat, width: CGFloat) -> CGFloat {
        min(max(x, 0), width)
    }
    
    func validY(y: CGFloat, height: CGFloat) -> CGFloat {
        min(max(y, 0), height)
    }
    
    func makeCircle() -> some View {
        Circle()
            .stroke(lineWidth: 3)
            .frame(width: outerRadius, height: outerRadius)
            .overlay(Circle().fill().frame(width: 10, height: 10))
            .frame(width: 50, height: 50)
            .contentShape(Rectangle())
    }
    
    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let height = proxy.size.height
            ZStack(alignment: .topLeading) {
                // MARK: Rect
                RoundedRectangle(cornerRadius: 10)
                    .fill(
                        Color(.secondarySystemFill)
                    )
                    .frame(width: width*(model.cropRect.maxX-model.cropRect.minX),
                           height: height*(model.cropRect.maxY-model.cropRect.minY))
                    .offset(.init(width: width*model.cropRect.minX, height: height*model.cropRect.minY))
                
                // MARK: Points
                // Top left.
                makeCircle()
                    .offset(topLeftOffset(inSize: proxy.size))
                    .gesture(DragGesture()
                                .onChanged { gesture in
                                    model.cropRect.minX = validX(x: gesture.location.x, width: width) / width
                                    model.cropRect.minY = validY(y: gesture.location.y, height: height) / height
                                }
                    )
                
                // Top right.
                makeCircle()
                    .offset(topRightOffset(inSize: proxy.size))
                    .gesture(DragGesture()
                                .onChanged { gesture in
                                    model.cropRect.maxX = validX(x: gesture.location.x, width: width) / width
                                    model.cropRect.minY = validY(y: gesture.location.y, height: height) / height
                                }
                    )

                // Bottom left.
                makeCircle()
                    .offset(bottomLeftOffset(inSize: proxy.size))
                    .gesture(DragGesture()
                                .onChanged { gesture in
                                    model.cropRect.minX = validX(x: gesture.location.x, width: width) / width
                                    model.cropRect.maxY = validY(y: gesture.location.y, height: height) / height
                                }
                    )

                // Bottom right.
                makeCircle()
                    .offset(bottomRightOffset(inSize: proxy.size))
                    .gesture(DragGesture()
                                .onChanged { gesture in
                                    model.cropRect.maxX = validX(x: gesture.location.x, width: width) / width
                                    model.cropRect.maxY = validY(y: gesture.location.y, height: height) / height
                                }
                    )
            }
        }
    }
}

struct ParallexCropView: View {
    
    var model: FrameTabPageModel
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            if let videoPath = model.videoPath {
                // Fix the aspect ratio of the views to the video.
                let item = AVPlayerItem(url: URL(fileURLWithPath: videoPath))
                if let size = item.asset.tracks(withMediaType: .video).first?.naturalSize {
                    Group {
                        VideoView(item: item)
//                        if UIDevice.current.userInterfaceIdiom == .phone {
//                            CropOverlayView(model: model)
//                        }
                    }
                    .aspectRatio(size, contentMode: .fit)
                    .transition(.scale)
                }
            }
        }
    }
}

//struct ParallexCropView_Previews: PreviewProvider {
//    static var previews: some View {
//        ParallexCropView(videoPath: .constant("/Users/zeruichen/Downloads/iOS 13 Apple Store Demo.mp4"))
//    }
//}
