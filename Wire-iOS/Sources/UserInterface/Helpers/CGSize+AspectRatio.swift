
import CoreGraphics

enum AspectRatio {
    case portrait
    case landscape
    case square
}

extension UIDeviceOrientation {
    var aspectRatio: AspectRatio {
        return isLandscape ? .landscape : .portrait
    }
}

extension CGSize {

    var aspectRatio: AspectRatio {
        if width < height {
            return .portrait
        } else if width > height {
            return .landscape
        } else {
            return .square
        }
    }
    
    var isLandscape: Bool {
        return aspectRatio == .landscape
    }
    
    var isPortrait: Bool {
        return aspectRatio == .portrait
    }
    
    var isSquare: Bool {
        return aspectRatio == .square
    }
    
    func flipped() -> CGSize {
        return CGSize(width: height, height: width)
    }
    
    func withOrientation(_ orientation: UIDeviceOrientation) -> CGSize {
        guard orientation.aspectRatio != aspectRatio else { return self }
        return flipped()
    }

}
