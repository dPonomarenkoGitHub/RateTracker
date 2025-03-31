//
//  HttpConstants.swift
//  RateTracker
//
//  Created by Dmitry Ponomarenko on 31.03.2025.
//

import Foundation

public enum HttpConstants {
    public enum Method: String {
        case GET
        case POST
    }

    public enum Path: String {
        case latest = "/api/latest.json"
        case currencies = "/api/currencies.json"
    }

    public enum Host: String {
        case exchangeRates = "openexchangerates.org"
    }

    public enum Scheme: String {
        case http = "http"
        case https = "https"
    }

    public static func buildAuthHeader(with token: String) -> [String: String] {
        ["Authorization": "Token \(token)"]
    }
}
