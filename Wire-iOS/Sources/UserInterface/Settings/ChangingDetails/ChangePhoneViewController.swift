
import UIKit
import WireUtilities

struct ChangePhoneNumberState {
    let currentNumber: PhoneNumber?
    var updatedNumber: PhoneNumber?
    var validationError: TextFieldValidator.ValidationError? = .tooShort(kind: .phoneNumber)

    var selectedCountry: Country {
        didSet {
            let newCode = selectedCountry.e164

            if let visible = visibleNumber {
                if visible.countryCode != newCode {
                    updatedNumber = PhoneNumber(countryCode: newCode, numberWithoutCode: visible.numberWithoutCode)
                }
            } else {
                updatedNumber = PhoneNumber(countryCode: newCode, numberWithoutCode: "")
            }
        }
    }

    var visibleNumber: PhoneNumber? {
        return updatedNumber ?? currentNumber
    }
    
    var isValid: Bool {
        guard let phoneNumber = visibleNumber else { return false }
        switch validationError {
        case .none:
            // No current number -> it's a valid change
            guard let current = currentNumber else { return true }
            return phoneNumber != current
        default:
            return false
        }
    }
    
    init(currentPhoneNumber: String? = ZMUser.selfUser().phoneNumber) {
        self.currentNumber = currentPhoneNumber.flatMap(PhoneNumber.init(fullNumber:))
        self.selectedCountry = currentNumber?.country ?? .defaultCountry
    }
    
}

fileprivate enum Section: Int {
    static var count: Int {
        return 2
    }
    
    case phoneNumber = 0
    case remove = 1
}

final class ChangePhoneViewController: SettingsBaseTableViewController {
    var state = ChangePhoneNumberState()
    fileprivate let userProfile = ZMUserSession.shared()?.userProfile
    fileprivate var observerToken: Any?
    
    init() {
        super.init(style: .grouped)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        observerToken = userProfile?.add(observer: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        observerToken = nil
    }
    
    fileprivate func setupViews() {
        PhoneNumberInputCell.register(in: tableView)
        SettingsButtonCell.register(in: tableView)
        title = "self.settings.account_section.phone_number.change.title".localized(uppercased: true)
        
        view.backgroundColor = .clear
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "self.settings.account_section.phone_number.change.save".localized(uppercased: true),
            style: .done,
            target: self,
            action: #selector(saveButtonTapped)
        )
    }
    
    fileprivate func updateSaveButtonState(enabled: Bool? = nil) {
        if let enabled = enabled {
            navigationItem.rightBarButtonItem?.isEnabled = enabled
        } else {
            navigationItem.rightBarButtonItem?.isEnabled = state.isValid
        }
    }
    
    @objc func saveButtonTapped() {
        if let newNumber = state.updatedNumber?.fullNumber {
            userProfile?.requestPhoneVerificationCode(phoneNumber: newNumber)
            updateSaveButtonState(enabled: false)
            navigationController?.showLoadingView = true
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if ZMUser.selfUser()?.phoneNumber == nil {
            return 1
        } else if let email = ZMUser.selfUser().emailAddress, !email.isEmpty {
            return Section.count
        } else {
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch Section(rawValue: indexPath.section)! {
        case .phoneNumber:
            let cell = tableView.dequeueReusableCell(withIdentifier: PhoneNumberInputCell.zm_reuseIdentifier, for: indexPath) as! PhoneNumberInputCell

            if let current = state.visibleNumber {
                cell.phoneInputView.setPhoneNumber(current)
            } else {
                cell.phoneInputView.selectCountry(state.selectedCountry)
            }

            cell.phoneInputView.delegate = self
            cell.phoneInputView.textColor = .dynamic(scheme: .title)
            cell.phoneInputView.inputBackgroundColor = .clear

            updateSaveButtonState()
            return cell

        case .remove:
            let cell = tableView.dequeueReusableCell(withIdentifier: SettingsButtonCell.zm_reuseIdentifier, for: indexPath) as! SettingsButtonCell
            cell.titleText = "self.settings.account_section.phone_number.change.remove".localized
//            cell.titleColor = .white
            cell.selectionStyle = .default
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch Section(rawValue: indexPath.section)! {
        case .phoneNumber:
            break
        case .remove:
            let alert = UIAlertController(
                title: nil,
                message: nil,
                preferredStyle: .actionSheet
            )
            
            alert.addAction(.init(title: "general.cancel".localized, style: .cancel, handler: nil))
            alert.addAction(.init(title: "self.settings.account_section.phone_number.change.remove.action".localized, style: .destructive) { [weak self] _ in
                guard let `self` = self else { return }
                self.userProfile?.requestPhoneNumberRemoval()
                self.updateSaveButtonState(enabled: false)
                self.navigationController?.showLoadingView = true
                })
            
            if let target = tableView.cellForRow(at: indexPath) {
                alert.popoverPresentationController?.sourceView = target
                alert.popoverPresentationController?.sourceRect = target.bounds
            }
            
            alert.applyTheme()
            present(alert, animated: true, completion: nil)
        }
        tableView.deselectRow(at: indexPath, animated: false)
    }

}

// MARK: - PhoneNumberInputViewDelegate

extension ChangePhoneViewController: PhoneNumberInputViewDelegate {

    func phoneNumberInputView(_ inputView: PhoneNumberInputView, didPickPhoneNumber phoneNumber: PhoneNumber) {
        // no-op: this will never be called because we hide the confirm button
    }

    func phoneNumberInputViewDidRequestCountryPicker(_ inputView: PhoneNumberInputView) {
        let countryCodeController = CountryCodeTableViewController()
        countryCodeController.delegate = self

        let navigationController = countryCodeController.wrapInNavigationController(navigationBarClass: DefaultNavigationBar.self)

        navigationController.modalPresentationStyle = .formSheet

        present(navigationController, animated: true, completion: nil)
    }

    func phoneNumberInputView(_ inputView: PhoneNumberInputView, didValidatePhoneNumber phoneNumber: PhoneNumber, withResult validationError: TextFieldValidator.ValidationError?) {
        state.updatedNumber = phoneNumber
        state.validationError = validationError
        updateSaveButtonState()
    }

}

extension ChangePhoneViewController: CountryCodeTableViewControllerDelegate {
    func countryCodeTableViewController(_ viewController: UIViewController, didSelect country: Country) {
        state.selectedCountry = country
        viewController.dismiss(animated: true, completion: nil)
        tableView.reloadData()
        updateSaveButtonState()
    }
}

extension ChangePhoneViewController: UserProfileUpdateObserver {
    func phoneNumberVerificationCodeRequestDidSucceed() {
        navigationController?.showLoadingView = false
        updateSaveButtonState()
        if let newNumber = state.updatedNumber?.fullNumber {
            let confirmController = ConfirmPhoneViewController(newNumber: newNumber, delegate: self)
            navigationController?.pushViewController(confirmController, animated: true)
        }
    }
    
    func phoneNumberVerificationCodeRequestDidFail(_ error: Error!) {
        navigationController?.showLoadingView = false
        updateSaveButtonState()
        showAlert(for: error)
    }
    
    func emailUpdateDidFail(_ error: Error!) {
        navigationController?.showLoadingView = false
        updateSaveButtonState()
        showAlert(for: error)
    }
    
    func phoneNumberRemovalDidFail(_ error: Error!) {
        navigationController?.showLoadingView = false
        updateSaveButtonState()
        showAlert(for: error)
    }
    
    func didRemovePhoneNumber() {
        navigationController?.showLoadingView = false
        _ = navigationController?.popToPrevious(of: self)
    }
    
}

extension ChangePhoneViewController: ConfirmPhoneDelegate {
    func resendVerificationCode(inController controller: ConfirmPhoneViewController) {
        if let newNumber = state.updatedNumber?.fullNumber {
            userProfile?.requestPhoneVerificationCode(phoneNumber: newNumber)
        }
    }
    
    func didConfirmPhone(inController controller: ConfirmPhoneViewController) {
        self.navigationController?.showLoadingView = false
        _ = navigationController?.popToPrevious(of: self)
    }
}
