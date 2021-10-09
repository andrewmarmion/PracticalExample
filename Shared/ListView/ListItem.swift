//
//  ListItem.swift
//  PracticalExample
//
//  Created by Andrew Marmion on 09/10/2021.
//

import SwiftUI

struct ListItem: View {

    let item: FeedItem

    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                ItemImageView(url: item.attributes.card_artwork_url)

                VStack(alignment: .leading, spacing: 10) {
                    Text(item.attributes.name)
                        .bold()
                        .fixedSize(horizontal: false, vertical: true)

                    HStack {
                        Image(systemName: getImageName(for: item.attributes.content_type))
                        Text(item.attributes.released_at.display())
                    }
                }

                Spacer()
            }

            Text(item.attributes.description)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    // This should be moved to a DTO
    func getImageName(for contentType: ContentType) -> String {
        switch contentType {
        case .article:
            return "doc.text"
        case .video:
            return "film"
        }
    }
}
