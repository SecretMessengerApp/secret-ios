
import Foundation
import WireDataModel

/// A helper class that provides a reference to the current self user.

public class SelfUser {

    /// The underlying provider of the self user.

    public static var provider: SelfUserProvider?

    /// The current self user.
    ///
    /// Calling this property will intentionally crash if the `provider` is not configured. This is a
    /// tradeoff for the convenience of not needing to unwrap the self user, as it is available in the
    /// majority of the codebase. For safe access, go through the provider instead.

    public class var current: UserType & ZMEditableUser {
        guard let provider = provider else { fatalError("Self user provider not set") }
        return provider.selfUser
    }
}
