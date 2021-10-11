//
//  HTTPClient.swift
//  PracticalExample
//
//  Created by Andrew Marmion on 10/10/2021.
//

import Combine
import Foundation

public protocol HTTPClient {
    func get(from url: URL) -> AnyPublisher<(data: Data, response: HTTPURLResponse), Error>
}
