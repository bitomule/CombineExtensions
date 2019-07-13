import XCTest
import Foundation
import Combine
import CombineExtensions

class DisposeBagTests: XCTestCase {
    func testReleasingDisposeBagCancellsSubscribers() {
        let sutExpectation = expectation(description: "Sink")
        sutExpectation.isInverted = true
        /// Given
        /// An optional DisposeBag
        var disposebag: DisposeBag? = DisposeBag()
        /// A publisher
        let subject = PassthroughSubject<Int ,Error>()
        _ = subject.sink(receiveValue: { value in
            sutExpectation.fulfill()
        }).disposedBy(disposebag!)
        /// When DisposeBag is released
        disposebag = nil
        subject.send(1)
        /// Expectation should not be fullfilled meaning the subscription was cancelled
        waitForExpectations(timeout: 0.1, handler: nil)
    }

    func testDisposeBagReceivesValue() {
        let sutExpectation = expectation(description: "Sink")
        /// Given a Disposebag
        let disposebag = DisposeBag()
        /// A Publisher
        let subject = PassthroughSubject<Int ,Error>()
        var values = [Int]()
        /// And a subscription disposed by the DisposeBag
        _ = subject.sink(receiveValue: { value in
            values.append(value)
            /// A value should be received
            XCTAssertEqual(values.count, 1)
            sutExpectation.fulfill()
        }).disposedBy(disposebag)
        subject.send(1)
        waitForExpectations(timeout: 0.1, handler: nil)
    }
}