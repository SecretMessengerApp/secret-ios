//
//  ScanForContactAddressViewController.swift
//  Wire-iOS
//

import UIKit
import Cartography

class ScanForContactAddressViewController: UIViewController {

    var result: ((String?) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(icon: .photo, target: self, action: #selector(photoBtnClicked))
        
        let scanVC = QRCodeScanViewController { [weak self] result in
            self?.result?(result)
        }
        addChild(scanVC)
        view.addSubview(scanVC.view)
        constrain(scanVC.view, view) { (scan, v) in
            scan.edges == v.edges
        }
        
    }
    
    private func dimissImagePicker(completion: (() -> Void)? = nil) {
        imagePickerHelper.dismissPicker(completion: completion)
    }

    private lazy var imagePickerHelper: YPImagePickerHelper = {
        let picker = YPImagePickerHelper(type: .QRCodeInAblum, completionPick: { [weak self] items, isCancelled in
            if isCancelled { self?.dimissImagePicker()  }
            self?.dimissImagePicker {
                if  let item = items.first,
                    case let .photo(mediaItem) = item,
                    let result = QRCodeImageDecoder(image: mediaItem.image).decode() {
                    self?.result?(result)
                } else {
                    HUD.error("hud.error.no.qrcode".localized)
                }
            }
        })
        return picker
    }()

    @objc private func photoBtnClicked() {
        imagePickerHelper.presentPicker(by: self)
    }
}
