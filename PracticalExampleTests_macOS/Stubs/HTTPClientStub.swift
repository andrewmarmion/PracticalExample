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

    private(set) var requestedURLs: [URL] = []

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

    static func publishesError(error: Error) -> AnyPublisher<(data: Data, response: HTTPURLResponse), Error> {
        Just(())
            .tryMap { throw error }
            .eraseToAnyPublisher()
    }

    static func publishesDataResponse(data: Data, response: HTTPURLResponse) -> AnyPublisher<(data: Data, response: HTTPURLResponse), Error>  {
        Just((data, response)).mapError{ _ in anyNSError() }.eraseToAnyPublisher()
    }
}
