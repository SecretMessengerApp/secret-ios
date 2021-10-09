
import Foundation

extension UserType {
    
    var nameTokens: [String] {
        return name?.components(separatedBy: CharacterSet.alphanumerics.inverted) ?? []
    }
}

extension ZMUser {
    static func searchForMentions(in users: [UserType], with query: String) -> [UserType] {
        
        let usersToSearch = users.filter { user in
            return !user.isSelfUser && !user.isServiceUser
        }
        
        if query == "" {
            return usersToSearch
        }
        
        let query = query.lowercased().normalizedForMentionSearch() as String
        let rules: [ ((UserType) -> Bool) ] = [
            { $0.name?.lowercased().normalizedForMentionSearch()?.hasPrefix(query) ?? false },
            { $0.nameTokens.first(where: { $0.lowercased().normalizedForMentionSearch()?.hasPrefix(query) ?? false }) != nil },
            { $0.handle?.lowercased().normalizedForMentionSearch()?.hasPrefix(query) ?? false },
            { $0.name?.lowercased().normalizedForMentionSearch().contains(query) ?? false },
            { $0.handle?.lowercased().normalizedForMentionSearch()?.contains(query) ?? false }
        ]
        
        var foundUsers = Set<HashBox<UserType>>()
        var results: [UserType] = []
        
        rules.forEach { rule in
            let matches = usersToSearch.filter({ rule($0) }).filter { !foundUsers.contains(HashBox(value: $0)) }
                .sorted(by: { $0.name < $1.name })
            foundUsers = foundUsers.union(matches.map(HashBox.init))
            results = results + matches
        }
        
        return results
    }
}
