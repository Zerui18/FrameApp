//
//  SavedVideo.swift
//  Frame
//
//  Created by Zerui Chen on 15/7/21.
//

import UIKit
import CoreData
import AVFoundation
import Tetra

fileprivate let bcFormatter = ByteCountFormatter()

@objc(SavedVideo)
class SavedVideo: NSManagedObject {
    
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
        NSEntityDescription.entity(forEntityName: "SavedVideo", in: CDManager.moc)!
    }
    
    convenience init(withName name: String, thumbnail: UIImage, remoteURL: URL? = nil, videoURL: URL? = nil) {
        self.init(entity: SavedVideo.entity(), insertInto: CDManager.moc)
        self.name = name
        self.isDownloaded = remoteURL == nil
        self.thumbnailData = thumbnail.pngData()
        self.remoteURL = remoteURL
        self.localURL = videoURL ?? Paths.rootDocumentsFolder.appendingPathComponent("videos/\(name).mp4")
        self.timestamp = Date()
    }
    
    func delete() {
        Tetra.shared.remove(task: downloadTask)
        try? FileManager.default.removeItem(at: localURL)
        CDManager.performAndSave { moc in
            moc.delete(self)
        }
    }
    
    // MARK: Download
    func markAsDownloaded() {
        CDManager.performAndSave { _ in
            self.isDownloaded = true
            self.size = self.localURL.fileSize
            self.sizeString = bcFormatter.string(fromByteCount: Int64(self.size))
        }
    }
    
    func beginDownload() {
        downloadTask.download(remoteURL!, onSuccess: markAsDownloaded)
    }
}

// MARK: CoreData Attributes
extension SavedVideo {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<SavedVideo> {
        let request = NSFetchRequest<SavedVideo>(entityName: "SavedVideo")
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
