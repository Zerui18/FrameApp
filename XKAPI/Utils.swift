//
//  Utils.swift
//  XKAPI
//
//  Created by Zerui Chen on 30/7/21.
//

import Foundation
import Combine

// MARK: Crypto Configs
fileprivate let iv = Data(repeating: 0, count: 16)
fileprivate let key = sha256(data: "9i98X0OxViK1oJhyHnOAUKRMAdHy8jy2Ik8Xv6xJ5A4oRDLD".data(using: .ascii)!)
fileprivate let aes = AES(key: key, iv: iv)

fileprivate func decryptAndUnzip(data: Data) -> Data? {
    Data(base64Encoded: data)
        .flatMap {
            aes.decrypt(data: $0)
        }
        .flatMap {
            Data(base64Encoded: $0)
        }.flatMap {
            try? $0.gunzipped()
        }
}

func fetchAndDecode<T: Codable>(from url: URL) -> AnyPublisher<T, Error> {
    URLSession.shared.dataTaskPublisher(for: url)
        .tryMap {
            if let decrypted = decryptAndUnzip(data: $0.data) {
                return decrypted
            }
            throw NSError(domain: "com.zx02.frame", code: 123, userInfo: nil)
        }
        .decode(type: T.self, decoder: JSONDecoder())
        .eraseToAnyPublisher()
}
