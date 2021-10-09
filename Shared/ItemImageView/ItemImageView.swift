//
//  ItemImageView.swift
//  PracticalExample
//
//  Created by Andrew Marmion on 09/10/2021.
//

import Foundation
import SwiftUI

struct ItemImageView: View {

    @ObservedObject private var loader: ImageLoader

    public init(
        url: URL?
    ) {
        self.loader = ImageLoader(url: url)
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
            #if os(iOS)
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
            #elseif os(macOS)
            Image(nsImage: image)
                .resizable()
                .scaledToFit()
            #endif
        } else {
            ZStack {
                ProgressView()
                Color.gray.opacity(0.1)
            }
        }

    }
}
