//
//  RemoteImageLoader.swift
//  PracticalExample
//
//  Created by Andrew Marmion on 11/10/2021.
//

import Foundation
import Combine

public final class RemoteImageLoader: ImageLoader {

    private let client: HTTPClient
    private(set) var isLoading: Bool = false

    public init(client: HTTPClient = URLSessionHTTPClient()) {
        self.client = client
    }

    public func load(url: URL?) -> AnyPublisher<Optional<PEImage>, Never> {
        guard let url = url else { return Just(nil).eraseToAnyPublisher() }

        return client.get(from: url)
            .tryMap({ PEImage(data: $0.data) })
            .replaceError(with: nil)
            .handleEvents(
                receiveSubscription: { [weak self] _ in self?.start() },
                receiveCompletion: { [weak self] _ in self?.finish() },
                receiveCancel: { [weak self] in self?.finish() })
            .eraseToAnyPublisher()
    }

    private func start() {
        self.isLoading = true
    }

    private func finish() {
        self.isLoading = false
    }
}
