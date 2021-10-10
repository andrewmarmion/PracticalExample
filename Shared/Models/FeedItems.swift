//
//  FeedItems.swift
//  PracticalExample
//
//  Created by Andrew Marmion on 09/10/2021.
//

import Foundation

enum FeedItemsMapper {
    struct Root: Decodable {
        let data: [RemoteFeedItem]
    }

    private static var OK_200: Int { 200 }

    static func map(_ data: Data, from response: HTTPURLResponse) throws -> [RemoteFeedItem] {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(DateFormatter.customDate)
        guard response.statusCode == OK_200,
              let root = try? decoder.decode(Root.self, from: data) else {
                  throw RemoteFeedLoader.Error.invalidData
              }
        return root.data
    }
}

struct FeedItems: Decodable {
    let data: [RemoteFeedItem]
}

struct RemoteFeedItem: Decodable, Identifiable {
    let id: String
    let type: String
    let attributes: ItemAttributes
}

struct ItemAttributes: Decodable {
    let name: String
    let description: String
    let contentType: ContentType
    let cardArtworkURL: URL
    let releasedAt: Date

    enum CodingKeys: String, CodingKey {
        case name
        case description
        case contentType = "content_type"
        case cardArtworkURL = "card_artwork_url"
        case releasedAt = "released_at"
    }
}

enum ContentType: String, Decodable {
    case article
    case video = "collection"
}
