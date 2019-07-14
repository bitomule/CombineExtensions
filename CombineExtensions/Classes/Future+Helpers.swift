//
//  Future extensions
//
//  Check the LICENSE file for details
//  Created by David Collado
//

import Combine

public extension Future {
    /// Create a new Future with a single value
    /// Future<Int, Error>.just(3)
    /// Returns a Future<Output,Failure>
    static func just(_ value: Output) -> Future<Output,Failure> {
        return Future<Output, Failure> { promise in return promise(.success(value)) }
    }
}
