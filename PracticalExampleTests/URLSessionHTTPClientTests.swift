import PracticalExample
import Combine
import XCTest

final class URLSessionHTTPClientTests: XCTestCase {

    private var cancellables = Set<AnyCancellable>()

    override func setUp() {
        super.setUp()
        URLProtocolStub.startInterceptingRequests()
        cancellables.removeAll()
    }

    override func tearDown() {
        super.tearDown()
        URLProtocolStub.stopInterceptingRequests()
        cancellables.removeAll()
    }

    func test_getFromURL_performsGETRequestWithURL() {
        let url = anyURL()
        let exp = expectation(description: "Wait for request")

        URLProtocolStub.observeRequests { request in
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "GET")
            exp.fulfill()
        }

        makeSUT().get(from: url)
            .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
            .store(in: &cancellables)

        wait(for: [exp], timeout: 1.0)
    }

    // MARK: - Helpers

    typealias HTTPClientResult = Result<(data: Data, response: HTTPURLResponse), Error>

    private func makeSUT(
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> HTTPClient {
        let sut = URLSessionHTTPClient()
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }

    private func resultFor(
        data: Data? ,
        response: URLResponse?,
        error: Error?,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> HTTPClientResult {
        URLProtocolStub.stub(data: data, response: response, error: error)

        let sut = makeSUT(file: file, line: line)
        let exp = expectation(description: "Wait for completion")

        var receivedResult: HTTPClientResult!
        sut.get(from: anyURL())
            .sink(
                receiveCompletion: { completion in
                    if case let .failure(error) = completion {
                        receivedResult = .failure(error)
                    }
                    exp.fulfill()
                },
                receiveValue: { data, response in
                    receivedResult = .success((data, response))
                }
            )
            .store(in: &cancellables)

        wait(for: [exp], timeout: 1.0)
        return receivedResult
    }

    private func resultValuesFor(
        data: Data? ,
        response: URLResponse?,
        error: Error?,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (data: Data, response: HTTPURLResponse)? {
        let result = resultFor(data: data , response: response, error: error)

        switch result {
        case let .success(successValues):
            return successValues
        default:
            XCTFail("Expected success, got \(String(describing: result)) instead", file: file, line: line)
            return nil
        }
    }

    private func resultErrorFor(
        data: Data? ,
        response: URLResponse?,
        error: Error?,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> Error? {
        let result = resultFor(data: data, response: response, error: error)

        switch result {
        case let .failure(error):
            return error
        default:
            XCTFail("Expected failure, got \(String(describing: result)) instead", file: file, line: line)
            return nil
        }
    }

    private func anyURL() -> URL {
        URL(string: "https://any-url.com")!
    }
}

// Subclass URLProtocol
private class URLProtocolStub: URLProtocol {

    private static var stub: Stub?
    private static var requestObserver: ((URLRequest) -> Void)?

    private struct Stub {
        let data: Data?
        let response: URLResponse?
        let error: Error?
    }

    static func stub(data: Data?, response: URLResponse?, error: Error?) {
        stub = Stub(data: data, response: response, error: error)
    }

    static func observeRequests(observer: @escaping (URLRequest) -> Void) {
        requestObserver = observer
    }

    static func startInterceptingRequests() {
        URLProtocol.registerClass(URLProtocolStub.self)
    }

    static func stopInterceptingRequests() {
        URLProtocol.unregisterClass(URLProtocolStub.self)
        URLProtocolStub.stub = nil
        URLProtocolStub.requestObserver = nil

    }

    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        if let requestObserver = URLProtocolStub.requestObserver {
            client?.urlProtocolDidFinishLoading(self)
            return requestObserver(request)
        }

        if let data = URLProtocolStub.stub?.data {
            client?.urlProtocol(self, didLoad: data)
        }

        if let response = URLProtocolStub.stub?.response {
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        }

        if let error = URLProtocolStub.stub?.error {
            client?.urlProtocol(self, didFailWithError: error)
        }

        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}
}

extension XCTestCase {

    func trackForMemoryLeaks(
        _ instance: AnyObject,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have been deallocated, Potential memory leak", file: file, line: line)
        }
    }
}
