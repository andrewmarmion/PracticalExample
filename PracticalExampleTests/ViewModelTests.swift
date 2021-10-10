@testable import PracticalExample
import Combine
import XCTest

final class ViewModelTests: XCTestCase {

    func test_init_initialState() {
        let feedLoader = StubbedFeedLoader(stubbedResponse: StubbedFeedLoader.publishesSuccessResponse())
        let sut = ViewModel(feedLoader: feedLoader)

        XCTAssertEqual(sut.state, .empty)
        XCTAssertEqual(sut.items, [])
        XCTAssertEqual(sut.selectedList, .all)
    }

    func test_load_errorInFeedLoaderCreatesErrorState() {
        let feedLoader = StubbedFeedLoader(stubbedResponse: StubbedFeedLoader.publishesErrorResponse())
        let sut = ViewModel(feedLoader: feedLoader)

        sut.load()

        XCTAssertEqual(sut.state, .error(anyNSError()))
        XCTAssertEqual(sut.items, [])
        XCTAssertEqual(sut.selectedList, .all)
    }

    func test_load_successInFeedLoaderWithEmptyListsCreatesLoadedState() {
        let feedLoader = StubbedFeedLoader(stubbedResponse: StubbedFeedLoader.publishesSuccessResponse())
        let sut = ViewModel(feedLoader: feedLoader)

        sut.load()

        XCTAssertEqual(sut.state, .loaded)
        XCTAssertEqual(sut.items, [])
        XCTAssertEqual(sut.selectedList, .all)
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
