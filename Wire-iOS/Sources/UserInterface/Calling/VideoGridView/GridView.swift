
import Foundation

fileprivate extension NSLayoutConstraint.Axis{
    var flipped: NSLayoutConstraint.Axis {
        switch self {
        case .horizontal: return .vertical
        case .vertical: return .horizontal
        @unknown default:
            fatalError()
        }
    }
}

class GridView: UIStackView {
    
    let upperHorizontalStackerView: UIStackView! = UIStackView(arrangedSubviews: [])
    let lowerHorizontalStackerView: UIStackView! = UIStackView(arrangedSubviews: [])

    var layoutDirection: NSLayoutConstraint.Axis = .vertical {
        didSet {
            axis = layoutDirection
            lowerHorizontalStackerView.axis = layoutDirection.flipped
            upperHorizontalStackerView.axis = layoutDirection.flipped
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        lowerHorizontalStackerView.axis = .horizontal
        upperHorizontalStackerView.axis = .horizontal
        
        lowerHorizontalStackerView.distribution = .fillEqually
        upperHorizontalStackerView.distribution = .fillEqually
        
        self.distribution = .fillEqually
        self.axis = .vertical
        self.addArrangedSubview(upperHorizontalStackerView)
        self.addArrangedSubview(lowerHorizontalStackerView)
    }
    
    var gridSubviews: [UIView] {
        return upperHorizontalStackerView.arrangedSubviews + lowerHorizontalStackerView.arrangedSubviews
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func append(view: UIView) {
        if upperHorizontalStackerView.arrangedSubviews.count <= lowerHorizontalStackerView.arrangedSubviews.count {
            upperHorizontalStackerView.addArrangedSubview(view)
        } else {
            lowerHorizontalStackerView.addArrangedSubview(view)
        }
        
        updateVisibleStacksViews()
    }
    
    func remove(view: UIView) {
        if let view = upperHorizontalStackerView.arrangedSubviews.first(where: { $0 == view }) {
            upperHorizontalStackerView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        
        if let view = lowerHorizontalStackerView.arrangedSubviews.first(where: { $0 == view }) {
            lowerHorizontalStackerView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        
        rearrangeViews()
        updateVisibleStacksViews()
    }
    
    private func reinsert(view: UIView) {
        remove(view: view)
        append(view: view)
    }
    
    private func rearrangeViews() {
        if lowerHorizontalStackerView.arrangedSubviews.isEmpty, upperHorizontalStackerView.arrangedSubviews.count > 1, let view = upperHorizontalStackerView.arrangedSubviews.last {
            reinsert(view: view)
        }
        
        if upperHorizontalStackerView.arrangedSubviews.isEmpty, lowerHorizontalStackerView.arrangedSubviews.count > 1, let view = lowerHorizontalStackerView.arrangedSubviews.last {
            reinsert(view: view)
        }
    }
    
    private func updateVisibleStacksViews() {
        upperHorizontalStackerView.isHidden = upperHorizontalStackerView.arrangedSubviews.isEmpty
        lowerHorizontalStackerView.isHidden = lowerHorizontalStackerView.arrangedSubviews.isEmpty
    }
    
}
