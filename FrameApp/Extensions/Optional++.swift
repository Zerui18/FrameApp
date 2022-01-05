//
//  Optional++.swift
//  FrameApp
//
//  Created by Zerui Chen on 4/1/22.
//

import Foundation

/// Helper protocol used to check if a generic type is Optional and some other checks.
protocol OptionalProtocol {
    var wrappedType: Any.Type {
        get
    }
    var isNil: Bool {
        get
    }
    
    mutating func unset()
}

extension Optional: OptionalProtocol {
    var wrappedType: Any.Type {
        Wrapped.self
    }
    var isNil: Bool {
        self == nil
    }
    mutating func unset() {
        self = .none
    }
}
