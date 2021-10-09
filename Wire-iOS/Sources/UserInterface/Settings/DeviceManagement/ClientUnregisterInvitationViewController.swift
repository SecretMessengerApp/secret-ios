//
// Wire
// Copyright (C) 2016 Wire Swiss GmbH
// 
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
// 
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
// 
// You should have received a copy of the GNU General Public License
// along with this program. If not, see http://www.gnu.org/licenses/.
// 


import UIKit
import Cartography

protocol ClientUnregisterInvitationViewControllerDelegate: class {
    /// Called when the user tapped the button to unregister clients.
    func userDidAcceptClientUnregisterInvitation()
}

class ClientUnregisterInvitationViewController: UIViewController {
    var subtitleLabel : UILabel?
    var manageDevicesButton : UIButton?
    var forgotPasswordButton = ButtonWithLargerHitArea()
    var containerView : UIView?

    weak var delegate: ClientUnregisterInvitationViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.createContainerView()
        self.createSubtitleLabel()
        self.createDeleteDevicesButton()
        self.createForgetPasswordButton()
        self.createConstraints()
        // Layout first to avoid the initial layout animation during the presentation.
        self.view.layoutIfNeeded()
    }
    
    fileprivate func createContainerView() {
        let view = UIView()
        self.containerView = view
        self.view?.addSubview(view)
    }
    
    fileprivate func createSubtitleLabel() {
        let subtitleLabel = UILabel()
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.font = FontSpec(.large, .light).font!
        subtitleLabel.textColor = UIColor.from(scheme: .textForeground, variant: .light)
        subtitleLabel.numberOfLines = 0
        subtitleLabel.text = NSLocalizedString("registration.signin.too_many_devices.subtitle", comment:"")
        
        self.subtitleLabel = subtitleLabel
        self.containerView?.addSubview(subtitleLabel)
    }
    
    fileprivate func createDeleteDevicesButton() {
        let manageDevicesButton = Button(style: .fullMonochrome)
        manageDevicesButton.setTitle(NSLocalizedString("registration.signin.too_many_devices.manage_button.title", comment:""), for: [])
        manageDevicesButton.addTarget(self, action: #selector(ClientUnregisterInvitationViewController.openManageDevices(_:)), for: .touchUpInside)
        manageDevicesButton.setTitleColor(.white, for: .normal)
        manageDevicesButton.layer.cornerRadius = 20
        manageDevicesButton.layer.masksToBounds = true
        manageDevicesButton.setBackgroundImageColor(UIColor.defaultBlue, for: .normal)
        self.manageDevicesButton = manageDevicesButton
        self.containerView?.addSubview(manageDevicesButton)
    }
    
    fileprivate func createForgetPasswordButton() {
        forgotPasswordButton.translatesAutoresizingMaskIntoConstraints = false
        forgotPasswordButton.setTitleColor(UIColor.black999, for: .normal)
        forgotPasswordButton.setTitleColor(UIColor.init(white: 1, alpha: 0.4), for: .highlighted)
        forgotPasswordButton.setTitle("signin.forgot_password".localized.uppercased(), for: .normal)
        forgotPasswordButton.titleLabel?.font = UIFont(11, .regular)
        forgotPasswordButton.addTarget(self, action: #selector(ClientUnregisterInvitationViewController.resetPassword), for: .touchUpInside)
        self.containerView?.addSubview(forgotPasswordButton)
    }
    
    fileprivate func createConstraints() {
        if let containerView = self.containerView,
            let subtitleLabel = self.subtitleLabel,
            let manageDevicesButton = self.manageDevicesButton {
            
            constrain(self.view, containerView) { selfView, containerView in
                containerView.edges == selfView.edges ~ 900
                containerView.width <= 414
                containerView.height <= 736
                containerView.center == selfView.center
            }
            
            constrain(containerView, forgotPasswordButton) { containerView, forgetbutton in
                forgetbutton.bottom == containerView.bottom - 24
                forgetbutton.centerX == containerView.centerX
            }
            
            constrain(containerView, manageDevicesButton, forgotPasswordButton, subtitleLabel) { containerview ,managerbutton, forgetbutton, subtitleLabel in
                forgetbutton.bottom == containerview.bottom - 24
                forgetbutton.centerX == containerview.centerX
                managerbutton.left == containerview.left + 24
                managerbutton.right == containerview.right - 24
                managerbutton.bottom == forgetbutton.top - 24
                managerbutton.height == 40
                subtitleLabel.left == containerview.left + 28
                subtitleLabel.right == containerview.right - 28
                subtitleLabel.bottom == managerbutton.top - 24
            }
        }
    }
    
    // MARK: - Actions
    
    @objc func openManageDevices(_ sender : UIButton!) {
        delegate?.userDidAcceptClientUnregisterInvitation()
    }
    
    @objc func signOut(_ sender : UIButton!) {
        // for the moment not supported
    }
    
    @objc func resetPassword() {
         UIApplication.shared.open(URL.wr_passwordReset)
    }
}
