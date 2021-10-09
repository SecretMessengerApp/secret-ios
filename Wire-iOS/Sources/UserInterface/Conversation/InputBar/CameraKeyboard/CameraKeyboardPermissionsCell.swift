

import Foundation
import Cartography
import UIKit

public enum DeniedAuthorizationType {
    case camera
    case photos
    case cameraAndPhotos
    case ongoingCall
}

open class CameraKeyboardPermissionsCell: UICollectionViewCell {

    let settingsButton = Button()
    let cameraIcon = IconButton()
    let descriptionLabel = UILabel()
    
    private let containerView = UIView()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .graphite
        
        cameraIcon.setIcon(.cameraLens, size: .tiny, for: .normal)
        cameraIcon.setIconColor(.white, for: .normal)
        cameraIcon.isUserInteractionEnabled = false
        
        descriptionLabel.backgroundColor = .clear
        descriptionLabel.textColor = .white
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textAlignment = .center
        
        settingsButton.setTitleColor(.white, for: .normal)
        settingsButton.titleLabel?.font = UIFont(16, .semibold)
        settingsButton.setTitle("keyboard_photos_access.denied.keyboard.settings".localized, for: .normal)
        settingsButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 30, bottom: 10, right: 30)
        settingsButton.layer.cornerRadius = 4.0
        settingsButton.layer.masksToBounds = true
        settingsButton.addTarget(self, action: #selector(CameraKeyboardPermissionsCell.openSettings), for: .touchUpInside)
        settingsButton.setBackgroundImageColor(UIColor.white.withAlphaComponent(0.16), for: .normal)
        settingsButton.setBackgroundImageColor(UIColor.white.withAlphaComponent(0.24), for: .highlighted)
        containerView.backgroundColor = .clear
        
        containerView.addSubview(descriptionLabel)
        
        addSubview(containerView)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public convenience init(frame: CGRect, deniedAuthorization: DeniedAuthorizationType) {
        self.init(frame: frame)
        configure(deniedAuthorization: deniedAuthorization)
    }
    
    func configure(deniedAuthorization: DeniedAuthorizationType) {
        var title = ""
        
        switch deniedAuthorization {
        case .camera:           title = "keyboard_photos_access.denied.keyboard.camera"
        case .photos:           title = "keyboard_photos_access.denied.keyboard.photos"
        case .cameraAndPhotos:  title = "keyboard_photos_access.denied.keyboard.camera_and_photos"
        case .ongoingCall:      title = "keyboard_photos_access.denied.keyboard.ongoing_call"
        }
        
        descriptionLabel.font = UIFont((deniedAuthorization == .ongoingCall ? 14.0 : 16.0), .light)
        descriptionLabel.text = title.localized
        
        createConstraints(deniedAuthorization: deniedAuthorization)
    }
    
    @objc private func openSettings() {
        guard let url = URL(string:UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(url) else { return }
        UIApplication.shared.open(url)
    }
    
    private func createConstraints(deniedAuthorization: DeniedAuthorizationType) {
        
        constrain(self, containerView, descriptionLabel, settingsButton, cameraIcon) { (selfView, container, description, settings, cameraIcon) in
            description.leading == container.leading + 16
            description.trailing == container.trailing - 16
            container.centerY == selfView.centerY
            container.leading == selfView.leading
            container.trailing == selfView.trailing
        }
        
        if deniedAuthorization == .ongoingCall {
            createConstraintsForOngoingCallAlert()
        } else {
            createConstraintsForPermissionsAlert()
        }
    }
    
    private func createConstraintsForPermissionsAlert() {
        
        if cameraIcon.superview != nil {
            cameraIcon.removeFromSuperview()
        }
        containerView.addSubview(settingsButton)
        
        constrain(self, containerView, descriptionLabel, settingsButton) { (selfView, container, description, settings) in
            settings.bottom == container.bottom
            settings.top == description.bottom + 24
            settings.height == 44.0
            settings.centerX == container.centerX
            description.top == container.top
        }
    }
    
    private func createConstraintsForOngoingCallAlert() {
        
        if settingsButton.superview != nil {
            settingsButton.removeFromSuperview()
        }
        containerView.addSubview(cameraIcon)
        
        constrain(self, containerView, descriptionLabel, cameraIcon) { (selfView, container, description, cameraIcon) in
            description.bottom == container.bottom
            description.top == cameraIcon.bottom + 16
            cameraIcon.top == container.top
            cameraIcon.centerX == container.centerX
        }
    }

}
