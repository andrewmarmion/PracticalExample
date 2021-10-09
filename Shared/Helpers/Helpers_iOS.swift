//
//  Helpers_iOS.swift
//  PracticalExample
//
//  Created by Andrew Marmion on 09/10/2021.
//

import Foundation

extension Date {
    func display() -> String {
        self.formatted(
            .dateTime
            .month(.wide)
            .day(.twoDigits)
            .year()
         )
    }
}
