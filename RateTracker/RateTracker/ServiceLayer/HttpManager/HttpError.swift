//
//  HttpError.swift
//  RateTracker
//
//  Created by Dmitry Ponomarenko on 31.03.2025.
//

import Foundation

public enum HttpError: Error {
    case invalidURL(urlPath: String)
    case emptyResponse(urlPath: String)
    case emptyResponseData(urlPath: String)
    case underlyingError(_ error: Error)
}

extension HttpError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidURL(let urlPath):
            return "Invalid URL" + "\n URL path: " + urlPath
        case .emptyResponse(let urlPath):
            return "Response is missing" + "\n URL: " + urlPath
        case .emptyResponseData(let urlPath):
            return "Response data is missing" + "\n URL: " + urlPath
        case .underlyingError(let error):
            return error.localizedDescription
        }
    }
}
