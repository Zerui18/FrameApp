//
//  VideoRecord.swift
//  Frame
//
//  Created by Zerui Chen on 15/7/21.
//

import UIKit
import CoreData
import AVFoundation

fileprivate let bcFormatter = ByteCountFormatter()

@objc(VideoRecord)
class VideoRecord: NSManagedObject {
    
    convenience init(withName name: String, videoURL: URL, thumbnail: UIImage? = nil) {
        self.init(entity: VideoRecord.entity(), insertInto: persistentContainer.viewContext)
        self.name = name
        self.videoURL = videoURL
        self.size = Int64(videoURL.fileSize)
        self.timestamp = Date()
        if let image = thumbnail {
            // If provided with thumbnail we're good to go.
            self.thumbnailImage = image
            self.thumbnailData = image.pngData()
        }
        else {
            // Otherwise we generate a thumbnail from the start of the video.
            AVAsset(url: videoURL).generateThumbnail { image in
                guard let image = image else {
                    return
                }
                self.thumbnailImage = image
                self.thumbnailData = image.pngData()
            }
        }
    }
    
    /// The decoded image from thumbnailData. Cached.
    lazy var thumbnailImage: UIImage = thumbnailData.flatMap(UIImage.init(data:)) ?? .init()
    
    lazy var sizeString: String = bcFormatter.string(fromByteCount: size)
    
}

// Taken from: https://stackoverflow.com/a/55531065
extension AVAsset {
    func generateThumbnail(completion: @escaping (UIImage?) -> Void) {
        DispatchQueue.global().async {
            let imageGenerator = AVAssetImageGenerator(asset: self)
            let time = CMTime(seconds: 0.0, preferredTimescale: 600)
            let times = [NSValue(time: time)]
            imageGenerator.generateCGImagesAsynchronously(forTimes: times, completionHandler: { _, image, _, _, _ in
                if let image = image {
                    completion(UIImage(cgImage: image))
                } else {
                    completion(nil)
                }
            })
        }
    }
}
