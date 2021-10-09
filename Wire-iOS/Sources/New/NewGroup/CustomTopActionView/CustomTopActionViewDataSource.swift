

import Foundation

// MARK: CustomTopAction

protocol CustomTopAction {}


// MARK: CustomTopActionReceiver
protocol CustomTopActionReceiver: AnyObject {
    func receiveAction(type: CustomTopAction)
}


// MARK: CustomTopActionViewDataSource
/// - parameter leftView:
/// - parameter rightView:
/// - parameter actionTarget:
protocol CustomTopActionViewDataSource: AnyObject {
    var leftView: UIView? { get }
    var rightView: UIView? { get }
    /// - important
    var actionTarget: CustomTopActionReceiver? { get set }
}



// MARK: CustomTopActionBaseViewController

class CustomTopActionBaseViewController: UIViewController, CustomTopActionReceiver {
    
    let topViewDataSource: CustomTopActionViewDataSource
    
    init(topViewDataSource: CustomTopActionViewDataSource) {
        self.topViewDataSource = topViewDataSource
        super.init(nibName: nil, bundle: nil)
        self.topViewDataSource.actionTarget = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addTopActionView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let leftView = self.topViewDataSource.leftView {
            self.view.bringSubviewToFront(leftView)
        }
        if let rightView = self.topViewDataSource.rightView {
            self.view.bringSubviewToFront(rightView)
        }
    }
    
    func addTopActionView() {
        addLeftView()
        addRightView()
    }
    
    private func addLeftView() {
        guard let leftView = self.topViewDataSource.leftView else { return }
        if self.navigationController != nil {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: leftView)
        } else {
            leftView.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview(leftView)
            NSLayoutConstraint.activate([
                leftView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0),
                leftView.topAnchor.constraint(equalTo: self.view.safeTopAnchor, constant: 0),
                leftView.widthAnchor.constraint(equalToConstant: 44),
                leftView.heightAnchor.constraint(equalToConstant: 44)
            ])
        }
    }
    
    private func addRightView() {
        guard let rightView = self.topViewDataSource.rightView else { return }
        if self.navigationController != nil {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightView)
        } else {
            rightView.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview(rightView)
        }
    }
    
    func receiveAction(type: CustomTopAction) {
    }
    
}




// MARK: ConversationRootViewControllerExpandDelegate
extension CustomTopActionBaseViewController: ConversationRootViewControllerExpandDelegate {
    func shouldExpand() {
        guard let actionView = self.topViewDataSource.rightView as? ConvGroupTopRightActionView else {
            return
        }
        actionView.shouldExpand()
    }
    
    func shouldUnexpand() {
        guard let actionView = self.topViewDataSource.rightView as? ConvGroupTopRightActionView else {
            return
        }
        actionView.shouldUnexpand()
    }
}
