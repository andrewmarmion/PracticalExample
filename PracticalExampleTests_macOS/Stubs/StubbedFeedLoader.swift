//
//  StubbedFeedLoader.swift
//  PracticalExampleTests
//
//  Created by Andrew Marmion on 10/10/2021.
//

import PracticalExample
import Combine
import Foundation

final class StubbedFeedLoader: FeedLoader {

    let stubbedResponse: AnyPublisher<(articles: [FeedItem], videos: [FeedItem]), Error>

    init(stubbedResponse: AnyPublisher<(articles: [FeedItem], videos: [FeedItem]), Error>) {
        self.stubbedResponse = stubbedResponse
    }

    func load() -> AnyPublisher<(articles: [FeedItem], videos: [FeedItem]), Error> {
        stubbedResponse
    }

    static func publishesErrorResponse() -> AnyPublisher<(articles: [FeedItem], videos: [FeedItem]), Error> {
        Just(())
            .tryMap { throw anyNSError() }
            .eraseToAnyPublisher()
    }

    static func publishesSuccessResponse(articles: [FeedItem] = [], videos: [FeedItem] = []) -> AnyPublisher<(articles: [FeedItem], videos: [FeedItem]), Error> {
        Just((articles, videos)).mapError{ _ in anyNSError() }.eraseToAnyPublisher()
    }
}
