//
//  StubbedImageLoader.swift
//  PracticalExampleTests_macOS
//
//  Created by Andrew Marmion on 11/10/2021.
//

import Combine
import Foundation
import PracticalExample

final class StubbedImageLoader: ImageLoader {

    private(set) var requestedURLs: [URL?] = []

    let stubbedResponse: AnyPublisher<Optional<PEImage>, Never>

    init(stubbedResponse: AnyPublisher<Optional<PEImage>, Never>) {
        self.stubbedResponse = stubbedResponse
    }

    func load(url: URL?) -> AnyPublisher<Optional<PEImage>, Never> {
        requestedURLs.append(url)
        return stubbedResponse
    }

    static func publishesImage(image: PEImage?) -> AnyPublisher<Optional<PEImage>, Never> {
        Just(image)
            .eraseToAnyPublisher()
    }

    static func publishesNil() -> AnyPublisher<Optional<PEImage>, Never> {
        Just(nil)
            .eraseToAnyPublisher()
    }
}
