//
//  ImageLoader.swift
//  PracticalExample
//
//  Created by Andrew Marmion on 09/10/2021.
//

import Combine
import Foundation

final class ImageViewModel: ObservableObject {
    @Published var image: PEImage?

    private let url: URL?
    private let imageLoader: ImageLoader
    private(set) var cancellable: AnyCancellable?

    public init(url: URL?, imageLoader: ImageLoader = MainQueueRemoteImageLoader()) {
        self.url = url
        self.imageLoader = imageLoader
    }

    deinit {
        cancellable?.cancel()
    }

    func load() {
        // TODO: We could add caching functionality so that we don't keep downloading the images
        guard let url = url else { return }

        cancellable = imageLoader.load(url: url)
            .assign(to: \.image, on: self)
    }

    func cancel() {
        cancellable?.cancel()
    }
}
