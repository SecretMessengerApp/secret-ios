
import Foundation
import WireDataModel

/// A set of instances conforming to `UserType`.

struct UserSet {

    typealias Storage = Set<HashBox<UserType>>

    private var storage: Storage

    private init(storage: Storage) {
        self.storage = storage
    }

}

// MARK: - Collection

extension UserSet: Collection {

    typealias Element = UserType
    typealias Index = Storage.Index

    var isEmpty: Bool {
        return storage.isEmpty
    }

    var startIndex: Index {
        return storage.startIndex
    }

    var endIndex: Index {
        return storage.endIndex
    }

    func index(after i: Index) -> Index {
        return storage.index(after: i)
    }

    subscript(position: Index) -> UserType {
        return storage[position].value
    }

    __consuming func makeIterator() -> IndexingIterator<[UserType]> {
        return storage.map(\.value).makeIterator()
    }

}

// MARK: - Set Algebra

extension UserSet: SetAlgebra {

    init() {
        storage = Storage()
    }

    init(arrayLiteral elements: UserType...) {
        storage = Storage(elements.map(HashBox.init))
    }

    func contains(_ member: UserType) -> Bool {
        return storage.contains(HashBox(value: member))
    }

    __consuming func union(_ other: __owned UserSet) -> UserSet {
        return UserSet(storage: storage.union(other.storage))
    }

    __consuming func intersection(_ other: UserSet) -> UserSet {
        return UserSet(storage: storage.intersection(other.storage))
    }

    __consuming func symmetricDifference(_ other: __owned UserSet) -> UserSet {
        return UserSet(storage: storage.symmetricDifference(other.storage))
    }

    @discardableResult
    mutating func insert(_ newMember: __owned UserType) -> (inserted: Bool, memberAfterInsert: UserType) {
        let (inserted, memberAfterInsert) = storage.insert(HashBox(value: newMember))
        return (inserted, memberAfterInsert.value)
    }

    @discardableResult
    mutating func remove(_ member: UserType) -> UserType? {
        return storage.remove(HashBox(value: member))?.value
    }

    @discardableResult
    mutating func update(with newMember: __owned UserType) -> UserType? {
        return storage.update(with: HashBox(value: newMember))?.value
    }

    mutating func formUnion(_ other: __owned UserSet) {
        storage.formUnion(other.storage)
    }

    mutating func formIntersection(_ other: UserSet) {
        storage.formIntersection(other.storage)
    }

    mutating func formSymmetricDifference(_ other: __owned UserSet) {
        storage.formSymmetricDifference(other.storage)
    }

}
