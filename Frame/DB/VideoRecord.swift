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
    
    lazy var size: UInt64 = {
        localURL.fileSize
    }()
    
    /// The size of the video in text.
    lazy var sizeString: String = bcFormatter.string(fromByteCount: Int64(size))
    
    /// The decoded image from thumbnailData.
    lazy var thumbnailImage: UIImage = .init(data: thumbnailData!) ?? .init()
    
    /// The download task for this video.
    lazy var downloadTask = Tetra.shared.downloadTask(forId: self.name, dstURL: self.localURL)
    
    // MARK: CoreData
    override class func entity() -> NSEntityDescription {
        NSEntityDescription.entity(forEntityName: "VideoRecord", in: persistentContainer.viewContext)!
    }
    
    convenience init(withName name: String, thumbnail: UIImage, remoteURL: URL? = nil, videoURL: URL? = nil) {
        self.init(entity: VideoRecord.entity(),
                  insertInto: persistentContainer.viewContext)
        self.name = name
        self.isDownloaded = remoteURL == nil
        self.thumbnailData = thumbnail.pngData()
        self.remoteURL = remoteURL
        self.localURL = videoURL ?? rootDocumentsFolder.appendingPathComponent("videos/\(name).mp4")
        self.timestamp = Date()
    }
    
    func delete() {
        Tetra.shared.remove(task: downloadTask)
        try? FileManager.default.removeItem(at: localURL)
        persistentContainer.viewContext.delete(self)
        try? persistentContainer.viewContext.save()
    }
    
    // MARK: Download
    func markAsDownloaded() {
        self.isDownloaded = true
        self.size = localURL.fileSize
        self.sizeString = bcFormatter.string(fromByteCount: Int64(size))
        try? persistentContainer.viewContext.save()
    }
    
    func beginDownload() {
        downloadTask.download(remoteURL!, onSuccess: markAsDownloaded)
    }
}

// MARK: CoreData Attributes
extension VideoRecord {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<VideoRecord> {
        let request = NSFetchRequest<VideoRecord>(entityName: "VideoRecord")
        request.sortDescriptors = [.init(key: "timestamp", ascending: false)]
        return request
    }

    @NSManaged public var name: String
    @NSManaged public var isDownloaded: Bool
    @NSManaged public var remoteURL: URL?
    @NSManaged public var thumbnailData: Data?
    @NSManaged public var timestamp: Date
    @NSManaged public var localURL: URL
}
