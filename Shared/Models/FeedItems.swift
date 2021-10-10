//
//  FeedItems.swift
//  PracticalExample
//
//  Created by Andrew Marmion on 09/10/2021.
//

import Foundation

struct FeedItems: Decodable {
    let data: [FeedItem]
}

struct FeedItem: Decodable, Identifiable {
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
