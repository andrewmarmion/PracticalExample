import PracticalExample
import Combine
import XCTest

final class RemoteFeedLoaderTests: XCTestCase {

    private var cancellables = Set<AnyCancellable>()

    func test_init_doesNotRequestDataFromURLs() {
        let (_, client) = makeSUT()

        XCTAssertTrue(client.requestedURLs.isEmpty)
    }

    func test_load_requestsDataFromURLs() {
        let articleURL = URL(string: "https://article-url.com")!
        let videoURL = URL(string: "https://video-url.com")!
        let (sut, client) = makeSUT(articleURL: articleURL, videoURL: videoURL)

        sut
            .load()
            .sink { _ in } receiveValue: { _, _ in }
            .store(in: &cancellables)

        XCTAssertEqual(client.requestedURLs, [articleURL, videoURL])
    }

    private func makeSUT(
        articleURL: URL = anyURL(),
        videoURL: URL = anyURL(),
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
