import XCTest
import CombineExtensions

class ReplaySubjectTets: XCTestCase {

    func testSinkAfterSendsValues() {
        let subjectExpectation = expectation(description: "Subject sink")
        let subject = ReplaySubject<Int, Error>(bufferSize: 2)
        subject.send(1)
        var valuesArray = [Int]()
        let cancellable = subject.sink(receiveCompletion: { _ in
            XCTAssertEqual(valuesArray.count, 1)
            subjectExpectation.fulfill()
        }) { value in
            valuesArray.append(value)
        }
        subject.send(completion: .finished)
        wait(for: [subjectExpectation], timeout: 1)
    }

    func testSinkBeforeSendsValues() {
        let subjectExpectation = expectation(description: "Subject sink")
        let subject = ReplaySubject<Int, Error>(bufferSize: 2)
        var valuesArray = [Int]()
        let cancellable = subject.sink(receiveCompletion: { _ in
            XCTAssertEqual(valuesArray.count, 1)
            subjectExpectation.fulfill()
        }) { value in
            valuesArray.append(value)
        }
        subject.send(1)
        subject.send(completion: .finished)
        wait(for: [subjectExpectation], timeout: 1)
    }
    
    func testBufferLimit() {
        let subjectExpectation = expectation(description: "Subject sink")
        let subject = ReplaySubject<Int, Error>(bufferSize: 2)
        subject.send(1)
        subject.send(2)
        subject.send(3)
        subject.send(4)
        var valuesArray = [Int]()
        let cancellable = subject.sink(receiveCompletion: { _ in
            XCTAssertEqual(valuesArray.count, 2)
            subjectExpectation.fulfill()
        }) { value in
            valuesArray.append(value)
        }
        subject.send(completion: .finished)
        wait(for: [subjectExpectation], timeout: 1)
    }
    
}
