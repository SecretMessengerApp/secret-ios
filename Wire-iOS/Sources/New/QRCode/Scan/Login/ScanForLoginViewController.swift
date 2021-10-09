//
//  ScanDesktopLoginViewController.swift
//  Wire-iOS
//

import UIKit
import Cartography

class ScanForLoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "self.settings.account_section.scan.title".localized
        let scanVC = QRCodeScanViewController { [weak self] result in
            guard let self = self, let result = result else { return }
            let resolver = QRCodeResolver(string: result)
            if case .login(let value) = resolver.model.type {
                self.login(qr: value)
            } else {
                self.navigationController?.popViewController(animated: true) {
                    HUD.text("hud.failed.setting.scan.login".localized)
                }
            }
        }
        addChild(scanVC)
        view.addSubview(scanVC.view)
        labelContainer.backgroundColor = .clear
        labelContainer.addSubview(descriptionLabel)
        view.addSubview(labelContainer)

        constrain(descriptionLabel, labelContainer) { (label, container) in
            label.edges == inset(container.edges, 20, 10)
        }
        constrain(labelContainer, view) { (label, view) in
            label.left == view.left
            label.right == view.right
            label.top == view.top
            label.height == 80
        }
        constrain(scanVC.view, view, labelContainer) { (sview, view, container) in
            sview.left == view.left
            sview.right == view.right
            sview.bottom == view.bottom
            sview.top == container.top
        }
    }

    private func login(qr: String) {
        HUD.loading()
        ScanForLoginService.login(qrString: qr) { [weak self] result in
            HUD.hide()
            guard let self = self else { return }
            self.navigationController?.popViewController(animated: true)
            switch result {
            case .success:
                HUD.text("hud.success.setting.scan.login".localized)
            case .failure:
                HUD.text("hud.failed.setting.scan.login".localized)
            }
        }
    }

    let labelContainer = UIView()
    lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.textColor = .dynamic(scheme: .title)
        label.text = "controller.scan.desktop.login".localized
        label.font = UIFont(name: "PingFangSC-Medium", size: 16)
        return label
    }()
}
