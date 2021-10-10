import PracticalExample
import Combine
import XCTest

final class RemoteFeedLoaderTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = makeSUT()

        XCTAssertTrue(client.requestedURLs.isEmpty)
    }

    private func makeSUT(
        articleURL: URL = URL(string: "https://a-url.com")!,
        videoURL: URL = URL(string: "https://a-url.com")!,
        client: HTTPClientStub = HTTPClientStub(),
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (sut: RemoteFeedLoader, client: HTTPClientStub) {
        let sut = RemoteFeedLoader(articleURL: articleURL, videoURL: videoURL, client: client)

        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(client, file: file, line: line)

        return (sut, client)
    }
}

private class HTTPClientStub: HTTPClient {

    var requestedURLs: [URL] = []

    let stubbedResponse: (() -> AnyPublisher<(data: Data, response: HTTPURLResponse), Error>)?

    init(stubbedResponse: (() -> AnyPublisher<(data: Data, response: HTTPURLResponse), Error>)? = nil) {
        self.stubbedResponse = stubbedResponse
    }

    func get(from url: URL) -> AnyPublisher<(data: Data, response: HTTPURLResponse), Error> {
        requestedURLs.append(url)

        return Just((anyData(), anyHTTPURLResponse())).mapError{ _ in anyNSError() }.eraseToAnyPublisher()
    }
}
