@testable import PracticalExample
import Combine
import XCTest

final class ViewModelTests: XCTestCase {

    func test_init_initialState() {
        let feedLoader = StubbedFeedLoader(stubbedResponse: StubbedFeedLoader.publishesEmptyResponse())
        let sut = ViewModel(feedLoader: feedLoader)

        XCTAssertEqual(sut.state, .empty)
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

    static func publishesEmptyResponse() -> AnyPublisher<(articles: [FeedItem], videos: [FeedItem]), Error> {
        Just(([], [])).mapError{ _ in anyNSError() }.eraseToAnyPublisher()
    }
}
