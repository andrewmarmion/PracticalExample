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
