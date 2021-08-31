//
//  RecordsModel.swift
//  Frame
//
//  Created by Zerui Chen on 2/8/21.
//

import Tetra
import Nuke
import CoreData

class RecordsModel: ObservableObject {
    
    static let shared = RecordsModel()
    
    private let fetchedResultsController = NSFetchedResultsController(fetchRequest: VideoRecord.fetchRequest(), managedObjectContext: persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        
    private init() {
        // Force initial fetch.
        try! fetchedResultsController.performFetch()
        let allRecords = fetchedResultsController.fetchedObjects ?? []
        // Restart all unfinished downloads when app restarts.
        for record in allRecords where !record.isDownloaded {
            record.beginDownload()
        }
    }
    
    func downloadVideo(withItem item: CatalogueModel.Item) {
        ImagePipeline.shared.loadImage(with: item.imageURL) { result in
            switch result {
            case .failure(let error):
                NSLog("[Frame] Error downloading image \(error)")
            case .success(let response):
                let record = VideoRecord(withName: item.name, thumbnail: response.image, remoteURL: item.videoURL)
                try! persistentContainer.viewContext.save()
                record.downloadTask.download(item.videoURL, onSuccess: record.markAsDownloaded)
            }
        }
    }
    
    func record(forVideoURL url: URL) -> VideoRecord? {
        fetchedResultsController.fetchedObjects?.first {
            $0.remoteURL == url
        }
    }
    
}