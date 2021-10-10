//
//  HTTPClient.swift
//  PracticalExample
//
//  Created by Andrew Marmion on 10/10/2021.
//

import Combine
import Foundation

public protocol HTTPClient {
    func get(from url: URL) -> AnyPublisher<(data: Data, response: HTTPURLResponse), Error>
}

public class URLSessionHTTPClient: HTTPClient {
    private let session: URLSession

    public init(session: URLSession = .shared) {
        self.session = session
    }

    private struct InvalidURLResponse: Error {}

    public func get(from url: URL) -> AnyPublisher<(data: Data, response: HTTPURLResponse), Error> {
        session.dataTaskPublisher(for: url)
            .tryMap { data, urlResponse -> (Data, HTTPURLResponse) in
                if let response = urlResponse as? HTTPURLResponse {
                    return (data, response)
                } else {
                    throw InvalidURLResponse()
                }
            }
            .eraseToAnyPublisher()
    }
}
