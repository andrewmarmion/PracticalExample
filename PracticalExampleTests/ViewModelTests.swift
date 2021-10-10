@testable import PracticalExample
import XCTest

final class ViewModelTests: XCTestCase {

    func test_init_isLoading() {
        let sut = ViewModel(client: HTTPClientStub())

        XCTAssertEqual(sut.state, .loading)
    }
}
