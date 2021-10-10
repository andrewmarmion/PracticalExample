//
//  FeedItem.swift
//  PracticalExample
//
//  Created by Andrew Marmion on 10/10/2021.
//

import Foundation

public struct FeedItem: Identifiable, Equatable {
    public let id: String
    public let name: String
    public let description: String
    public let imageURL: URL
    public let releasedDateString: String
    public let releasedDate: Date
    public let itemTypeImage: String

    public init(
        id: String,
        name: String,
        description: String, 
        imageURL: URL,
        releasedDateString: String,
        releasedDate: Date,
        itemTypeImage: String
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.imageURL = imageURL
        self.releasedDateString = releasedDateString
        self.releasedDate = releasedDate
        self.itemTypeImage = itemTypeImage
    }
}
