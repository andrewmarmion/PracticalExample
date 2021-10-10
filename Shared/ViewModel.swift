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

enum LoadingState {
    case loading
    case loaded
    case error(Error)
}

class ViewModel: ObservableObject {

    @Published var state: LoadingState = .loading
    @Published var selectedList: SelectedList = .all
    @Published var items: [DisplayItem] = []

    private var articles: [DisplayItem] = []
    private var videos: [DisplayItem] = []
    private var both: [DisplayItem] = []

    private var cancellables = Set<AnyCancellable>()

    init() {
        load()
    }

    func load() {
        self.state = .loading
        let articlesURL = URL(string: "https://raw.githubusercontent.com/raywenderlich/ios-interview/master/Practical%20Example/articles.json")!

        let videosURL = URL(string: "https://raw.githubusercontent.com/raywenderlich/ios-interview/master/Practical%20Example/videos.json")!

        let articlePublisher = publisher(for: articlesURL)
        let videoPublisher = publisher(for: videosURL)

        articlePublisher
            .combineLatest(videoPublisher)
            .receive(on: DispatchQueue.main)
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

    private func publisher(for url: URL) -> AnyPublisher<[DisplayItem], Error> {
        // We should be injeting this so that we can use any type of dataTaskPublisher
        URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { $0.data }
            .decode(type: FeedItems.self, decoder: feedItemDecoder())
            .map { $0.data.map(Self.mapToDisplayItem) }
            .eraseToAnyPublisher()
    }

    private func handle(selectedList: SelectedList) {
        switch selectedList {
        case .all: items = both
        case .articles: items = articles
        case .videos: items = videos
        }
    }

    private func feedItemDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(DateFormatter.customDate)
        return decoder
    }

    private static func mapToDisplayItem(_ feedItem: FeedItem) -> DisplayItem {

        func getImageName(for contentType: ContentType) -> String {
            switch contentType {
            case .article:
                return "doc.text"
            case .video:
                return "film"
            }
        }

        return DisplayItem(
            id: feedItem.id,
            name: feedItem.attributes.name,
            description: feedItem.attributes.description,
            imageURL: feedItem.attributes.cardArtworkURL,
            releasedDateString: feedItem.attributes.releasedAt.display(),
            releasedDate: feedItem.attributes.releasedAt,
            itemTypeImage: getImageName(for: feedItem.attributes.contentType)
        )
    }
}



private extension Array where Element == DisplayItem {
    func dateSorted() -> [Element] {
        self.sorted { first, second in
            first.releasedDate < second.releasedDate
        }
    }
}
