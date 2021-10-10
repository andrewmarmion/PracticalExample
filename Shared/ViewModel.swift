//
//  ViewModel.swift
//  PracticalExample
//
//  Created by Andrew Marmion on 09/10/2021.
//

import Combine
import SwiftUI

enum SelectedList: String, CaseIterable, Identifiable {
    case all
    case articles
    case videos

    var id: String {
        self.rawValue
    }

    var title: String {
        self.rawValue.capitalized
    }
}

enum LoadingState: Equatable {
    case empty
    case loading
    case loaded
    case error(Error)

    static func == (lhs: LoadingState, rhs: LoadingState) -> Bool {
        switch (lhs, rhs) {
        case (.loading, .loading): return true
        case (.loaded, .loaded): return true
        case (.error, .error): return true
        case(.empty, .empty): return true
        default: return false
        }
    }
}

class WrappedFeedLoader: FeedLoader {

    private let articlesURL = URL(string: "https://raw.githubusercontent.com/raywenderlich/ios-interview/master/Practical%20Example/articles.json")!

    private let videosURL = URL(string: "https://raw.githubusercontent.com/raywenderlich/ios-interview/master/Practical%20Example/videos.json")!

    let remoteFeedLoader: RemoteFeedLoader

    init(client: HTTPClient = URLSessionHTTPClient()) {
        remoteFeedLoader = RemoteFeedLoader(articleURL: articlesURL, videoURL: videosURL, client: client)
    }


    func load() -> AnyPublisher<(articles: [FeedItem], videos: [FeedItem]), Error> {
        remoteFeedLoader.load()
    }
}

class ViewModel: ObservableObject {

    @Published var state: LoadingState = .empty
    @Published var selectedList: SelectedList = .all
    @Published var items: [FeedItem] = []

    private var articles: [FeedItem] = []
    private var videos: [FeedItem] = []
    private var both: [FeedItem] = []

    private var cancellables = Set<AnyCancellable>()
    private var feedLoader: FeedLoader

    init(feedLoader: FeedLoader = WrappedFeedLoader()) {
        self.feedLoader = feedLoader
    }

    func load() {
        self.state = .loading

        feedLoader.load()
            .receive(on: RunLoop.main)
            .sink { completion in
                if case let .failure(error) = completion {
                    self.state = .error(error)
                }
            } receiveValue: { [weak self] articles, videos in
                guard let self = self else { return }

                // make sure the articles and videos are sorted so we only have to show perform the sort once
                self.articles = articles.dateSorted()
                self.videos = videos.dateSorted()
                self.both = (articles + videos).dateSorted()
                self.state = .loaded

                // reset the selectedList so that we can refresh what is shown on screen
                self.selectedList = self.selectedList
            }
            .store(in: &cancellables)

        $selectedList
            .sink { [weak self] selection in
                self?.handle(selectedList: selection)
            }
            .store(in: &cancellables)
    }

    private func handle(selectedList: SelectedList) {
        switch selectedList {
        case .all: items = both
        case .articles: items = articles
        case .videos: items = videos
        }
    }
}

private extension Array where Element == FeedItem {
    func dateSorted() -> [Element] {
        self.sorted { first, second in
            first.releasedDate < second.releasedDate
        }
    }
}
