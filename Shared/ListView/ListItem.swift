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
                ItemImageView(url: item.imageURL)

                VStack(alignment: .leading, spacing: 10) {
                    Text(item.name)
                        .bold()
                        .fixedSize(horizontal: false, vertical: true)

                    HStack {
                        Image(systemName: item.itemTypeImage)
                        Text(item.releasedDateString)
                    }
                }

                Spacer()
            }

            Text(item.description)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

}
