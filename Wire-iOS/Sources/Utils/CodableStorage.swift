//
//  DecodableStorage.swift
//  Wire-iOS
//


import Foundation

class CodableStorage<T: Codable> {

    private init() {}

    enum Where {
        case documents, caches
    }

    static func store(_ encodable: T, to: Where = .documents, name: String) {
        guard let url = get(url: to, name: name) else { return }
        do {
            if FileManager.default.fileExists(atPath: url.path) {
                try FileManager.default.removeItem(at: url)
            }
            let data = try JSONEncoder().encode(encodable)
            FileManager.default.createFile(atPath: url.path, contents: data, attributes: nil)
        } catch {
            fatalError(error.localizedDescription)
        }
    }

    static func retrieve(name: String, from: Where = .documents) -> T? {
        guard
            let url = get(url: from, name: name),
            FileManager.default.fileExists(atPath: url.path),
            let data = FileManager.default.contents(atPath: url.path)
            else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }

    static func remove(_ name: String, from: Where) {
        if
            let url = get(url: from, name: name),
            FileManager.default.fileExists(atPath: url.path) {
            do {
                try FileManager.default.removeItem(at: url)
            } catch {
                fatalError(error.localizedDescription)
            }
        }
    }

    static private func get(url from: Where, name: String) -> URL? {
        var searchPathDirectory: FileManager.SearchPathDirectory
        switch from {
        case .documents: searchPathDirectory = .documentDirectory
        case .caches: searchPathDirectory = .cachesDirectory
        }
        return FileManager.default
            .urls(for: searchPathDirectory, in: .userDomainMask)
            .first?
            .appendingPathComponent(name)
    }
}
