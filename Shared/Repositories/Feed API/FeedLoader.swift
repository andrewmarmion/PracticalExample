//
//  FeedLoader.swift
//  PracticalExample
//
//  Created by Andrew Marmion on 10/10/2021.
//

import Combine
import Foundation

public protocol FeedLoader {
    func load() -> AnyPublisher<(articles: [FeedItem], videos: [FeedItem]), Error>
}
