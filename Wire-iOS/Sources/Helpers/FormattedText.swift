
import Foundation
import FormatterKit

/**
 * A namespace to generate formatted text from raw data.
 *
 * It currently supports:
 * - list formatting from an array
 */

enum FormattedText {

    private static let legacayArrayFormatter: TTTArrayFormatter = {
        let formatter = TTTArrayFormatter()
        formatter.conjunction = ""
        return formatter
    }()

    /**
     * Creates a string that describes an array separated by commas.
     * - parameter array: The array to describe.
     * - returns: The description of the array.
     */

    static func list(from array: [String]) -> String {
        #warning("TODO iOS 13: Use the Foundation list formatter.")
        return legacayArrayFormatter.string(from: array)
    }

}
