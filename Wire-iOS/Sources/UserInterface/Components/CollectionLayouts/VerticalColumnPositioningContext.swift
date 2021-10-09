
import UIKit

/**
 * The context for computing the position of items.
 */

struct VerticalColumnPositioningContext {

    /// The width of the collection view container, minus insets.
    let contentWidth: CGFloat

    /// The number of columns that will organize the contents.
    let numberOfColumns: Int

    /// The spacing between items inside the same column.
    let interItemSpacing: CGFloat

    /// The spacing between columns.
    let interColumnSpacing: CGFloat

    /// The start position of each columns.
    let columns: [CGFloat]

    /// The width of a single column.
    let columnWidth: CGFloat

    init(contentWidth: CGFloat, numberOfColumns: Int, interItemSpacing: CGFloat, interColumnSpacing: CGFloat) {
        self.contentWidth = contentWidth
        self.numberOfColumns = numberOfColumns
        self.interItemSpacing = interItemSpacing
        self.interColumnSpacing = interColumnSpacing

        let totalSpacing = (CGFloat(numberOfColumns - 1) * interColumnSpacing)
        let columnWidth = ((contentWidth - totalSpacing) / CGFloat(numberOfColumns))

        self.columns = (0 ..< numberOfColumns).map {
            let base = CGFloat($0) * columnWidth
            let precedingSpacing = CGFloat($0) * interColumnSpacing
            return base + precedingSpacing
        }

        self.columnWidth = columnWidth
    }

}
