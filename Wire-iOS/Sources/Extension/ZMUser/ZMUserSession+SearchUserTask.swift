//
//  ZMUserSession+SearchUserTask.swift
//  Wire-iOS
//


import Foundation

extension ZMUserSession {
    private static var searchTasks: [(directory: SearchDirectory, task: SearchTask?)] = []


    func seachUser(by handle: String,
                   searchOptions: SearchOptions = [.directory],
                   completion: @escaping (ZMSearchUser?) -> Void) {
        guard let session = ZMUserSession.shared() else { completion(nil); return }
        type(of: self).searchTasks.forEach {
            $0.directory.tearDown()
            $0.task?.cancel()
        }
        type(of: self).searchTasks.removeAll()
        let request = SearchRequest(query: handle, searchOptions: searchOptions, team: nil)
        let searchDirectory = SearchDirectory(userSession: session)
        let task = searchDirectory.perform(request)
        task.onResult { result, isCompleted in
            if isCompleted, let user = result.directory.first {
                completion(user)
            } else {
                completion(nil)
            }
        }
        task.startHandleRemoteSearch()
        type(of: self).searchTasks.append((searchDirectory, task))
    }
    

    func searchContacts(_ completion: @escaping ([ZMUser]) -> Void) {
        guard let session = ZMUserSession.shared() else { completion([]); return }
        type(of: self).searchTasks.forEach {
            $0.directory.tearDown()
            $0.task?.cancel()
        }
        type(of: self).searchTasks.removeAll()
        let request = SearchRequest(query: "", searchOptions: [.contacts])
        let searchDirectory = SearchDirectory(userSession: session)
        let task = searchDirectory.perform(request)
        task.onResult { result, isCompleted in
            guard isCompleted else {return}
            completion(result.contacts)
            searchDirectory.tearDown()
        }
        task.start()
        type(of: self).searchTasks.append((searchDirectory, task))
    }
}
