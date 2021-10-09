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
    let description: String
    let content_type: ContentType
    let card_artwork_url: URL
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
    case loaded([FeedItems.FeedItem])
    case error(Error)
}

class ViewModel: ObservableObject {

    @Published var state: LoadingState = .loading

    private var cancellables = Set<AnyCancellable>()

    init() {
        load()
    }

    func load() {

        let articlesURL = URL(string: "https://raw.githubusercontent.com/raywenderlich/ios-interview/master/Practical%20Example/videos.json")!

        URLSession.shared.dataTaskPublisher(for: articlesURL)
            .tryMap { $0.data }
            .decode(type: FeedItems.self, decoder: JSONDecoder())
            .sink { completion in
                switch completion {
                case .failure(let error):
                    self.state = .error(error)
                case .finished:
                    break
                }

            } receiveValue: { [weak self] value in
                self?.state = .loaded(value.data)
            }
            .store(in: &cancellables)

    }
}

struct ContentView: View {

    @StateObject var viewModel = ViewModel()

    var body: some View {
        switch viewModel.state {
        case .error(let error):
            Text("Loading error \(error.localizedDescription)")
        case .loaded(let items):
            ListView(items: items)
        case .loading:
            Text("Loading")
        }
    }
}

struct ListView: View {
    let items: [FeedItems.FeedItem]

    var body: some View {
        List {
            ForEach(items) { item in
                VStack(alignment: .leading) {
                    HStack(alignment: .top) {
                        ItemImage(url: item.attributes.card_artwork_url)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .frame(width: 100, height: 100)

                        VStack(alignment: .leading, spacing: 10) {
                            Text(item.attributes.name)
                                .fixedSize(horizontal: false, vertical: true)
                            Image(systemName: getImageName(for: item.attributes.content_type))
                        }

                        Spacer()
                    }

                    Text(item.attributes.description)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
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
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ContentView()
        }
    }
}
