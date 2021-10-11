//
//  RemoteFeedLoader.swift
//  PracticalExample
//
//  Created by Andrew Marmion on 11/10/2021.
//

import Combine
import Foundation

public final class RemoteFeedLoader: FeedLoader {

    private let articleURL: URL
    private let videoURL: URL
    private let client: HTTPClient

    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }

    public init(articleURL: URL, videoURL: URL, client: HTTPClient) {
        self.articleURL = articleURL
        self.videoURL = videoURL
        self.client = client
    }

    public func load() -> AnyPublisher<(articles: [FeedItem], videos: [FeedItem]), Swift.Error> {
        let articlePublisher = createPublisher(for: articleURL)
        let videoPublisher = createPublisher(for: videoURL)

        return articlePublisher.combineLatest(videoPublisher)
            .tryMap { ($0.toModels(), $1.toModels()) }
            .eraseToAnyPublisher()
    }

    private func createPublisher(for url: URL) -> AnyPublisher<[RemoteFeedItem], Swift.Error> {
        return client.get(from: url)
            .tryMap { try FeedItemsMapper.map($0.data, from: $0.response) }
            .eraseToAnyPublisher()
    }
}

// Convert [RemoteFeedItem] to [FeedItem]
private extension Array where Element == RemoteFeedItem {
    func toModels() -> [FeedItem] {

        func getImageName(for contentType: ContentType) -> String {
            switch contentType {
            case .article:
                return "doc.text"
            case .video:
                return "film"
            }
        }

        return map {
            FeedItem(
                id: $0.id,
                name: $0.attributes.name,
                description: $0.attributes.description,
                imageURL: $0.attributes.cardArtworkURL,
                releasedDateString: $0.attributes.releasedAt.display(),
                releasedDate: $0.attributes.releasedAt,
                itemTypeImage: getImageName(for: $0.attributes.contentType)
            )
        }
    }
}
