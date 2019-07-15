//
//  DisposeBag
//
//  Check the LICENSE file for details
//  Created by David Collado
//

import Combine
import class Foundation.NSRecursiveLock

/**
 Bag that disposes added disposables on `deinit`.
 This returns ARC (RAII) like resource management to `Combine`.
 In case contained disposables need to be disposed, just put a different dispose bag
 or create a new one in its place.
 self.existingDisposeBag = DisposeBag()
 */
public class DisposeBag {
    private var _lock = NSRecursiveLock()

    // state
    fileprivate var _cancellables = [Cancellable]()
    fileprivate var _isDisposed = false

    /// Constructs new empty dispose bag.
    public init() { }

    /// Adds `cancellable` to be disposed when dispose bag is being deinited.
    ///
    /// - parameter disposable: Disposable to add.
    public func insert(_ cancellable: Cancellable) {
        self._insert(cancellable)?.cancel()
    }

    private func _insert(_ cancellable: Cancellable) -> Cancellable? {
        self._lock.lock(); defer { self._lock.unlock() }
        if self._isDisposed {
            return cancellable
        }

        self._cancellables.append(cancellable)

        return nil
    }

    private func dispose() {
        self._lock.lock(); defer { self._lock.unlock() }
        let oldCancellables = self._dispose()

        for cancellable in oldCancellables {
            cancellable.cancel()
        }
    }

    private func _dispose() -> [Cancellable] {
        let cancellables = self._cancellables

        self._cancellables.removeAll(keepingCapacity: false)
        self._isDisposed = true

        return cancellables
    }

    deinit {
        self.dispose()
    }
}

public extension Cancellable {
    /// Adds `self` to `bag`
    ///
    /// - parameter bag: `DisposeBag` to add `self` to.
    func disposed(by bag: DisposeBag) {
        bag.insert(self)
    }
}
