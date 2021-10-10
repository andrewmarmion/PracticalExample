//
//  Helpers_macOS.swift
//  PracticalExample
//
//  Created by Andrew Marmion on 09/10/2021.
//

import Foundation

extension Date {

    private static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        return dateFormatter
    }()

    public func display() -> String {
        Self.dateFormatter.string(from: self)
    }
}
