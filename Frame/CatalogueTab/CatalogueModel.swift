//
//  CatalogueModel.swift
//  Frame
//
//  Created by Zerui Chen on 30/7/21.
//

import UIKit
import Combine
import XKAPI

class CatalogueModel: ObservableObject {
    
    struct Item: GalleryGridItemRepresentable {
        public var id: URL { videoURL }
        /// Display name.
        public let name: String
        /// Formatted size string.
        public let sizeString: String
        /// URL to the video file.
        public var videoURL: URL
        /// URL to the webp thumbnail image.
        public var imageURL: URL
        
        public let image: UIImage? = nil
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
            .combineLatest($selectedCategoryIndex.setFailureType(to: Error.self))
            .flatMap { indexResponse, selectedCategoryIndex in
                return indexResponse.items[selectedCategoryIndex]
                    .fetchListing()
                    .eraseToAnyPublisher()
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case let .failure(error) = completion {
                    self?.error = error
                }
            } receiveValue: { [weak self] listingResponse in
                self?.listingItems = listingResponse.items.map {
                    .init(name: $0.name, sizeString: $0.size, videoURL: $0.videoURL, imageURL: $0.imageURL)
                }
            }
    }
    
}
