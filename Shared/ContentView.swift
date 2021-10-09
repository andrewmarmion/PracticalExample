//
//  ContentView.swift
//  Shared
//
//  Created by Andrew Marmion on 09/10/2021.
//

import Combine
import SwiftUI

enum ContentType: String, Decodable {
    case article
    case video = "collection"
}

struct ItemAttributes: Decodable {
    let name: String
    let description: String // is html in the videos, do we need to handle that?
    let content_type: ContentType
    let card_artwork_url: URL
    let released_at: Date
}

struct FeedItems: Decodable {
    let data: [FeedItem]

    struct FeedItem: Decodable, Identifiable {
        let id: String
        let type: String
        let attributes: ItemAttributes
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
    @Published var items: [FeedItems.FeedItem] = []

    private var articles: [FeedItems.FeedItem] = []
    private var videos: [FeedItems.FeedItem] = []
    private var both: [FeedItems.FeedItem] = []

    private var cancellables = Set<AnyCancellable>()

    func load() {
        self.state = .loading
        let articlesURL = URL(string: "https://raw.githubusercontent.com/raywenderlich/ios-interview/master/Practical%20Example/articles.json")!

        let videosURL = URL(string: "https://raw.githubusercontent.com/raywenderlich/ios-interview/master/Practical%20Example/videos.json")!

        let articlePublisher = publisher(for: articlesURL)
        let videoPublisher = publisher(for: videosURL)

        articlePublisher
            .combineLatest(videoPublisher)
//            .delay(for: 2, scheduler: DispatchQueue.main)
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

    private func publisher(for url: URL) -> AnyPublisher<[FeedItems.FeedItem], Error> {
        // We should be injeting this so that we can use any type of dataTaskPublisher
        URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { $0.data }
            .decode(type: FeedItems.self, decoder: feedItemDecoder())
            .map { $0.data }
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
}

extension DateFormatter {
    // We are not displaying the date and we only need it for sorting purposes
    static let customDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        return formatter
    }()
}

enum SelectedList {
    case all
    case articles
    case videos
}

extension Array where Element == FeedItems.FeedItem {
    func dateSorted() -> [Element] {
        self.sorted { first, second in
            first.attributes.released_at < second.attributes.released_at
        }
    }
}

struct ContentView: View {

    @StateObject var viewModel = ViewModel()

    var body: some View {
        NavigationView {
            Group {
                switch viewModel.state {
                case .error(let error):
                    Text("Loading error \(error.localizedDescription)")
                        .padding()

                case .loaded:

                    VStack {
                        Picker("List", selection: $viewModel.selectedList) {
                            Text("All").tag(SelectedList.all)
                            Text("Articles").tag(SelectedList.articles)
                            Text("Videos").tag(SelectedList.videos)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        ListView(items: viewModel.items)
                           // consider using a toolbar to place the SegmentedController in the navigation
                    }

                case .loading:
                    ProgressView("Loading...")
                        .font(.title)
                }
            }
            .navigationTitle("Courses")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        viewModel.load()
                    } label: {
                        Image(systemName: "arrow.counterclockwise")
                    }
                }
            }
            .onAppear {
                viewModel.load()
            }
        }
    }
}

struct ListView: View {
    let items: [FeedItems.FeedItem]

    var body: some View {
        List {
            ForEach(items) { item in
                ListItem(item: item)
            }
        }
    }
}

struct ListItem: View {

    let item: FeedItems.FeedItem

    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                ItemImage(url: item.attributes.card_artwork_url)

                VStack(alignment: .leading, spacing: 10) {
                    Text(item.attributes.name)
                        .bold()
                        .fixedSize(horizontal: false, vertical: true)
                    Image(systemName: getImageName(for: item.attributes.content_type))
                }

                Spacer()
            }

            Text(item.attributes.description)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    func getImageName(for contentType: ContentType) -> String {
        switch contentType {
        case .article:
            return "doc.text"
        case .video:
            return "film"
        }
    }
}

struct ItemImage: View {
    let url: URL
    var body: some View {
        // TODO: AsyncImage is not available in macOS 11.3 so we need to roll our own version of it
        AsyncImage(url: url) { image in
            image
                .resizable()
                .scaledToFit()
        } placeholder: {
            ZStack {
                ProgressView()
                Color.gray.opacity(0.1)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .frame(width: 100, height: 100)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
