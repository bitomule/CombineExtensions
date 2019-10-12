//
//  ReplaySubject
//
//  Check the LICENSE file for details
//  Created by David Collado
//

import Combine
import class Foundation.NSRecursiveLock

final class ReplaySubscription<Input, Failure: Error>: Subscription {
    private var subscriber: AnySubscriber<Input, Failure>?
    var isCancelled: Bool = false

    init(subscriber: AnySubscriber<Input, Failure>) {
        self.subscriber = subscriber
    }

    func request(_ demand: Subscribers.Demand) {
        // We do nothing here as we only want to send events when they occur.
        // See, for more info: https://developer.apple.com/documentation/combine/subscribers/demand
    }

    func receive(_ value: Input) {
        _ = subscriber?.receive(value)
    }

    func receive(_ completion: Subscribers.Completion<Failure>) {
        subscriber?.receive(completion: completion)
    }

    func cancel() {
        isCancelled = true
        subscriber = nil
    }
}

public final class ReplaySubject<Output,Failure>: Subject where Failure : Error {
    private var subscriptions: [ReplaySubscription<Output, Failure>] = []
    private var values: Queue<Output>
    private let bufferSize: Int

    private var _lock = NSRecursiveLock()

    public init(bufferSize: Int) {
        self.bufferSize = bufferSize
        values = Queue<Output>(capacity: bufferSize)
    }

    public func receive<S>(subscriber: S) where S : Subscriber, S.Failure == Failure, S.Input == Output {
        let subscription = ReplaySubscription(subscriber: AnySubscriber(subscriber))
        addSubscription(subscription)
        subscriber.receive(subscription: subscription)
        values.forEach { subscription.receive($0) }
    }

    private func addSubscription(_ subscription: ReplaySubscription<Output,Failure>) {
        self._lock.lock(); defer { self._lock.unlock() }
        subscriptions.append(subscription)
    }

    public func send(_ value: Output) {
        self._lock.lock(); defer { self._lock.unlock() }
        values.enqueue(value)
        trim()
        removeCancelledSubscriptions()
        subscriptions.forEach { $0.receive(value) }
    }

    private func removeCancelledSubscriptions() {
        subscriptions.removeAll(where: { $0.isCancelled })
    }

    private func trim() {
        while self.values.count > self.bufferSize {
            _ = self.values.dequeue()
        }
    }

    public func send(completion: Subscribers.Completion<Failure>) {
        self._lock.lock(); defer { self._lock.unlock() }
        removeCancelledSubscriptions()
        subscriptions.forEach { $0.receive(completion) }
        subscriptions.removeAll()
    }

    public func send(subscription: Subscription) {
        guard let sub = subscription as? ReplaySubscription<Output,Failure> else { return }
        addSubscription(sub)
    }
}
