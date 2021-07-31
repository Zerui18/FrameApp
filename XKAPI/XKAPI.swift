//
//  XKAPI.swift
//  XKAPI
//
//  Created by Zerui Chen on 30/7/21.
//

import UIKit
import Combine

// MARK: Actual API
/// Struct representing the api response of a category's listing.
public struct XKListingAPIResponse: Codable {
    
    /// Struct representing each item (video) in the category.
    public struct Item: Codable {
        let vpath: String
        let ipath: String
        
        /// Display name.
        public let name: String
        /// Formatted size string.
        public let size: String
        
        /// URL to the video file.
        public var videoURL: URL {
            URL(string: vpath.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!
        }
        
        /// URL to the webp thumbnail image.
        public var imageURL: URL {
            URL(string: ipath.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case items = "wdata"
    }
    
    /// All items in this category.
    public var items: [Item]
    
}

/// The english translation for the important category names.
fileprivate let englishNames = ["首页" : "Home", "最新" : "New", "推荐" : "Hot", "随机" : "Random", "景观" : "Landscapes", "动漫" : "Anime", "游戏" : "Games", "其它" : "Abstract"]

/// The categories to be filtered out.
fileprivate let filteredNames = ["小姐姐", "再淘一下", "公告"]

/// Struct representing the api response of the root/index categories.
public struct XKIndexAPIResponse: Codable {
    
    /// Struct representing each category.
    public struct Item: Codable {
        public let name: String
        let path: String

        /// The property that should be accessed for the displayed name.
        public var displayName: String {
            return englishNames[name] ?? name
        }
        
        /// The URL to this category's listing.
        public var url: URL? {
            return URL(string: path.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
        }
        
        /// Fetch the listing of this category with a completion handler.
        public func fetchListing() -> AnyPublisher<XKListingAPIResponse, Error> {
            fetchAndDecode(from: url!)
                .map { (response: XKListingAPIResponse) in
                    var response = response
                    if response.items.first?.size == "32.78MB" {
                        response.items.remove(at: 0)
                    }
                    return response
                }
                .eraseToAnyPublisher()
        }
    }
    
    public enum CodingKeys: String, CodingKey {
        case items = "item", allURL = "all"
    }
    
    /// All categories.
    public private(set) var items: [Item]
    /// URL to the "all" category's listing.
    public let allURL: String
    
    /// Convenience method to fetch a new response given a completion callback, optionally specifying an overriding api url.
    public static func fetch(from url: URL = URL(string: "http://api-20200527.xkspbz.com/admin-n.json")!) -> AnyPublisher<XKIndexAPIResponse, Error> {
        fetchAndDecode(from: url)
            // Apply filter.
            .map { (response: XKIndexAPIResponse) in
                var response = response
                response.items.removeAll { filteredNames.contains($0.name) }
                return response
            }
            .eraseToAnyPublisher()
    }
    
}
