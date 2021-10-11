//
//  ImageLoader.swift
//  PracticalExample
//
//  Created by Andrew Marmion on 11/10/2021.
//

import Foundation
import Combine

#if canImport(UIKit)
import UIKit
public typealias PEImage = UIImage
#endif

#if canImport(Cocoa)
import Cocoa
public typealias PEImage = NSImage
#endif

public protocol ImageLoader {
    func load(url: URL?) -> AnyPublisher<Optional<PEImage>, Never>
}
