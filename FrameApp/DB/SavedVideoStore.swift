//
//  SavedVideoStore.swift
//  Frame
//
//  Created by Zerui Chen on 2/8/21.
//

import Tetra
import Nuke
import CoreData

class SavedVideoStore: NSObject, ObservableObject {
    
    static let shared = SavedVideoStore()
    
    @Published var savedVideos: [SavedVideo]
    
    private let fetchedResultsController: NSFetchedResultsController<SavedVideo>
        
    override init() {
        let fetchedResultsController = CDManager.getFetchResultsController(forRequest: SavedVideo.fetchRequest())
        try? fetchedResultsController.performFetch()
        savedVideos = fetchedResultsController.fetchedObjects ?? []
        self.fetchedResultsController = fetchedResultsController
        super.init()
        fetchedResultsController.delegate = self
    }
    
    /// Restart all unfinished downloads when app restarts.
    func restartDownloads() {
        for video in savedVideos where !video.isDownloaded {
            video.beginDownload()
        }
    }
    
    func addVideo(_ video: CatalogueModel.VideoItem) {
        ImagePipeline.shared.loadImage(with: video.imageURL) { result in
            switch result {
            case .failure(let error):
                NSLog("[Frame] Error downloading image \(error)")
            case .success(let response):
                CDManager.performAndSave { _ in
                    let record = SavedVideo(withName: video.name, thumbnail: response.image, remoteURL: video.videoURL)
                    record.downloadTask.download(video.videoURL, onSuccess: record.markAsDownloaded)
                }
            }
        }
    }
    
    func getVideo(withURL url: URL) -> SavedVideo? {
        fetchedResultsController.fetchedObjects?.first {
            $0.remoteURL == url
        }
    }
    
}

extension SavedVideoStore: NSFetchedResultsControllerDelegate {
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        savedVideos = controller.fetchedObjects as? [SavedVideo] ?? []
    }
    
}
