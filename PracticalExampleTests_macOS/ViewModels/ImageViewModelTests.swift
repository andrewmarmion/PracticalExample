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

    func test_load_imageLoaderPerformLoadForURL() {
        let imageURL = anyURL()
        let (sut, imageLoader) = makeSUT(imageURL: imageURL)

        sut.load()

        XCTAssertEqual(imageLoader.requestedURLs, [imageURL])
    }

    func test_load_imageLoaderDeliversImageToViewModel() {
        let image = PEImage.makeTestImage()
        let (sut, _) = makeSUT(stubbedResponse: StubbedImageLoader.publishesImage(image: image))

        sut.load()

        XCTAssertNotNil(sut.image)
        XCTAssertEqual(sut.image, image)
    }

    func test_load_imageLoaderDeliversNilToViewModel() {
        let (sut, _) = makeSUT(stubbedResponse: StubbedImageLoader.publishesNil())

        sut.load()

        XCTAssertNil(sut.image)
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
