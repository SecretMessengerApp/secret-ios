
import UIKit

/**
 * A view controller that can display the interface from an authentication step.
 */

class AuthenticationStepController: AuthenticationStepViewController {

    /// The step to display.
    let stepDescription: AuthenticationStepDescription

    /// The object that coordinates authentication.
    weak var authenticationCoordinator: AuthenticationCoordinator? {
        didSet {
            stepDescription.secondaryView?.actioner = authenticationCoordinator
        }
    }

    // MARK: - Configuration

    static let mainViewHeight: CGFloat = 56

    static let headlineFont         = UIFont.systemFont(ofSize: 40, weight: UIFont.Weight.light)
    static let headlineSmallFont    = UIFont.systemFont(ofSize: 32, weight: UIFont.Weight.light)
    static let subtextFont          = FontSpec(.normal, .regular).font!
    static let errorMessageFont     = FontSpec(.medium, .regular).font!
    static let textButtonFont       = FontSpec(.small, .semibold).font!

    // MARK: - Views

    private var contentStack: CustomSpacingStackView!

    private var headlineLabel: UILabel!
    private var headlineLabelContainer: ContentInsetView!
    private var subtextLabel: UILabel!
    private var subtextLabelContainer: ContentInsetView!
    private var mainView: UIView!
    fileprivate var errorLabel: UILabel!
    fileprivate var errorLabelContainer: ContentInsetView!

    fileprivate var secondaryViews: [UIView] = []
    fileprivate var secondaryErrorView: UIView?
    fileprivate var secondaryViewsStackView: UIStackView!

    private var mainViewWidthRegular: NSLayoutConstraint!
    private var mainViewWidthCompact: NSLayoutConstraint!
    private var contentCenter: NSLayoutConstraint!

    private var rightItemAction: AuthenticationCoordinatorAction?

    var contentCenterXAnchor: NSLayoutYAxisAnchor {
        return contentStack.centerYAnchor
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
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        configureObservers()
        showKeyboard()
        UIAccessibility.post(notification: .screenChanged, argument: headlineLabel)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeObservers()
    }

    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateConstraints(forRegularLayout: traitCollection.horizontalSizeClass == .regular)
        updateHeadlineLabelFont()
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
        let textPadding = UIEdgeInsets(top: 0, left: 32, bottom: 0, right: 32)

        headlineLabel = UILabel()
        headlineLabelContainer = ContentInsetView(headlineLabel, inset: textPadding)
        headlineLabel.textAlignment = .center
        headlineLabel.textColor = .dynamic(scheme: .title)
        headlineLabel.text = stepDescription.headline
        headlineLabel.translatesAutoresizingMaskIntoConstraints = false
        headlineLabel.numberOfLines = 0
        headlineLabel.lineBreakMode = .byWordWrapping
        headlineLabel.accessibilityTraits.insert(.header)
        updateHeadlineLabelFont()

        if stepDescription.subtext != nil {
            subtextLabel = UILabel()
            subtextLabelContainer = ContentInsetView(subtextLabel, inset: textPadding)
            subtextLabel.textAlignment = .center
            subtextLabel.text = stepDescription.subtext
            subtextLabel.font = AuthenticationStepController.subtextFont
            subtextLabel.textColor = .gray
            subtextLabel.numberOfLines = 0
            subtextLabel.lineBreakMode = .byWordWrapping
            subtextLabelContainer.isHidden = stepDescription.subtext == nil
        }

        errorLabel = UILabel()
        let errorInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 24 + AccessoryTextField.ConfirmButtonWidth)
        errorLabelContainer = ContentInsetView(errorLabel, inset: errorInsets)
        errorLabel.textAlignment = .left
        errorLabel.numberOfLines = 0
        errorLabel.font = AuthenticationStepController.errorMessageFont
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        updateValidation(initialValidation)

        mainView = createMainView()

        if let secondaryView = stepDescription.secondaryView {
            secondaryViews = secondaryView.views.map { $0.create() }
        }

        secondaryViewsStackView = UIStackView(arrangedSubviews: secondaryViews)
        secondaryViewsStackView.distribution = .equalCentering
        secondaryViewsStackView.spacing = 24
        secondaryViewsStackView.translatesAutoresizingMaskIntoConstraints = false

        let subviews = [headlineLabelContainer, subtextLabelContainer, mainView, errorLabelContainer, secondaryViewsStackView].compactMap { $0 }

        contentStack = CustomSpacingStackView(customSpacedArrangedSubviews: subviews)
        contentStack.axis = .vertical
        contentStack.distribution = .fill
        contentStack.alignment = .fill

        view.addSubview(contentStack)
    }

    private func updateHeadlineLabelFont() {
        headlineLabel.font = self.view.frame.size.width > 320 ? AuthenticationStepController.headlineFont : AuthenticationStepController.headlineSmallFont
    }

    func setSecondaryViewHidden(_ isHidden: Bool) {
        secondaryViewsStackView.isHidden = isHidden
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

    private func createConstraints() {
        contentStack.translatesAutoresizingMaskIntoConstraints = false

        // Arrangement
        headlineLabel.setContentCompressionResistancePriority(UILayoutPriority.required, for: .vertical)
        errorLabel.setContentCompressionResistancePriority(UILayoutPriority.required, for: .vertical)
        mainView.setContentCompressionResistancePriority(UILayoutPriority.required, for: .vertical)
        mainView.setContentHuggingPriority(.defaultLow, for: .horizontal)

        // Spacing
        if stepDescription.subtext != nil {
            subtextLabel.setContentCompressionResistancePriority(UILayoutPriority.required, for: .vertical)
            subtextLabel.widthAnchor.constraint(equalTo: contentStack.widthAnchor, constant: -64).isActive = true
            contentStack.wr_addCustomSpacing(16, after: headlineLabelContainer)
            contentStack.wr_addCustomSpacing(44, after: subtextLabelContainer)
        } else {
            contentStack.wr_addCustomSpacing(44, after: headlineLabelContainer)
        }

        contentStack.wr_addCustomSpacing(16, after: mainView)
        contentStack.wr_addCustomSpacing(16, after: errorLabelContainer)

        // Fixed Constraints
        contentCenter = contentCenterXAnchor.constraint(equalTo: view.centerYAnchor)

        NSLayoutConstraint.activate([
            // contentStack
            contentStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            contentCenter,

            // labels
            headlineLabel.widthAnchor.constraint(equalTo: contentStack.widthAnchor, constant: -64),

            // height
            mainView.heightAnchor.constraint(greaterThanOrEqualToConstant: AuthenticationStepController.mainViewHeight),
            secondaryViewsStackView.heightAnchor.constraint(greaterThanOrEqualToConstant: 13),
            errorLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 19)
        ])

        // Adaptive Constraints
        mainViewWidthRegular = mainView.widthAnchor.constraint(equalToConstant: 375)
        mainViewWidthCompact = mainView.widthAnchor.constraint(equalTo: view.widthAnchor)

        updateConstraints(forRegularLayout: traitCollection.horizontalSizeClass == .regular)
    }

    // MARK: - Customization

    func setRightItem(_ title: String, withAction action: AuthenticationCoordinatorAction, accessibilityID: String) {
        let button = UIBarButtonItem(title: title.localizedUppercase, style: .plain, target: self, action: #selector(rightItemTapped))
        button.accessibilityIdentifier = accessibilityID
        rightItemAction = action
        navigationItem.rightBarButtonItem = button
    }

    @objc private func rightItemTapped() {
        guard let rightItemAction = self.rightItemAction else {
            return
        }

        authenticationCoordinator?.executeAction(rightItemAction)
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

extension AuthenticationStepController {
    
    // MARK: - AuthenticationCoordinatedViewController
    
    func displayError(_ error: Error) {
        //no-op
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
        authenticationCoordinator?.handleUserInput(value)
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
            errorLabel.textColor = UIColor.Team.placeholderColor
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

extension AuthenticationStepController {
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
