//
//  HttpManager.swift
//  RateTracker
//
//  Created by Dmitry Ponomarenko on 31.03.2025.
//

import Foundation

public enum HttpManager {
    public static func request<T: Decodable>(router: HttpRequestProtocol, completion: @escaping (Result<T, Error>) -> Void) {
        var components = URLComponents()
        components.scheme = router.scheme
        components.host = router.host
        components.path = router.path
        if !router.parameters.isEmpty {
            components.queryItems = router.parameters
        }

        guard let url = components.url else {
            completion(.failure(HttpError.invalidURL(urlPath: router.path)))
            return
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = router.method.rawValue

        if !router.body.isEmpty {
            do {
                urlRequest.httpBody = try JSONSerialization.data(withJSONObject: router.body, options: .prettyPrinted)
                urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            } catch {
                completion(.failure(error))
                return
            }
        }

        let config = URLSessionConfiguration.default
        var headers = router.httpAdditionalHeaders
        config.httpAdditionalHeaders = headers

        let session = URLSession(configuration: config)

        let dataTask = session.dataTask(with: urlRequest) { data, response, error in
            guard error == nil else {
                completion(.failure(error!))
                return
            }
            guard response != nil else {
                completion(.failure(HttpError.emptyResponse(urlPath: url.absoluteString)))
                return
            }
            guard let responseData = data else {
                completion(.failure(HttpError.emptyResponseData(urlPath: url.absoluteString)))
                return
            }
            do {
                /*
                if let responseString = String(data: responseData, encoding: .utf8) {
                    debugPrint(responseString)
                }
                */
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = router.keyDecodingStrategy
                let responseObject = try decoder.decode(T.self, from: responseData)
                completion(.success(responseObject))
            } catch {
                completion(.failure(error))
            }
        }
        dataTask.resume()
    }
}
