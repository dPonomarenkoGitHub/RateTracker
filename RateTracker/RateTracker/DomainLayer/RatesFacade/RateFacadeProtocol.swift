//
//  RateFacadeProtocol.swift
//  RateTracker
//
//  Created by Dmitry Ponomarenko on 31.03.2025.
//

import Foundation
import Combine

protocol RateFacadeProtocol {
    func getRates()
    
    func getRemoteCurrencies() -> AnyPublisher<[TrackedCurrency], Never>
    
    func getLocalCurrencies() -> AnyPublisher<[TrackedCurrency], Never>
}
