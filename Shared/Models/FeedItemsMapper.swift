//
//  FeedItemsMapper.swift
//  PracticalExampleTests
//
//  Created by Andrew Marmion on 10/10/2021.
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
