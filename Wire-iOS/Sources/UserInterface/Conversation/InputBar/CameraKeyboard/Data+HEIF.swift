
import Foundation

extension Data {
    func convertHEIFToJPG() -> Data? {
        guard let inputImage = CIImage(data: self),
              let colorSpace = inputImage.colorSpace else { return nil }

        let context = CIContext(options: nil)
        return context.jpegRepresentation(of: inputImage, colorSpace: colorSpace, options: [:])
    }
}
