

import UIKit
import Cartography

protocol EphemeralKeyboardViewControllerDelegate: class {
    func ephemeralKeyboardWantsToBeDismissed(_ keyboard: EphemeralKeyboardViewController)

    func ephemeralKeyboard(
        _ keyboard: EphemeralKeyboardViewController,
        didSelectMessageTimeout timeout: TimeInterval
    )
}

extension ZMConversation {

    var destructionTimeout: MessageDestructionTimeoutValue? {
        switch messageDestructionTimeout {
        case .local(let value)?:
            return value
        case .synced(let value)?:
            return value
        default:
            return nil
        }
    }
    
    var timeoutImage: UIImage? {
        guard let value = self.destructionTimeout else { return nil }
        return timeoutImage(for: value)
    }

    var disabledTimeoutImage: UIImage? {
        guard let value = self.destructionTimeout else { return nil }
        return timeoutImage(for: value, withColor: .lightGraphite)
    }
    
    private func timeoutImage(for timeout: MessageDestructionTimeoutValue, withColor color: UIColor = UIColor.accent()) -> UIImage? {
        if timeout.isYears    { return StyleKitIcon.timeoutYear.makeImage(size: 64, color: color) }
        if timeout.isWeeks    { return StyleKitIcon.timeoutWeek.makeImage(size: 64, color: color) }
        if timeout.isDays     { return StyleKitIcon.timeoutDay.makeImage(size: 64, color: color) }
        if timeout.isHours    { return StyleKitIcon.timeoutHour.makeImage(size: 64, color: color) }
        if timeout.isMinutes  { return StyleKitIcon.timeoutMinute.makeImage(size: 64, color: color) }
        if timeout.isSeconds  { return StyleKitIcon.timeoutSecond.makeImage(size: 64, color: color) }
        return nil
    }
}

extension UIAlertController {
    enum AlertError: Error {
        case userRejected
    }
    
    static func requestCustomTimeInterval(over controller: UIViewController,
                                          with completion: @escaping (Result<TimeInterval>)->()) {
        let alertController = UIAlertController(title: "Custom timer", message: nil, preferredStyle: .alert)
        alertController.addTextField { (textField: UITextField) in
            textField.keyboardType = .decimalPad
            textField.placeholder = "Time interval in seconds"
        }
        let confirmAction = UIAlertAction(title: "OK", style: .default) { [weak alertController] action in
            guard let input = alertController?.textFields?.first,
                let inputText = input.text,
                let selectedTimeInterval = TimeInterval(inputText) else {
                    return
            }
            
            completion(.success(selectedTimeInterval))
        }
        
        alertController.addAction(confirmAction)
        
        let cancelAction = UIAlertAction.cancel {
            completion(.failure(AlertError.userRejected))
        }
        
        alertController.addAction(cancelAction)
        controller.present(alertController, animated: true) { [weak alertController] in
            guard let input = alertController?.textFields?.first else {
                return
            }
            
            input.becomeFirstResponder()
        }
    }
}

final class EphemeralKeyboardViewController: UIViewController {

    weak var delegate: EphemeralKeyboardViewControllerDelegate?

    fileprivate let timeouts: [MessageDestructionTimeoutValue?]

    let titleLabel = UILabel()
    var pickerFont: UIFont? = .normalSemiboldFont
    var pickerColor: UIColor? = UIColor.from(scheme: .textForeground, variant: .dark)
    var separatorColor: UIColor? = UIColor.from(scheme: .separator, variant: .light)

    private let conversation: ZMConversation!
    private let picker = PickerView()


    /// Allow conversation argument is nil for testing
    ///
    /// - Parameter conversation: nil for testing only
    init(conversation: ZMConversation!) {
        self.conversation = conversation
        if Bundle.developerModeEnabled {
            timeouts = MessageDestructionTimeoutValue.all + [nil]
        }
        else {
            timeouts = MessageDestructionTimeoutValue.all
        }
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        createConstraints()

        view.backgroundColor = UIColor.from(scheme: .textForeground, variant: .light)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        guard let index = timeouts.firstIndex(of: MessageDestructionTimeoutValue(rawValue: conversation.messageDestructionTimeoutValue)) else { return }
        picker.selectRow(index, inComponent: 0, animated: false)
    }

    private func setupViews() {
        
        picker.delegate = self
        picker.dataSource = self
        picker.backgroundColor = .clear
        picker.tintColor = .red
        picker.showsSelectionIndicator = true
        picker.selectorColor = separatorColor
        picker.didTapViewClosure = dismissKeyboardIfNeeded

        titleLabel.textAlignment = .center
        titleLabel.textColor = UIColor.from(scheme: .textForeground, variant: .dark)
        titleLabel.font = .smallSemiboldFont

        titleLabel.text = "input.ephemeral.title".localized(uppercased: true)
        titleLabel.numberOfLines = 0
        titleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        [titleLabel, picker].forEach(view.addSubview)
    }

    func dismissKeyboardIfNeeded() {
        delegate?.ephemeralKeyboardWantsToBeDismissed(self)
    }

    private func createConstraints() {
        constrain(view, picker, titleLabel) { view, picker, label in
            label.leading == view.leading + 16
            label.trailing == view.trailing - 16
            label.top == view.top + 16
            picker.top == label.bottom
            picker.bottom == view.bottom - 16
            picker.leading == view.leading + 32
            picker.trailing == view.trailing - 32
        }
    }

    fileprivate func displayCustomPicker() {
        delegate?.ephemeralKeyboardWantsToBeDismissed(self)
        
        UIAlertController.requestCustomTimeInterval(over: UIApplication.shared.topmostViewController(onlyFullScreen: true)!) { [weak self] result in
            
            guard let `self` = self else {
                return
            }
            
            switch result {
            case .success(let value):
                self.delegate?.ephemeralKeyboard(self, didSelectMessageTimeout: value)
            default:
                break
            }
            
        }
    }
}


/// This class is a workaround to make the selector color
/// of a `UIPickerView` changeable. It relies on the height of the selector
/// views, which means that the behaviour could break in future iOS updates.
class PickerView: UIPickerView, UIGestureRecognizerDelegate {

    var selectorColor: UIColor? = nil
    var tapRecognizer: UIGestureRecognizer! = nil
    var didTapViewClosure: (() -> Void)? = nil

    init() {
        super.init(frame: .zero)
        tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapView))
        tapRecognizer.delegate = self
        addGestureRecognizer(tapRecognizer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        for subview in subviews where subview.bounds.height <= 1.0 {
            subview.backgroundColor = selectorColor
        }
    }

    @objc func didTapView(sender: UIGestureRecognizer) {
        guard recognizerInSelectedRow(sender) else { return }
        didTapViewClosure?()
    }

    /// Used to determine if the recognizers touches are in the area
    /// of the selected row of the `UIPickerView`, this is done by asking the
    /// delegate for the rowHeight and using it to caculate the rect 
    /// of the center (selected) row.
    private func recognizerInSelectedRow(_ recognizer: UIGestureRecognizer) -> Bool {
        guard selectedRow(inComponent: 0) != -1 else { return false }
        guard let height = delegate?.pickerView?(self, rowHeightForComponent: 0) else { return false }
        let rect = bounds.insetBy(dx: 0, dy: bounds.midY - height / 2)
        let location = recognizer.location(in: self)
        return rect.contains(location)
    }

    // MARK: - UIGestureRecognizerDelegate

    // We want the tapgesture recognizer to fire when the selected row is tapped,
    // but need to make sure the scrolling behaviour and taps outside the selected row still
    // get propagated (other wise the scroll-to behaviour would break when tapping on another row) etc.

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return gestureRecognizer == tapRecognizer && recognizerInSelectedRow(gestureRecognizer)
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return otherGestureRecognizer == tapRecognizer && recognizerInSelectedRow(gestureRecognizer)
    }

}


extension EphemeralKeyboardViewController: UIPickerViewDelegate, UIPickerViewDataSource {

    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 35
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return timeouts.count
    }

    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        guard let font = pickerFont, let color = pickerColor else { return nil }
        let timeout = timeouts[row]
        if let actualTimeout = timeout, let title = actualTimeout.localizedText {
            return title && font && color
        }
        else {
            return "Custom" && font && color
        }
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let timeout = timeouts[row]
        
        if let actualTimeout = timeout {
            delegate?.ephemeralKeyboard(self, didSelectMessageTimeout: actualTimeout.rawValue)
        }
        else {
            displayCustomPicker()
        }
    }
    
}
