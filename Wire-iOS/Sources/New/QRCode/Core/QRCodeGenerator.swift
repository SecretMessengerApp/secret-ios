//
//  QRCodeGenerator.swift
//  Wire-iOS
//

import Foundation

// MARK: - Convenience Generator
extension QRCodeGenerator {

    static func generate(type: QRCodeModel.ModelType) -> UIImage? {
        let qRCodeString: String
        switch type {
        case .group(let url):
            qRCodeString = "https://g.isecret.im/?url=\(url)"
            
        case let .newFriend(id):
            qRCodeString = "https://u.isecret.im/\(id)"
        case .login, .unknown, .friend, .h5Auth:
            qRCodeString = ""
        }
        
        return QRCodeGenerator(qRCodeString)?.generate()
    }
}

// MARK: - QRCodeGenerator
class QRCodeGenerator {

    convenience init?(_ id: String) {
        guard let data = id.data(using: .isoLatin1) else { return nil }
        self.init(data)
    }

    private let data: Data

    init(_ data: Data) {
        self.data = data
    }

    struct Color {
        let foreground: UIColor
        let background: UIColor
    }

    struct Filter {

        enum FilterType {
            case qr(value: Data, level: CorrectionLevel)
            case color(value: CIImage, color: Color)
        }

        let type: FilterType

        var ciImage: CIImage? {
            switch type {
            case let .qr(value, level):
                let filter = CIFilter(name: "CIQRCodeGenerator")
                filter?.setValue(level.rawValue, forKey: "inputCorrectionLevel")
                filter?.setValue(value, forKey: "inputMessage")
                return filter?.outputImage

            case let .color(value, color):
                let filter = CIFilter(name: "CIFalseColor")
                filter?.setDefaults()
                filter?.setValue(value, forKey: "inputImage")
                filter?.setValue(CIColor(cgColor: color.foreground.cgColor), forKey: "inputColor0")
                filter?.setValue(CIColor(cgColor: color.background.cgColor), forKey: "inputColor1")
                return filter?.outputImage
            }
        }
    }

    /**
     The level of error correction.

     - low:      7%
     - medium:   15%
     - quartile: 25%
     - high:     30%
     */
    enum CorrectionLevel: String {
        case low = "L"
        case medium = "M"
        case quartile = "Q"
        case high = "H"
    }

    func generate(
        correctionLevel level: CorrectionLevel = .quartile,
        size: CGSize = CGSize(width: 200, height: 200),
        color: Color? = nil
        ) -> UIImage? {
        guard let ciImage = Filter(type: .qr(value: data, level: level)).ciImage else { return nil }
        if let color = color, let ciImage = Filter(type: .color(value: ciImage, color: color)).ciImage {
            return image(from: ciImage, scale: scale(origin: size, current: ciImage.extent.size))
        } else {
            return image(from: ciImage, scale: scale(origin: size, current: ciImage.extent.size))
        }
    }
}

private extension QRCodeGenerator {

    func scale(origin: CGSize, current: CGSize) -> Scale {
        return Scale(dx: origin.width / current.width,
                     dy: origin.height / current.height)
    }

    struct Scale {
        let dx: CGFloat
        let dy: CGFloat
    }

    func image(from ciImage: CIImage,
               scale: Scale = Scale(dx: 1, dy: 1)) -> UIImage? {
        guard let cgImage = CIContext(options: nil)
            .createCGImage(ciImage, from: ciImage.extent) else { return nil }
        let size = CGSize(width: ciImage.extent.width * scale.dx,
                          height: ciImage.extent.height * scale.dy)
        UIGraphicsBeginImageContextWithOptions(size, true, 0)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        context.interpolationQuality = .none
        context.translateBy(x: 0, y: size.height)
        context.scaleBy(x: 1.0, y: -1.0)
        context.draw(cgImage, in: context.boundingBoxOfClipPath)
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result
    }
}
