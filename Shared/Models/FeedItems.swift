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
    let description: String // is html in the videos, do we need to handle that?
    let content_type: ContentType
    let card_artwork_url: URL
    let released_at: Date
}

enum ContentType: String, Decodable {
    case article
    case video = "collection"
}
