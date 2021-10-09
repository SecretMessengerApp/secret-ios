

import Foundation

extension Float {
    func clamp(_ lower: Float, upper: Float) -> Float {
        return max(lower, min(upper, self))
    }
}

extension CGFloat {
    func clamp(_ lower: CGFloat, upper: CGFloat) -> CGFloat {
        return fmax(lower, fmin(upper, self))
    }
}

// MARK: Decibel Normalization

extension Float {
    
    /**
      Calculates a nomrlaized value between 0 and 1 
      when called on  a `decibel` value, see:
      http://stackoverflow.com/questions/31598410/how-can-i-normalized-decibel-value-and-make-it-between-0-and-1
      Value is bumped 4x to match the usual voice loudness level (0-160 dB is from absolute silence to military jet aircraft take-off)
     - returns: Normalized loudness value between 0 and 1
     */
    func normalizedDecibelValue() -> Float {
        return (pow(10, self / 20) * 4.0).clamp(0, upper: 1)
    }
}
