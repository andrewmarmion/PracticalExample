//
//  MainQueueRemoteImageLoader.swift
//  PracticalExample
//
//  Created by Andrew Marmion on 11/10/2021.
//

import Combine
import Foundation

final class MainQueueRemoteImageLoader: ImageLoader {

    private let imageLoader: ImageLoader

    init(imageLoader: ImageLoader = RemoteImageLoader()) {
        self.imageLoader = imageLoader
    }

    func load(url: URL?) -> AnyPublisher<Optional<PEImage>, Never> {
        imageLoader.load(url: url)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
