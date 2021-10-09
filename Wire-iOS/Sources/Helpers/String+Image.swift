
import Foundation

extension String {
    
    func image(renderedWithAttributes attributes: [NSAttributedString.Key : Any]) -> UIImage? {
        let attributedString = NSAttributedString(string: self, attributes: attributes)
        let size = attributedString.size()
        let rect = CGRect(origin: CGPoint.zero, size: size)
        UIGraphicsBeginImageContextWithOptions(size, false, 0);
        attributedString.draw(in: rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
}
