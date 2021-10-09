//
//  NSString+Size.swift
//  Wire-iOS
//


import Foundation


extension String {
    func cl_widthForComment(font: UIFont, height: CGFloat = 20) -> CGFloat {
        let rect = NSString(string: self).boundingRect(with:
                    CGSize(width: CGFloat(MAXFLOAT), height: height),
            options: .usesLineFragmentOrigin,
            attributes: [NSAttributedString.Key.font: font], context: nil)
        return ceil(rect.width)
    }
    
    func cl_widthForComment(fontSize: CGFloat, height: CGFloat = 15) -> CGFloat {
        let font = UIFont.systemFont(ofSize: fontSize)
        let rect = NSString(string: self).boundingRect(with:
                    CGSize(width: CGFloat(MAXFLOAT), height: height),
                    options: .usesLineFragmentOrigin,
                    attributes: [NSAttributedString.Key.font: font], context: nil)
        return ceil(rect.width)
    }
    
    func cl_heightForComment(fontSize: CGFloat, width: CGFloat) -> CGFloat {
        let font = UIFont.systemFont(ofSize: fontSize)
        let rect = NSString(string: self).boundingRect(with:
                    CGSize(width: width, height: CGFloat(MAXFLOAT)),
                    options: [.usesFontLeading, .usesLineFragmentOrigin],
                    attributes: [NSAttributedString.Key.font: font], context: nil)
        return ceil(rect.height)
    }
    
    func cl_heightForComment(fontSize: CGFloat, width: CGFloat, maxHeight: CGFloat) -> CGFloat {
        let font = UIFont.systemFont(ofSize: fontSize)
        let rect = NSString(string: self).boundingRect(with:
            CGSize(width: width, height: CGFloat(MAXFLOAT)),
            options: .usesLineFragmentOrigin,
            attributes: [NSAttributedString.Key.font: font], context: nil)
        return ceil(rect.height)>maxHeight ? maxHeight : ceil(rect.height)
    }
    
}

extension NSAttributedString {

    func cl_heightForComment(width: CGFloat, maxHeight: CGFloat) -> CGFloat {
        let rect = self.boundingRect(with:
            CGSize(width: width, height: CGFloat(MAXFLOAT)),
                                                       options: .usesLineFragmentOrigin,
                                                       context: nil)
        return ceil(rect.height)>maxHeight ? maxHeight : ceil(rect.height)
    }

}
