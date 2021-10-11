@testable import PracticalExample
import Combine
import XCTest

final class RemoteImageLoaderTests: XCTestCase {

    private var cancellables = Set<AnyCancellable>()

    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = makeSUT()

        XCTAssertTrue(client.requestedURLs.isEmpty)
    }

    func test_load_requestsDataFromURL() {
        let imageURL = anyURL()
        let (sut, client) = makeSUT()

        sut
            .load(url: imageURL)
            .sink { _ in } receiveValue: { _ in }
            .store(in: &cancellables)

        XCTAssertEqual(client.requestedURLs, [imageURL])
    }

    func test_loadTwice_requestsDataFromURLs() {
        let imageURL1 = anyURL()
        let imageURL2 = anotherURL()
        let (sut, client) = makeSUT()

        sut
            .load(url: imageURL1)
            .sink { _ in }
            .store(in: &cancellables)

        sut
            .load(url: imageURL2)
            .sink { _ in }
            .store(in: &cancellables)

        XCTAssertEqual(client.requestedURLs, [imageURL1, imageURL2])
    }

    func test_load_deliversNilOnClientError() {
        let clientError = anyNSError()
        let httpClient = HTTPClientStub(stubbedResponse: HTTPClientStub.publishesError(error: clientError))
        let (sut, _) = makeSUT(client: httpClient)
        let exp = expectation(description: "delivers nil on error")
        let imageURL = anyURL()

        sut
            .load(url: imageURL)
            .sink { image in
                XCTAssertNil(image)
                exp.fulfill()
            }
            .store(in: &cancellables)

        wait(for: [exp], timeout: 1.0)
    }


    

    // MARK: - Helpers

    private func makeSUT(
        client: HTTPClientStub = HTTPClientStub(),
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (sut: RemoteImageLoader, client: HTTPClientStub) {
        let sut = RemoteImageLoader(client: client)

        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(client, file: file, line: line)

        return (sut, client)
    }
}
