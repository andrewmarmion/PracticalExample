//
//  Helpers.swift
//  PracticalExampleTests
//
//  Created by Andrew Marmion on 10/10/2021.
//

import Foundation

func anyURL() -> URL {
    URL(string: "https://any-url.com")!
}

func anotherURL() -> URL {
    URL(string: "https://another-url.com")!
}

func anyData() -> Data {
    Data("any data".utf8)
}

func anyNSError() -> NSError {
    NSError(domain: "any error", code: 0)
}

func nonHTTPURLResponse() -> URLResponse {
    URLResponse(url: anyURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
}

func anyHTTPURLResponse() -> HTTPURLResponse {
    HTTPURLResponse(url: anyURL(), statusCode: 200, httpVersion: nil, headerFields: nil)!
}
