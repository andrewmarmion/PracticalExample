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

    func test_load_successInFeedWithOnlyArticlesResultsCreatesLoadedStateWithArticlesOrdered() {

        let article1 = makeFeedItem(number: 1, type: .article)
        let article2 = makeFeedItem(number: 2, type: .article)

        let articles = [article2, article1]

        let stubbedResponse = StubbedFeedLoader.publishesSuccessResponse(articles: articles, videos: [])
        let sut = makeSUT(stubbedResponse: stubbedResponse)

        sut.load()

        XCTAssertEqual(sut.state, .loaded)
        XCTAssertEqual(sut.items, [article1, article2])
    }

    func test_load_successInFeedWithOnlyVideosResultsCreatesLoadedStateWithVideosOrdered() {
        let video1 = makeFeedItem(number: 1, type: .video)
        let video2 = makeFeedItem(number: 2, type: .video)

        let videos = [video2, video1]

        let stubbedResponse = StubbedFeedLoader.publishesSuccessResponse(articles: [], videos: videos)
        let sut = makeSUT(stubbedResponse: stubbedResponse)

        sut.load()

        XCTAssertEqual(sut.state, .loaded)
        XCTAssertEqual(sut.items, [video1, video2])
    }

    func test_load_successWithBothArticleAndVideoCreatedLoadedStateWithFeedItemsOrderedShowsCorrectListWhenChanged() {
        let article1 = makeFeedItem(number: 1, type: .article)
        let article2 = makeFeedItem(number: 2, type: .article)

        let video1 = makeFeedItem(number: 1, type: .video)
        let video2 = makeFeedItem(number: 2, type: .video)

        let article3 = makeFeedItem(number: 3, type: .article)

        let videos = [video2, video1]
        let articles = [article2, article1, article3]

        let stubbedResponse = StubbedFeedLoader.publishesSuccessResponse(articles: articles, videos: videos)
        let sut = makeSUT(stubbedResponse: stubbedResponse)

        sut.load()

        XCTAssertEqual(sut.state, .loaded)
        XCTAssertEqual(sut.selectedList, .all)
        XCTAssertEqual(sut.items, [article1, article2, video1, video2, article3])

        sut.selectedList = .articles
        XCTAssertEqual(sut.items, [article1, article2, article3])

        sut.selectedList = .videos
        XCTAssertEqual(sut.items, [video1, video2])

        sut.selectedList = .all
        XCTAssertEqual(sut.items, [article1, article2, video1, video2, article3])

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

    private func makeFeedItem(number: Int, type: ContentType) -> FeedItem {
        FeedItem(
            id: "\(number)",
            name: "item\(number)",
            description: "item\(number) description",
            imageURL: URL(string: "https://item\(number)-url.com")!,
            releasedDateString: "item\(number) releaseDateString",
            releasedDate: Date(),
            itemTypeImage: "item\(number) \(type.rawValue)"
        )
    }

}


