//
//  URLSession+Tetra.swift
//  Tetra
//
//  Created by Zerui Chen on 14/7/20.
//

import Foundation

extension URLSession {
    
    /// The internal URLSession that Tetra uses.
    static let tetra = URLSession(configuration: .default)
    
}
