//
//  GetCurrenciesRequest.swift
//  RateTracker
//
//  Created by Dmitry Ponomarenko on 31.03.2025.
//

import Foundation

struct GetCurrenciesRequest: HttpRequestProtocol {
    var scheme: String = HttpConstants.Scheme.https.rawValue
    var host: String = HttpConstants.Host.exchangeRates.rawValue
    var path: String = HttpConstants.Path.currencies.rawValue
    var parameters: [URLQueryItem] = []
    var body: [String : Any] = [:]
    var method: HttpConstants.Method = .GET
    var httpAdditionalHeaders: [String : String]
    
    init(token: String) {
        httpAdditionalHeaders = HttpConstants.buildAuthHeader(with: token)
    }
}
