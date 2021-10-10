//
//  Helpers.swift
//  PracticalExample
//
//  Created by Andrew Marmion on 09/10/2021.
//

import Foundation

extension DateFormatter {
    public static let customDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
}
