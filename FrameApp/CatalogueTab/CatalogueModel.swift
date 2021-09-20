//
//  CatalogueModel.swift
//  Frame
//
//  Created by Zerui Chen on 30/7/21.
//

import UIKit
import Combine
import XKAPI
import Tetra

class CatalogueModel: ObservableObject {
    
    class Item: GalleryGridItemRepresentable {
        
        init(name: String, sizeString: String, videoURL: URL, imageURL: URL, image: UIImage? = nil) {
            self.name = name
            self.sizeString = sizeString
            self.videoURL = videoURL
            self.imageURL = imageURL
            self.image = image
        }
        
        public var id: String { name }
        /// Display name.
        public let name: String
        /// Formatted size string.
        public let sizeString: String
        /// URL to the video file.
        public var videoURL: URL
        /// URL to the webp thumbnail image.
        public var imageURL: URL
        
        public let image: UIImage?
        
        let isLocal: Bool = false
        
        lazy var downloadTask: TTask = {
            Tetra.shared.downloadTask(forId: name, dstURL: Paths.urlFor(videoName: name))
        }()
        
        static func ==(_ a: Item, _ b: Item) -> Bool {
            a.id == b.id
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
    }
    
    static let shared = CatalogueModel()
    
    // MARK: Published
    @Published var categoryNames = [String]()
    @Published var listingItems = [Item]()
    @Published var error: Error?
    @Published var selectedCategoryIndex: Int = 0
    
    var selectedCategoryName: String {
        categoryNames.isEmpty ? "":categoryNames[selectedCategoryIndex]
    }
    
    private var handle: AnyCancellable?
    private let refreshSubject = PassthroughSubject<Void, Error>()
    private var refreshCompletedHandler: (() -> Void)?
    
    private init() {}
    
    func fetchIndexIfNecessary() {
        guard handle == nil else { return }
        
        handle = XKIndexAPIResponse.fetch()
            .map { [weak self] response -> XKIndexAPIResponse in
                DispatchQueue.main.async {
                    self?.categoryNames = response.items.map { $0.displayName }
                }
                return response
            }
            .combineLatest($selectedCategoryIndex.setFailureType(to: Error.self), refreshSubject)
            .flatMap { indexResponse, selectedCategoryIndex, _ in
                indexResponse.items[selectedCategoryIndex]
                    .fetchListing()
                    .eraseToAnyPublisher()
            }
            .receive(on: RunLoop.main)
            .mapError { error -> Error in
                self.error = error
                self.refreshCompletedHandler?()
                return error
            }
            .sink { _ in } receiveValue: { listingResponse in
                self.listingItems = listingResponse.items.map {
                    .init(name: $0.name, sizeString: $0.sizeString, videoURL: $0.videoURL, imageURL: $0.imageURL)
                }
                self.refreshCompletedHandler?()
            }
        
        refreshSubject.send()
    }
    
    func refreshListing(with refreshCompletedHandler: @escaping ()->Void) {
        self.refreshCompletedHandler = refreshCompletedHandler
        refreshSubject.send()
    }
    
}
