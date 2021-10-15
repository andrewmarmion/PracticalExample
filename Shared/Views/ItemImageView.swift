//
//  ItemImageView.swift
//  PracticalExample
//
//  Created by Andrew Marmion on 09/10/2021.
//

import Foundation
import SwiftUI

struct ItemImageView: View {

    @StateObject private var loader: ImageViewModel

    public init(
        url: URL?
    ) {
        self._loader = StateObject(wrappedValue: ImageViewModel(url: url))
    }

    public var body: some View {
        image
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .frame(width: 100, height: 100)
            .onAppear(perform: loader.load)
            .onDisappear(perform: loader.cancel)
    }

    @ViewBuilder
    private var image: some View {
        if let image = loader.image {
            Image(peImage: image)
                .resizable()
                .scaledToFit()
        } else {
            ZStack {
                ProgressView()
                Color.gray.opacity(0.1)
            }
        }

    }
}

private extension Image {
    init(peImage: PEImage) {
        #if os(iOS)
        self.init(uiImage: peImage)
        #elseif os(macOS)
        self.init(nsImage: peImage)
        #endif
    }
}
