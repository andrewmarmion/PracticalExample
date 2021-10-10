//
//  DisplayItem.swift
//  PracticalExample
//
//  Created by Andrew Marmion on 10/10/2021.
//

import Foundation

struct DisplayItem: Identifiable {
    let id: String
    let name: String
    let description: String
    let imageURL: URL
    let releasedDateString: String
    let releasedDate: Date
    let itemTypeImage: String
}
