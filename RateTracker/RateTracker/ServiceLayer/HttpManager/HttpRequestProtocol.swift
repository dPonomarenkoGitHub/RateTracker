//
//  HttpRequestProtocol.swift
//  RateTracker
//
//  Created by Dmitry Ponomarenko on 31.03.2025.
//

import Foundation

public protocol HttpRequestProtocol {
    var scheme: String { get }
    var host: String { get }
    var path: String { get }
    var parameters: [URLQueryItem] { get }
    var body: [String: Any] { get }
    var method: HttpConstants.Method { get }
    var httpAdditionalHeaders: [String: String] { get }
    var keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy { get }
}

public extension HttpRequestProtocol {
    var keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy {
        .useDefaultKeys
    }
}
