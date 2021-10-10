//
//  HTTPClientStub.swift
//  PracticalExampleTests
//
//  Created by Andrew Marmion on 10/10/2021.
//

import PracticalExample
import Combine
import Foundation

final class HTTPClientStub: HTTPClient {

    var requestedURLs: [URL] = []

    var stubbedResponse: (AnyPublisher<(data: Data, response: HTTPURLResponse), Error>)?

    init(stubbedResponse: (AnyPublisher<(data: Data, response: HTTPURLResponse), Error>)? = nil) {
        self.stubbedResponse = stubbedResponse
    }

    func get(from url: URL) -> AnyPublisher<(data: Data, response: HTTPURLResponse), Error> {
        requestedURLs.append(url)

        if let stubbedResponse = stubbedResponse {
            return stubbedResponse
        }
        return Just((anyData(), anyHTTPURLResponse())).mapError{ _ in anyNSError() }.eraseToAnyPublisher()
    }
}
