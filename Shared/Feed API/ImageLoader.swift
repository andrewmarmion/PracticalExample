//
//  ImageLoader.swift
//  PracticalExample
//
//  Created by Andrew Marmion on 09/10/2021.
//

import Combine
import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

#if canImport(Cocoa)
import Cocoa
typealias UIImage = NSImage
#endif

class ImageLoader: ObservableObject {
    @Published var image: UIImage?

    private let url: URL?
    private let client: HTTPClient
    private(set) var cancellable: AnyCancellable?

    private(set) var isLoading: Bool = false

    private static let imageProcessingQueue = DispatchQueue(label: "Image-Processing")

    public init(url: URL?, client: HTTPClient = URLSessionHTTPClient()) {
        self.url = url
        self.client = client
    }

    deinit {
        cancellable?.cancel()
    }

    func load() {
        // TODO: We could add caching functionality so that we don't keep downloading the images
        guard let url = url, !isLoading else { return }

        // Need to inject URLSession here
        cancellable = client.get(from: url)
            .subscribe(on: Self.imageProcessingQueue)
            .map({ UIImage(data: $0.data) })
            .replaceError(with: nil)
            .handleEvents(
                receiveSubscription: { [weak self] _ in self?.start() },
                receiveCompletion: { [weak self] _ in self?.finish() },
                receiveCancel: { [weak self] in self?.finish() })
            .receive(on: RunLoop.main)
            .assign(to: \.image, on: self)
    }

    func cancel() {
        cancellable?.cancel()
    }

    private func start() {
        self.isLoading = true
    }

    private func finish() {
        self.isLoading = false
    }
}
