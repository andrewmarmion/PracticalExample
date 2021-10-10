@testable import PracticalExample
import Combine
import XCTest

final class ViewModelTests: XCTestCase {

    func test_init_initialState() {
        let sut = makeSUT()

        XCTAssertEqual(sut.state, .empty)
        XCTAssertEqual(sut.items, [])
        XCTAssertEqual(sut.selectedList, .all)
    }

    func test_load_errorInFeedLoaderCreatesErrorState() {
        let sut = makeSUT(stubbedResponse: StubbedFeedLoader.publishesErrorResponse())

        sut.load()

        XCTAssertEqual(sut.state, .error(anyNSError()))
        XCTAssertEqual(sut.items, [])
        XCTAssertEqual(sut.selectedList, .all)
    }

    func test_load_successInFeedLoaderWithEmptyListsCreatesLoadedState() {
        let sut = makeSUT()

        sut.load()

        XCTAssertEqual(sut.state, .loaded)
        XCTAssertEqual(sut.items, [])
        XCTAssertEqual(sut.selectedList, .all)
    }
    // MARK: - Helpers

    private func makeSUT(
        stubbedResponse: AnyPublisher<(articles: [FeedItem], videos: [FeedItem]), Error> = StubbedFeedLoader.publishesSuccessResponse(),
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> ViewModel {
        let feedLoader = StubbedFeedLoader(stubbedResponse: stubbedResponse)
        let sut = ViewModel(feedLoader: feedLoader)

        trackForMemoryLeaks(feedLoader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)

        return sut
    }

}

private final class StubbedFeedLoader: FeedLoader {

    let stubbedResponse: AnyPublisher<(articles: [FeedItem], videos: [FeedItem]), Error>

    init(stubbedResponse: AnyPublisher<(articles: [FeedItem], videos: [FeedItem]), Error>) {
        self.stubbedResponse = stubbedResponse
    }

    func load() -> AnyPublisher<(articles: [FeedItem], videos: [FeedItem]), Error> {
        stubbedResponse
    }

    static func publishesErrorResponse() -> AnyPublisher<(articles: [FeedItem], videos: [FeedItem]), Error> {
        Just(())
            .tryMap { throw anyNSError() }
            .eraseToAnyPublisher()
    }

    static func publishesSuccessResponse(articles: [FeedItem] = [], videos: [FeedItem] = []) -> AnyPublisher<(articles: [FeedItem], videos: [FeedItem]), Error> {
        Just((articles, videos)).mapError{ _ in anyNSError() }.eraseToAnyPublisher()
    }
}
