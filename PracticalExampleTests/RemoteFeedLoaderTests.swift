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

    func test_loadTwice_requestsDataFromURLs() {
        let articleURL = URL(string: "https://article-url.com")!
        let videoURL = URL(string: "https://video-url.com")!
        let (sut, client) = makeSUT(articleURL: articleURL, videoURL: videoURL)

        sut
            .load()
            .sink { _ in } receiveValue: { _, _ in }
            .store(in: &cancellables)

        sut
            .load()
            .sink { _ in } receiveValue: { _, _ in }
            .store(in: &cancellables)

        XCTAssertEqual(client.requestedURLs, [articleURL, videoURL, articleURL, videoURL])
    }

    func test_load_deliversErrorOnClientError() {
        let clientError = anyNSError()
        let httpClient = HTTPClientStub(stubbedResponse: publishesError(error: clientError))
        let (sut, _) = makeSUT(client: httpClient)
        let exp = expectation(description: "Client Error")

        sut
            .load()
            .sink { completion in
                if case let .failure(error) = completion {
                    XCTAssertEqual(error as NSError, clientError)
                    exp.fulfill()
                }
            } receiveValue: { _, _ in }
            .store(in: &cancellables)

        wait(for: [exp], timeout: 1.0)
    }

    func test_load_deliversErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        let samples = [199, 201, 300, 400, 500]

        samples.forEach { code in
            expect(sut, toCompleteWith: failure(.invalidData)) {
                    let clientResponse = HTTPURLResponse(url: anyURL(), statusCode: code, httpVersion: nil, headerFields: nil)!
                    client.stubbedResponse = publishesDataResponse(data: anyData(), response: clientResponse)
            }
        }
    }

    func test_load_deliversErrorOn200HTTPResponseWithInvalidJSON() {
        let (sut, client) = makeSUT()

        expect(sut, toCompleteWith: failure(.invalidData)) {
            let invalidJSON = Data("invalid json".utf8)
            client.stubbedResponse = publishesDataResponse(data: invalidJSON, response: anyHTTPURLResponse())
        }
    }

    func test_load_deliversNoItemsOn200HTTPResponseWithEmptyJSONList() {
        let (sut, client) = makeSUT()

        expect(sut, toCompleteWith: .success(([], []))) {
            let emptyListJSON = makeItemsJSON([])
            client.stubbedResponse = publishesDataResponse(data: emptyListJSON, response: anyHTTPURLResponse())
        }
    }

    // MARK: - Helpers

    typealias ClientResult = Result<(articles: [FeedItem], videos: [FeedItem]), Error>

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

    func expect(
        _ sut: RemoteFeedLoader,
        toCompleteWith expectedResult: ClientResult,
        when action: () -> Void,
        file: StaticString = #filePath, line: UInt = #line
    ) {
        let exp = expectation(description: "wait for load completion")
        var clientResult: ClientResult?
        action()

        sut.load()
            .sink { completion in

                if case let .failure(error) = completion {
                    clientResult = .failure(error)
                }

                exp.fulfill()

            } receiveValue: { articles, videos in
                clientResult = .success((articles, videos))

            }.store(in: &cancellables)



        wait(for: [exp], timeout: 1.0)

        guard let receivedResult = clientResult else {
            XCTFail("Expected clientResult to not be nil")
            return
        }

        switch (receivedResult, expectedResult) {
        case let (.success(receivedItems), .success(expectedItems)):
            XCTAssertEqual(receivedItems.articles, expectedItems.articles, file: file, line: line)
            XCTAssertEqual(receivedItems.videos, expectedItems.videos, file: file, line: line)

        case let(.failure(receivedError as RemoteFeedLoader.Error), .failure(expectedError as RemoteFeedLoader.Error)):
            XCTAssertEqual(receivedError, expectedError, file: file, line: line)

        default:
            XCTFail("Expected result \(expectedResult) got \(receivedResult) instead", file: file, line: line)
        }

    }

    private func failure(_ error: RemoteFeedLoader.Error) -> ClientResult {
        .failure(error)
    }

    private func publishesError(error: Error) -> AnyPublisher<(data: Data, response: HTTPURLResponse), Error> {
        Just(())
            .tryMap { throw error }
            .eraseToAnyPublisher()
    }

    private func publishesDataResponse(data: Data, response: HTTPURLResponse) -> AnyPublisher<(data: Data, response: HTTPURLResponse), Error>  {
        Just((data, response)).mapError{ _ in anyNSError() }.eraseToAnyPublisher()
    }

    private func makeItemsJSON(_ items: [[String: Any]]) -> Data {
        let json = ["data": items]
        return try! JSONSerialization.data(withJSONObject: json)
    }
}

private class HTTPClientStub: HTTPClient {

    var requestedURLs: [URL] = []

    var stubbedResponse: (AnyPublisher<(data: Data, response: HTTPURLResponse), Error>)?

    init(stubbedResponse: (AnyPublisher<(data: Data, response: HTTPURLResponse), Error>)? = nil) {
        self.stubbedResponse = stubbedResponse
    }

    func get(from url: URL) -> AnyPublisher<(data: Data, response: HTTPURLResponse), Error> {
        requestedURLs.append(url)

        if let stubbedResponse = stubbedResponse {
            return stubbedResponse
        }
        return Just((anyData(), anyHTTPURLResponse())).mapError{ _ in anyNSError() }.eraseToAnyPublisher()
    }
}
