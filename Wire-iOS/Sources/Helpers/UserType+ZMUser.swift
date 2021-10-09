

extension UserType {

    /// Return the ZMUser associated with the generic user, if available.
    var zmUser: ZMUser? {
        if let searchUser = self as? ZMSearchUser {
            return searchUser.user
        } else if let zmUser = self as? ZMUser {
            return zmUser
        } else {
            return nil
        }
    }

}
