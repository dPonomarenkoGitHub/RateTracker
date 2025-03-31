//
//  RealmManagerProtocol.swift
//  RateTracker
//
//  Created by Dmitry Ponomarenko on 31.03.2025.
//

import Foundation
import RealmSwift
import Combine

public protocol RealmManagerProtocol {
    func add<S: Sequence>(_ objects: S, update: Bool) where S.Element: Object

    func addAsync<S: Sequence>(_ objects: S, update: Bool) where S.Element: Object

    func remove<S: Sequence>(_ objects: S) where S.Element: Object

    func removeAsync<S: Sequence>(_ objects: S) where S.Element: Object

    func refresh<S: Sequence>(
        objectPrimaryKeyValues: Set<AnyHashable>,
        with newObjects: S,
        onSuccess: (() -> Void)?
    ) where S.Element: Object

    func refreshAsync<S: Sequence>(
        objectPrimaryKeyValues: Set<AnyHashable>,
        with newObjects: S,
        onSuccess: (() -> Void)?
    ) where S.Element: Object

    func object<T: Object, Key>(_ type: T.Type, forPrimaryKey key: Key) -> T?

    func objects<T: Object>(_ type: T.Type) -> Results<T>

    func write(_ block: @escaping (Realm) -> Void)

    func writeAsync(_ block: @escaping (Realm) -> Void)
}

public extension RealmCollection where Self: RealmSubscribable {
    var realmPublisher: AnyPublisher<Self, Never> {
        collectionPublisher
            .prepend(self)
            .catch { _ in Empty() }
            .eraseToAnyPublisher()
    }

    func realmPublisher(on queue: DispatchQueue) -> AnyPublisher<Self, Never> {
        collectionPublisher
            .receive(on: queue)
            .catch { _ in Empty() }
            .eraseToAnyPublisher()
    }
}
