//
//  QRCodeScanResultHandle.swift
//  Wire-iOS
//

import Foundation

struct QRCodeResolver {

    var model: QRCodeModel

    init(string: String) {
        self.model = QRCodeModel(string: string)
    }
}
