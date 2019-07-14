//
//  Completable
//
//  Check the LICENSE file for details
//  Created by David Collado
//

import Combine

public typealias Completable<T:Error> = Future<Void, T>
