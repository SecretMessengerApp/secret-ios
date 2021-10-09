//
//  QRCodeImageDecoder.swift
//  Wire-iOS
//

import UIKit

struct QRCodeImageDecoder {
    
    private let image: UIImage
    
    init(image: UIImage) {
        self.image = image
    }
    
    func decode() -> String? {
        let detector = CIDetector(ofType: CIDetectorTypeQRCode,
                                  context: nil,
                                  options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])
        guard
            let cgImage = image.cgImage,
            let features = detector?.features(in: CIImage(cgImage: cgImage)),
            !features.isEmpty
            else { return nil }
        
        for feature in features where feature is CIQRCodeFeature {
            return (feature as! CIQRCodeFeature).messageString
        }
        return nil
    }
}

