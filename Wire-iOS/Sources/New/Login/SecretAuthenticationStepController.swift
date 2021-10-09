
import UIKit

/**
 * A Secret view controller that can display the interface from an authentication step.
 */

class SecretAuthenticationStepController: AuthenticationStepViewController {
    
    /// The step to display.
    var stepDescription: AuthenticationStepDescription
    
    /// The object that coordinates authentication.
    weak var authenticationCoordinator: AuthenticationCoordinator? {
        didSet {
            stepDescription.secondaryView?.actioner = authenticationCoordinator
        }
    }
    
    // MARK: - Configuration
    
    static let mainViewHeight: CGFloat = 56
    
    static let headlineFont         = UIFont.systemFont(ofSize: 22, weight: UIFont.Weight.light)
    static let headlineSmallFont    = UIFont.systemFont(ofSize: 22, weight: UIFont.Weight.light)
    
    static let smallHeadlineFont    = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.light)
    static let smallHeadlineSmallFont    = UIFont.systemFont(ofSize: 18, weight: UIFont.Weight.light)
    
    static let subtextFont          = FontSpec(.normal, .regular).font!
    static let errorMessageFont     = FontSpec(.medium, .regular).font!
    static let textButtonFont       = FontSpec(.small, .semibold).font!
    
    // MARK: - Views
    
    private var contentStack: CustomSpacingStackView!
    
    private var headlineLabel: UILabel!
    private var subtextLabel: UILabel!
    private var subtextLabelContainer: ContentInsetView!
    private var mainView: UIView!
    fileprivate var errorLabel: UILabel!
    fileprivate var errorLabelContainer: ContentInsetView!
    
    fileprivate var secondaryViews: [UIView] = []
    fileprivate var secondaryErrorView: UIView?
    fileprivate var secondaryViewsStackView: UIStackView!
    
    fileprivate var nextButton: UIButton!
    
    private var mainViewWidthRegular: NSLayoutConstraint!
    private var mainViewWidthCompact: NSLayoutConstraint!
    private var contentCenter: NSLayoutConstraint!
    
    private var headlineLabelCenterY: NSLayoutConstraint!
    private var headlineLabelBottom: NSLayoutConstraint!
    private var headlineLabelLeftS: NSLayoutConstraint!
    private var headlineLabelLeftM: NSLayoutConstraint!
    
    private var rightItemAction: AuthenticationCoordinatorAction?
    
    var email: String?
    var password: String?
    
    var contentCenterXAnchor: NSLayoutYAxisAnchor {
        return contentStack.centerYAnchor
    }
    
    deinit {
        print("SecretAuthenticationStepController deinit ")
    }
    
    // MARK: - Initialization
    
    /**
     * Creates the view controller to display the specified interface description.
     * - parameter description: The description of the step interface.
     */
    
    required init(description: AuthenticationStepDescription) {
        self.stepDescription = description
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .dynamic(scheme: .background)
        
        createViews()
        createConstraints()
        updateBackButton()
        
        setInputValueListener()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        configureObservers()
        UIAccessibility.post(notification: .screenChanged, argument: headlineLabel)
        self.showKeyboard()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeObservers()
    }
    
    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateConstraints(forRegularLayout: false)
    }
    
    // MARK: - View Creation
    
    /**
     * Creates the main input view for the view controller. Override this method if you need a different
     * main view than the one provided by the step description, or to customize its behavior.
     * - returns: The main view to include in the stack.
     */
    
    /// Override this method to provide a different main view.
    func createMainView() -> UIView {
        return stepDescription.mainView.create()
    }
    
    private func createViews() {
        
        nextButton = UIButton(type: .custom)
        nextButton.setTitle("Next", for: .normal)
        nextButton.setTitleColor(.dynamic(scheme: .brand), for: .normal)
        nextButton.setTitleColor(.dynamic(scheme: .separator), for: .disabled)
        nextButton.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        nextButton.addTarget(self, action: #selector(rightItemTapped), for: .touchUpInside)
        
        let item = UIBarButtonItem(customView: nextButton)
        navigationItem.rightBarButtonItem = item
        nextButton.isEnabled = false
        
        let textPadding = UIEdgeInsets(top: 0, left: 32, bottom: 0, right: 32)
        
        if stepDescription.subtext != nil {
            subtextLabel = UILabel()
            subtextLabelContainer = ContentInsetView(subtextLabel, inset: textPadding)
            subtextLabel.textAlignment = .center
            subtextLabel.text = stepDescription.subtext
            subtextLabel.font = SecretAuthenticationStepController.subtextFont
            subtextLabel.textColor = .dynamic(scheme: .separator)
            subtextLabel.numberOfLines = 0
            subtextLabel.lineBreakMode = .byWordWrapping
            subtextLabelContainer.isHidden = stepDescription.subtext == nil
        }
        
        errorLabel = UILabel()
        let errorInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 24 + AccessoryTextField.ConfirmButtonWidth)
        errorLabelContainer = ContentInsetView(errorLabel, inset: errorInsets)
        errorLabel.textAlignment = .left
        errorLabel.numberOfLines = 0
        errorLabel.font = SecretAuthenticationStepController.errorMessageFont
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        updateValidation(initialValidation)
        
        mainView = createMainView()
        mainView.tintColor = .dynamic(scheme: .title)
        
        if  let textAble = self.stepDescription.mainView as? TextFieldable {
            textAble.textField?.font = UIFont.systemFont(ofSize: 22)
        }
        
        if let secondaryView = stepDescription.secondaryView {
            secondaryViews = secondaryView.views.map { $0.create() }
        }
        
        secondaryViewsStackView = UIStackView(arrangedSubviews: secondaryViews)
        secondaryViewsStackView.distribution = .equalCentering
        secondaryViewsStackView.spacing = 24
        secondaryViewsStackView.translatesAutoresizingMaskIntoConstraints = false
        
        let subviews = [subtextLabelContainer, mainView, errorLabelContainer, secondaryViewsStackView].compactMap { $0 }
        
        contentStack = CustomSpacingStackView(customSpacedArrangedSubviews: subviews)
        contentStack.axis = .vertical
        contentStack.distribution = .fill
        contentStack.alignment = .fill
        
        view.addSubview(contentStack)
        
        errorLabelContainer.alpha = stepDescription.isShowKeyBoard ? 1 : 0
        secondaryViewsStackView.alpha = stepDescription.isShowKeyBoard ? 1 : 0
        
        if let description = self.stepDescription.mainView as? TextFieldable {
            description.textField?.confirmButton.alpha = 0
            description.textField?.backgroundColor = .clear
            let text = description.textField?.placeholder ?? ""
            if stepDescription.isShowKeyBoard {
                description.textField?.attributedPlaceholder = NSAttributedString(string: text, attributes: [ .foregroundColor: UIColor.dynamic(scheme: .subtitle)])
            } else {
                description.textField?.attributedPlaceholder = NSAttributedString.init(string: text, attributes: [.foregroundColor: UIColor.clear])
            }
        }
        
        headlineLabel = UILabel()
        headlineLabel.textAlignment = .center
        headlineLabel.textColor = .dynamic(scheme: .subtitle)
        headlineLabel.text = stepDescription.headline
        headlineLabel.translatesAutoresizingMaskIntoConstraints = false
        headlineLabel.numberOfLines = 0
        headlineLabel.lineBreakMode = .byWordWrapping
        headlineLabel.accessibilityTraits.insert(.header)
        updateHeadlineLabelFont(isShowKeyBoard: stepDescription.isShowKeyBoard)
        view.addSubview(headlineLabel)
        
        showPlaceHolder(show: false)
    }
    
    private func updateHeadlineLabelFont(isShowKeyBoard: Bool) {
        if isShowKeyBoard {
            headlineLabel.font = SecretAuthenticationStepController.smallHeadlineFont
        } else {
            headlineLabel.font = SecretAuthenticationStepController.headlineFont
        }
    }
    
    func setSecondaryViewHidden(_ isHidden: Bool) {
        secondaryViewsStackView.isHidden = isHidden
    }
    
    func showPlaceHolder(show: Bool) {
        if let description = self.stepDescription.mainView as? TextFieldable {
            let text = description.textField?.placeholder ?? ""
            if show {
                description.textField?.attributedPlaceholder = NSAttributedString(string: text, attributes: [.foregroundColor: UIColor.dynamic(scheme: .subtitle)])
            } else {
                description.textField?.attributedPlaceholder = NSAttributedString(string: text, attributes: [ .foregroundColor: UIColor.clear])
            }
            
        }
    }
    
    /**
     * Updates the constrains for display in regular or compact latout.
     * - parameter isRegular: Whether the current size class is regular.
     */
    
    func updateConstraints(forRegularLayout isRegular: Bool) {
        if isRegular {
            mainViewWidthCompact.isActive = false
            mainViewWidthRegular.isActive = true
        } else {
            mainViewWidthRegular.isActive = false
            mainViewWidthCompact.isActive = true
        }
    }
    
    func updateConstraints(forKeyBoard isShow: Bool) {
        if isShow {
            showPlaceHolder(show: true)
            headlineLabelCenterY.isActive = false
            headlineLabelBottom.isActive = true
            headlineLabelLeftM.isActive = false
            headlineLabelLeftS.isActive = true
        } else {
            showPlaceHolder(show: false)
            headlineLabelCenterY.isActive = true
            headlineLabelBottom.isActive = false
            headlineLabelLeftM.isActive = true
            headlineLabelLeftS.isActive = false
        }
    }
    
    private func createConstraints() {
        contentStack.translatesAutoresizingMaskIntoConstraints = false
    
        errorLabel.setContentCompressionResistancePriority(UILayoutPriority.required, for: .vertical)
        mainView.setContentCompressionResistancePriority(UILayoutPriority.required, for: .vertical)
        mainView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
        // Spacing
        if stepDescription.subtext != nil {
            subtextLabel.setContentCompressionResistancePriority(UILayoutPriority.required, for: .vertical)
            subtextLabel.widthAnchor.constraint(equalTo: contentStack.widthAnchor, constant: -64).isActive = true
            contentStack.wr_addCustomSpacing(44, after: subtextLabelContainer)
        }
        
        contentStack.wr_addCustomSpacing(16, after: mainView)
        contentStack.wr_addCustomSpacing(16, after: errorLabelContainer)
        
        // Fixed Constraints
        contentCenter = contentCenterXAnchor.constraint(equalTo: view.centerYAnchor, constant: -100)
        
        headlineLabelCenterY = headlineLabel.centerYAnchor.constraint(equalTo: mainView.centerYAnchor)
        headlineLabelBottom = headlineLabel.bottomAnchor.constraint(equalTo: mainView.topAnchor, constant: 20)
        
        headlineLabelLeftS = headlineLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 12)
        headlineLabelLeftM = headlineLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 22)
        
        NSLayoutConstraint.activate([
            // contentStack
            contentStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            contentCenter,
            
            // labels
            headlineLabel.heightAnchor.constraint(equalToConstant: SecretAuthenticationStepController.mainViewHeight),
            
            // height
            mainView.heightAnchor.constraint(greaterThanOrEqualToConstant: SecretAuthenticationStepController.mainViewHeight),
            secondaryViewsStackView.heightAnchor.constraint(greaterThanOrEqualToConstant: 13),
            errorLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 19)
            ])
        
        // Adaptive Constraints
        mainViewWidthRegular = mainView.widthAnchor.constraint(equalToConstant: 375)
        mainViewWidthCompact = mainView.widthAnchor.constraint(equalTo: view.widthAnchor)
        
//        updateConstraints(forRegularLayout: traitCollection.horizontalSizeClass == .regular)
        updateConstraints(forRegularLayout: false)

        
        updateConstraints(forKeyBoard: stepDescription.isShowKeyBoard)
    }
    
    // MARK: - Back Button
    
    private func updateBackButton() {
        guard navigationController?.viewControllers.count > 1 else {
            return
        }
        
        let button = AuthenticationNavigationBar.makeBackButton()
        button.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: button)
    }
    
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Keyboard
    
    private func configureObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardPresentation), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardPresentation), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func removeObservers() {
        NotificationCenter.default.removeObserver(self)
    }
    
    func setInputValueListener() {
        if var description = self.stepDescription.mainView as? TextFieldable {
            description.editingChangedListener = {
                [unowned self] value in
                if let description = self.stepDescription.mainView as? TextFieldable {
                    self.nextButton.isEnabled = description.textField?.enableConfirmButton?() ?? false
                }
                if  value == nil || value?.count == 0 {
                    guard self.errorLabelContainer.alpha == 1 else {return}
                    self.updateHeadlineLabelFont(isShowKeyBoard: false)
                    self.updateConstraints(forKeyBoard: false)
                    UIView.animate(withDuration: 0.3, animations: {
                        self.view.layoutIfNeeded()
                        self.errorLabelContainer.alpha = 0
                        self.secondaryViewsStackView.alpha = 0
                    }) { (_) in
                    }
                } else {
                    guard self.errorLabelContainer.alpha == 0 else {return}
                    self.updateHeadlineLabelFont(isShowKeyBoard: true)
                    self.updateConstraints(forKeyBoard: true)
                    UIView.animate(withDuration: 0.3, animations: {
                        self.view.layoutIfNeeded()
                        self.errorLabelContainer.alpha = 1
                        self.secondaryViewsStackView.alpha = 1
                    }) { (_) in
                    }
                }
            }
        }
    }
    
    @objc func rightItemTapped() {
        if let description = self.stepDescription.mainView as? TextFieldable {
            self.valueSubmitted((description.textField?.text)!)
        }
    }
    
    @objc private func handleKeyboardPresentation(notification: Notification) {
        updateOffsetForKeyboard(in: notification)
    }
    
    private func updateOffsetForKeyboard(in notification: Notification) {
        // Do not change the keyboard frame when there is a modal alert with a text field
        guard presentedViewController == nil else { return }
        
        let keyboardFrame = UIView.keyboardFrame(in: view, forKeyboardNotification: notification)
        updateKeyboard(with: keyboardFrame)
    }
    
    private func updateKeyboard(with keyboardFrame: CGRect) {
        let minimumKeyboardSpacing: CGFloat = 24
        let currentOffset = abs(contentCenter.constant)
        
        // Reset the frame when the keyboard is dismissed
        if keyboardFrame.height == 0 {
            return contentCenter.constant = 0
        }
        
        // Calculate the height of the content under the keyboard
        let contentRect = CGRect(x: contentStack.frame.origin.x,
                                 y: contentStack.frame.origin.y + currentOffset,
                                 width: contentStack.frame.width,
                                 height: contentStack.frame.height + minimumKeyboardSpacing)
        
        let offset = keyboardFrame.intersection(contentRect).height
        
        // Adjust if we need more space
        if offset > currentOffset {
            contentCenter.constant = -offset
        }
    }
    
    func clearInputFields() {
        (mainView as? TextContainer)?.text = nil
        showKeyboard()
    }
    
    func showKeyboard() {
        mainView.becomeFirstResponderIfPossible()
    }
    
    func dismissKeyboard() {
        mainView.resignFirstResponder()
    }
    
    override func accessibilityPerformMagicTap() -> Bool {
        return (mainView as? MagicTappable)?.performMagicTap() == true
    }
    
}

// MARK: - Event Handling

extension SecretAuthenticationStepController {
    
    func displayError(_ error: Error) {
         // no-op
    }
    
    func executeErrorFeedbackAction(_ feedbackAction: AuthenticationErrorFeedbackAction) {
        switch feedbackAction {
        case .clearInputFields:
            clearInputFields()
        case .showGuidanceDot:
            break
        }
    }
    
    func valueSubmitted(_ value: Any) {
        dismissKeyboard()
        guard let input = value as? String else {
            return
        }
        if self.stepDescription is SecretLoginEmailStepDescription {
            self.pushToPasswordViewController(input: input)
            return
        }
        if self.stepDescription is SecretLoginPasswordStepDescription {
            self.password = input
            if let email = self.email, let password = self.password {
                authenticationCoordinator?.handleUserInput((email, password))
                return
            }
        }
        authenticationCoordinator?.handleUserInput(input)
    }
    
    func pushToPasswordViewController(input: String) {
        let description = SecretLoginPasswordStepDescription()
        let controller = SecretAuthenticationStepController(description: description)
        controller.authenticationCoordinator = self.authenticationCoordinator
        controller.authenticationCoordinator?.currentViewController = controller
        let mainView = description.mainView
        mainView.valueSubmitted = { [weak controller] value in
            controller?.valueSubmitted(value)
        }
        mainView.valueValidated = { [weak controller] validation in
            controller?.valueValidated(validation)
        }
        controller.email = input
        authenticationCoordinator?.stateController.stack.append(.provideCredentials(.email, nil))
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    var initialValidation: ValueValidation? {
        return (stepDescription as? DefaultValidatingStepDescription)?.initialValidation
    }
    
    func valueValidated(_ validation: ValueValidation?) {
        updateValidation(validation ?? initialValidation)
    }
    
    func updateValidation(_ suggestedValidation: ValueValidation?) {
        switch suggestedValidation {
        case .info(let infoText)?:
            errorLabel.accessibilityIdentifier = "validation-rules"
            errorLabel.text = infoText
            errorLabel.textColor = UIColor.dynamic(scheme: .placeholder)
            errorLabelContainer.isHidden = false
            showSecondaryView(for: nil)
            
        case .error(let error, let showVisualFeedback)?:
            if !showVisualFeedback {
                // If we do not want to show an error (eg if all the text was deleted,
                // either use the initial info or clear the error
                return updateValidation(initialValidation)
            }
            
            errorLabel.accessibilityIdentifier = "validation-failure"
            errorLabel.text = error.errorDescription
            errorLabel.textColor = UIColor.from(scheme: .errorIndicator, variant: .light)
            errorLabelContainer.isHidden = false
            showSecondaryView(for: error)
            
        case nil:
            clearError()
        }
    }
}

// MARK: - Error handling

extension SecretAuthenticationStepController {
    func clearError() {
        errorLabel.text = nil
        errorLabelContainer.isHidden = true
        showSecondaryView(for: nil)
    }
    
    func showSecondaryView(for error: Error?) {
        if let view = self.secondaryErrorView {
            secondaryViewsStackView.removeArrangedSubview(view)
            view.removeFromSuperview()
            secondaryViewsStackView.arrangedSubviews.forEach { $0.isHidden = false }
            self.secondaryErrorView = nil
        }
        
        if let error = error, let errorDescription = stepDescription.secondaryView?.display(on: error) {
            let view = errorDescription.create()
            self.secondaryErrorView = view
            secondaryViewsStackView.arrangedSubviews.forEach { $0.isHidden = true }
            secondaryViewsStackView.addArrangedSubview(view)
        }
    }
    
}


