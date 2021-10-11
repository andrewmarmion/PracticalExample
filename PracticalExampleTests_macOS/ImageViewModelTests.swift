@testable import PracticalExample
import Combine
import XCTest

final class ImageViewModelTests: XCTestCase {

    func test_init_initalState() {
        let (sut, imageLoader) = makeSUT()

        XCTAssertEqual(imageLoader.requestedURLs, [])
        XCTAssertNil(sut.image)
        XCTAssertNil(sut.cancellable)
    }


    // MARK: - Helpers

    private func makeSUT(
        imageURL: URL = anyURL(),
        stubbedResponse: AnyPublisher<Optional<PEImage>, Never> = StubbedImageLoader.publishesNil(),
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (ImageViewModel, StubbedImageLoader) {
        let imageLoader = StubbedImageLoader(stubbedResponse: stubbedResponse)
        let sut = ImageViewModel(url: imageURL, imageLoader: imageLoader)

        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(imageLoader, file: file, line: line)

        return (sut, imageLoader)
    }
}

final class StubbedImageLoader: ImageLoader {

    private(set) var requestedURLs: [URL] = []

    let stubbedResponse: AnyPublisher<Optional<PEImage>, Never>

    init(stubbedResponse: AnyPublisher<Optional<PEImage>, Never>) {
        self.stubbedResponse = stubbedResponse
    }

    func load(url: URL?) -> AnyPublisher<Optional<PEImage>, Never> {
        stubbedResponse
    }

    static func publishesImage() -> AnyPublisher<Optional<PEImage>, Never> {
        Just(PEImage.makeTestImage())
            .eraseToAnyPublisher()
    }

    static func publishesNil() -> AnyPublisher<Optional<PEImage>, Never> {
        Just(nil)
            .eraseToAnyPublisher()
    }
}
