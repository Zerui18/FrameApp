//
//  VideoRecord.swift
//  Frame
//
//  Created by Zerui Chen on 15/7/21.
//

import UIKit
import CoreData
import AVFoundation
import Tetra

fileprivate let bcFormatter = ByteCountFormatter()

@objc(VideoRecord)
class VideoRecord: NSManagedObject {
    
    convenience init(withName name: String, remoteURL: URL? = nil, videoURL: URL? = nil, thumbnail: UIImage? = nil) {
        self.init(entity: VideoRecord.entity(), insertInto: persistentContainer.viewContext)
        self.name = name
        self.remoteURL = remoteURL
        self.videoURL = videoURL ?? rootDocumentsFolder.appendingPathComponent("videos/\(name).mp4")
        self.size = Int64(videoURL?.fileSize ?? 0)
        self.timestamp = Date()
        if let image = thumbnail {
            // If provided with thumbnail we're good to go.
            self._thumbnailImage = image
            self.thumbnailData = image.pngData()
        }
    }
    
    /// The decoded image from thumbnailData. Cached.
    private lazy var _thumbnailImage: UIImage? = thumbnailData.flatMap(UIImage.init(data:))
    var thumbnailImage: UIImage? {
        if let image = _thumbnailImage {
            return image
        }
        self.processVideo()
        return nil
    }
    
    /// The size of the video in text.
    lazy var sizeString: String = bcFormatter.string(fromByteCount: size)
    
    /// The download task for this video.
    lazy var downloadTask = Tetra.shared.downloadTask(forId: self.name, dstURL: self.videoURL)
    
    /// To be called after the local video file is available.
    func processVideo() {
        guard isDownloaded else { return }
        // Create thumbnail.
        AVAsset(url: videoURL).generateThumbnail { image in
            guard let image = image else {
                return
            }
            self._thumbnailImage = image
            self.thumbnailData = image.pngData()
        }
        // Update size.
        self.size = Int64(videoURL.fileSize)
        self.sizeString = bcFormatter.string(fromByteCount: self.size)
    }
}

// MARK: CoreData Attributes
extension VideoRecord {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<VideoRecord> {
        return NSFetchRequest<VideoRecord>(entityName: "VideoRecord")
    }

    @NSManaged public var isDownloaded: Bool
    @NSManaged public var remoteURL: URL?
    @NSManaged public var name: String
    @NSManaged public var size: Int64
    @NSManaged public var thumbnailData: Data?
    @NSManaged public var timestamp: Date
    @NSManaged public var videoURL: URL
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
