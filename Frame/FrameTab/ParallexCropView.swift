//
//  ParallexCropView.swift
//  Frame
//
//  Created by Zerui Chen on 16/7/21.
//

import SwiftUI

struct Rect {
    var minX: CGFloat = 0
    var minY: CGFloat = 0
    var maxX: CGFloat = 1
    var maxY: CGFloat = 1
}

struct ParallexCropView: View {
    
    @Binding var videoPath: String?
    
    @State private var cropRect: Rect = .init()
    private let outerRadius: CGFloat = 25
    
    func topLeftOffset(inSize size: CGSize) -> CGSize {
        CGSize(width: size.width*cropRect.minX - 0.5*outerRadius,
               height: size.height*cropRect.minY - 0.5*outerRadius)
    }
    
    func topRightOffset(inSize size: CGSize) -> CGSize {
        CGSize(width: size.width*cropRect.maxX - 0.5*outerRadius,
               height: size.height*cropRect.minY - 0.5*outerRadius)
    }
    
    func bottomLeftOffset(inSize size: CGSize) -> CGSize {
        CGSize(width: size.width*cropRect.minX - 0.5*outerRadius,
               height: size.height*cropRect.maxY - 0.5*outerRadius)
    }
    
    func bottomRightOffset(inSize size: CGSize) -> CGSize {
        CGSize(width: size.width*cropRect.maxX - 0.5*outerRadius,
               height: size.height*cropRect.maxY - 0.5*outerRadius)
    }
    
    func validX(x: CGFloat, width: CGFloat) -> CGFloat {
        min(max(x, 0), width)
    }
    
    func validY(y: CGFloat, height: CGFloat) -> CGFloat {
        min(max(y, 0), height)
    }
    
    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let height = proxy.size.height
            ZStack(alignment: .topLeading) {
                // MARK: Video
                VideoView(videoPath: $videoPath)
                
                // MARK: Points
                // Top left.
                Circle()
                    .stroke(lineWidth: 3)
                    .frame(width: outerRadius, height: outerRadius)
                    .overlay(Circle().fill().frame(width: 10, height: 10))
                    .offset(topLeftOffset(inSize: proxy.size))
                    .gesture(DragGesture()
                                .onChanged { gesture in
                                    cropRect.minX = validX(x: gesture.location.x, width: width) / width
                                    cropRect.minY = validY(y: gesture.location.y, height: height) / height
                                }
                    )
                
                // Top right.
                Circle()
                    .stroke(lineWidth: 3)
                    .frame(width: 25, height: 25)
                    .overlay(Circle().fill().frame(width: 10, height: 10))
                    .offset(topRightOffset(inSize: proxy.size))
                    .gesture(DragGesture()
                                .onChanged { gesture in
                                    cropRect.maxX = validX(x: gesture.location.x, width: width) / width
                                    cropRect.minY = validY(y: gesture.location.y, height: height) / height
                                }
                    )

                // Bottom left.
                Circle()
                    .stroke(lineWidth: 3)
                    .frame(width: 25, height: 25)
                    .overlay(Circle().fill().frame(width: 10, height: 10))
                    .offset(bottomLeftOffset(inSize: proxy.size))
                    .gesture(DragGesture()
                                .onChanged { gesture in
                                    cropRect.minX = validX(x: gesture.location.x, width: width) / width
                                    cropRect.maxY = validY(y: gesture.location.y, height: height) / height
                                }
                    )

                // Bottom right.
                Circle()
                    .stroke(lineWidth: 3)
                    .frame(width: 25, height: 25)
                    .overlay(Circle().fill().frame(width: 10, height: 10))
                    .offset(bottomRightOffset(inSize: proxy.size))
                    .gesture(DragGesture()
                                .onChanged { gesture in
                                    cropRect.maxX = validX(x: gesture.location.x, width: width) / width
                                    cropRect.maxY = validY(y: gesture.location.y, height: height) / height
                                }
                    )
                
                // MARK: Lines
                
            }
        }
    }
}

struct ParallexCropView_Previews: PreviewProvider {
    static var previews: some View {
        ParallexCropView(videoPath: .constant("/Users/zeruichen/Downloads/iOS 13 Apple Store Demo.mp4"))
    }
}
