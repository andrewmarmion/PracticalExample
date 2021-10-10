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
}
