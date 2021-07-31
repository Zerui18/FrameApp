//
//  Nuke+WebP.swift
//  Frame
//
//  Created by Zerui Chen on 31/7/21.
//

import Foundation
import WebP
import Nuke

// MARK: WebP + Data
private let fileHeaderIndex: Int = 12
private let fileHeaderPrefix = "RIFF"
private let fileHeaderSuffix = "WEBP"
fileprivate extension Data {

    var isWebPFormat: Bool {
        guard fileHeaderIndex < count else { return false }
        let endIndex = index(startIndex, offsetBy: fileHeaderIndex)
        let data = subdata(in: startIndex..<endIndex)
        let string = String(data: data, encoding: .ascii) ?? ""
        return string.hasPrefix(fileHeaderPrefix) && string.hasSuffix(fileHeaderSuffix)
    }

}

// MARK: WebP + Nuke
public class WebPImageDecoder: Nuke.ImageDecoding {

    private lazy var decoder: WebPDecoder = .init()

    public init() {
    }

    public func decode(_ data: Data) -> ImageContainer? {
        guard data.isWebPFormat, let image = _decode(data) else { return nil }
        return ImageContainer(image: image)
    }

}

// MARK: - check webp format data.
extension WebPImageDecoder {

    public static func enable() {
        Nuke.ImageDecoderRegistry.shared.register { (context) -> ImageDecoding? in
            WebPImageDecoder.enable(context: context)
        }
    }

    public static func enable(context: Nuke.ImageDecodingContext) -> Nuke.ImageDecoding? {
        context.data.isWebPFormat ? WebPImageDecoder() : nil
    }

}

// MARK: - private
private let _queue = DispatchQueue(label: "com.zx02.nuke_webp.DataDecoder")

extension WebPImageDecoder {

    private func _decode(_ data: Data) -> PlatformImage? {
        _queue.sync {
            try? decoder.decode(toUImage: data, options: .init())
        }
    }

}
