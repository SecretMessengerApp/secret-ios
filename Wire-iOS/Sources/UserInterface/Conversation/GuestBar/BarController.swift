

import Foundation
import Cartography

protocol Bar {
    var weight: Float { get }
}

final class BarController: UIViewController {
    private let stackView = UIStackView()
    
    public private(set) var bars: [UIViewController] = []
    
    public var topBar: UIViewController? {
        return bars.last
    }
    
    @objc(presentBar:)
    public func present(bar: UIViewController) {
        if bars.contains(bar) {
            return
        }
        
        bars.append(bar)
        
        bars.sort { (left, right) -> Bool in
            let leftWeight = (left as? Bar)?.weight ?? 0
            let rightWeight = (right as? Bar)?.weight ?? 0
            
            return leftWeight < rightWeight
        }
        
        addChild(bar)
        updateStackView()
        bar.didMove(toParent: self)
    }
    
    @objc(dismissBar:)
    public func dismiss(bar: UIViewController) {
        guard let index = bars.firstIndex(of: bar) else {
            return
        }
        bar.willMove(toParent: nil)
        bars.remove(at: index)
        
        UIView.animate(withDuration: 0.35) {
            self.stackView.removeArrangedSubview(bar.view)
            bar.view.removeFromSuperview()
        }

        bar.removeFromParent()
    }
    
    private func updateStackView() {
        UIView.animate(withDuration: 0.35) {
            self.stackView.arrangedSubviews.forEach {
                self.stackView.removeArrangedSubview($0)
                $0.removeFromSuperview()
            }
            
            self.bars.map { $0.view }.forEach(self.stackView.addArrangedSubview)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .fill

        view.addSubview(stackView)

        constrain(self.view, stackView) { view, stackView in
            stackView.edges == view.edges
        }
    }
}
