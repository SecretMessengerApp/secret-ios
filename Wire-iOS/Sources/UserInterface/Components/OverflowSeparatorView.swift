

import Foundation

final class OverflowSeparatorView: UIView {

    var inverse: Bool = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.applyStyle()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.applyStyle()
    }
    
    private func applyStyle() {
        self.backgroundColor = .dynamic(scheme: .separator)
        self.alpha = 0
    }
    
    override var intrinsicContentSize: CGSize {
        get {
            return CGSize(width: UIView.noIntrinsicMetric, height: .hairline)
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView!) {
        if inverse {
            let (height, contentHeight) = (scrollView.bounds.height, scrollView.contentSize.height)
            let offsetY = scrollView.contentOffset.y
            let showSeparator = contentHeight - offsetY > height
            alpha = showSeparator ? 1 : 0
        } else {
            self.alpha = scrollView.contentOffset.y > 0 ? 1 : 0
        }
    }
}

