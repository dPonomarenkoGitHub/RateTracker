//
//  RealmManager.swift
//  RateTracker
//
//  Created by Dmitry Ponomarenko on 31.03.2025.
//

import Foundation
import RealmSwift

private enum Migrations: UInt64 {
    case initial = 1_000
}

final class RealmManager: RealmManagerProtocol {
    static let shared = RealmManager()

    private let configuration: Realm.Configuration
    private let queue = DispatchQueue(label: "io.ratetracker.realm")

    init() {
        self.configuration = Realm.Configuration(
            schemaVersion: Migrations.initial.rawValue,
            migrationBlock: { _, _ in
            },
            shouldCompactOnLaunch: { totalBytes, usedBytes in
                // totalBytes refers to the size of the file on disk in bytes (data + free space)
                // usedBytes refers to the number of bytes used by data in the file
                // Compact if the file is over 200MB in size and less than 50% 'used'
                let threshold = 200 * 1_024 * 1_024
                return (totalBytes > threshold) && (Double(usedBytes) / Double(totalBytes)) < 0.5
            }
        )
    }

    func makeRealm() -> Realm {
        do {
            return try Realm(configuration: configuration)
        } catch {
            fatalError("Failed to get Realm")
        }
    }

    func add<S: Sequence>(_ objects: S, update: Bool) where S.Element: Object {
        addObjects(objects) { [weak self] block in
            self?.queue.sync(execute: block)
        }
    }

    func addAsync<S: Sequence>(_ objects: S, update: Bool) where S.Element: Object {
        addObjects(objects) { [weak self] block in
            self?.queue.async(execute: block)
        }
    }

    func refresh<S: Sequence>(
        objectPrimaryKeyValues: Set<AnyHashable>,
        with newObjects: S,
        onSuccess: (() -> Void)?
    ) where S.Element: Object {
        refreshObjects(objectPrimaryKeyValues: objectPrimaryKeyValues, with: newObjects, onSuccess: onSuccess) { [weak self] block in
            self?.queue.sync(execute: block)
        }
    }

    func refreshAsync<S: Sequence>(
        objectPrimaryKeyValues: Set<AnyHashable>,
        with newObjects: S,
        onSuccess: (() -> Void)?
    ) where S.Element: Object {
        refreshObjects(objectPrimaryKeyValues: objectPrimaryKeyValues, with: newObjects, onSuccess: onSuccess) { [weak self] block in
            self?.queue.async(execute: block)
        }
    }

    func remove<S: Sequence>(_ objects: S) where S.Element: Object {
        removeObjects(objects) { [weak self] block in
            self?.queue.sync(execute: block)
        }
    }

    func removeAsync<S: Sequence>(_ objects: S) where S.Element: Object {
        removeObjects(objects) { [weak self] block in
            self?.queue.async(execute: block)
        }
    }

    func objects<T: Object>(_ type: T.Type) -> Results<T> {
        let realm = makeRealm()
        return realm.objects(type)
    }

    func object<T: Object, Key>(_ type: T.Type, forPrimaryKey key: Key) -> T? {
        let realm = makeRealm()
        return realm.object(ofType: type, forPrimaryKey: key)
    }

    func write(_ block: @escaping (Realm) -> Void) {
        queue.sync {
            autoreleasepool {
                do {
                    let realm = self.makeRealm()
                    try realm.safeWrite {
                        block(realm)
                    }
                } catch {
                    debugPrint(error)
                }
            }
        }
    }

    func writeAsync(_ block: @escaping (Realm) -> Void) {
        queue.async {
            autoreleasepool {
                do {
                    let realm = self.makeRealm()
                    try realm.safeWrite {
                        block(realm)
                    }
                } catch {
                    debugPrint(error)
                }
            }
        }
    }

    private func addObjects<S: Sequence>(
        _ objects: S,
        executionBlock: @escaping (@escaping () -> Void) -> Void
    ) where S.Element: Object {
        executionBlock {
            autoreleasepool {
                do {
                    let realm = self.makeRealm()
                    try realm.safeWrite {
                        realm.add(objects, update: .modified)
                    }
                } catch {
                    debugPrint(error)
                }
            }
        }
    }

    private func removeObjects<S: Sequence>(
        _ objects: S,
        executionBlock: @escaping (@escaping () -> Void) -> Void
    ) where S.Element: Object {
        executionBlock {
            autoreleasepool {
                do {
                    let realm = self.makeRealm()
                    try realm.safeWrite {
                        realm.delete(objects)
                    }
                } catch {
                    debugPrint(error)
                }
            }
        }
    }

    private func refreshObjects<S: Sequence>(
        objectPrimaryKeyValues: Set<AnyHashable>,
        with newObjects: S,
        onSuccess: (() -> Void)?,
        executionBlock: @escaping (@escaping () -> Void) -> Void
    ) where S.Element: Object {
        executionBlock {
            autoreleasepool {
                do {
                    guard let primaryKey = S.Element.primaryKey() else {
                        assertionFailure("Object \(S.Element.self) does not have a primary key")
                        return
                    }
                    let newObjectKeys = Set(newObjects.compactMap { $0.value(forKey: primaryKey) as? AnyHashable })
                    let keysToRemove = objectPrimaryKeyValues.subtracting(newObjectKeys)
                    let realm = self.makeRealm()
                    let objectsToRemove = realm
                        .objects(S.Element.self)
                        .filter("\(primaryKey) IN %@", keysToRemove)
                    try realm.safeWrite {
                        if !objectsToRemove.isEmpty {
                            realm.delete(objectsToRemove)
                        }
                        realm.add(newObjects, update: .modified)
                    }
                    onSuccess?()
                } catch {
                    debugPrint(error)
                }
            }
        }
    }
}

// swiftlint:disable:next strict_fileprivate
fileprivate extension Realm {
    func safeWrite(_ block: (() throws -> Void)) throws {
        if isInWriteTransaction {
            try block()
        } else {
            try write(block)
        }
    }
}
