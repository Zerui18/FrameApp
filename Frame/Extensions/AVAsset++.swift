//
//  AVAsset++.swift
//  Frame
//
//  Created by Zerui Chen on 7/8/21.
//

import AVFoundation
import UIKit

// Taken from: https://stackoverflow.com/a/55531065
extension AVAsset {
    func generateThumbnail(completion: @escaping (UIImage?) -> Void) {
        let imageGenerator = AVAssetImageGenerator(asset: self)
        let time = CMTime(seconds: 0.0, preferredTimescale: 600)
        let times = [NSValue(time: time)]
        imageGenerator.generateCGImagesAsynchronously(forTimes: times) { _, image, _, _, _ in
            if let image = image {
                completion(UIImage(cgImage: image))
            } else {
                completion(nil)
            }
        }
    }
    
    func generateThumbnail() throws -> UIImage {
        let imageGenerator = AVAssetImageGenerator(asset: self)
        let time = CMTime(seconds: 0.0, preferredTimescale: 600)
        return UIImage(cgImage: try imageGenerator.copyCGImage(at: time, actualTime: nil))
    }
    
    static func generateThumbnail(fromAssetAtURL url: URL) throws -> UIImage {
        try AVAsset(url: url).generateThumbnail()
    }
}
