//
//  MainQueueRemoteFeedLoader.swift
//  PracticalExample
//
//  Created by Andrew Marmion on 11/10/2021.
//

import Combine
import Foundation

class MainQueueRemoteFeedLoader: FeedLoader {

    // We could technically pass in these URLs but for ease we'll just hard code them here
    private let articlesURL = URL(string: "https://raw.githubusercontent.com/raywenderlich/ios-interview/master/Practical%20Example/articles.json")!

    private let videosURL = URL(string: "https://raw.githubusercontent.com/raywenderlich/ios-interview/master/Practical%20Example/videos.json")!

    let remoteFeedLoader: RemoteFeedLoader

    init(client: HTTPClient = URLSessionHTTPClient()) {
        remoteFeedLoader = RemoteFeedLoader(articleURL: articlesURL, videoURL: videosURL, client: client)
    }

    func load() -> AnyPublisher<(articles: [FeedItem], videos: [FeedItem]), Error> {
        remoteFeedLoader
            .load()
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()

    }
}
