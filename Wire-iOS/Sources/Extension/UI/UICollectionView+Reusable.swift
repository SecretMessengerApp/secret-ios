//
//  UICollectionView+Reusable.swift
//  Wire-iOS
//


import UIKit.UICollectionView

extension UICollectionView {
    
    func registerNibCell<T: UICollectionViewCell>(_ type: T.Type) {
        register(UINib(nibName: "\(type)", bundle: nil), forCellWithReuseIdentifier: "\(type)")
    }
    
    func registerCell<T: UICollectionViewCell>(_ type: T.Type) {
        register(type, forCellWithReuseIdentifier: "\(type)")
    }
    
    func dequeueCell<T: UICollectionViewCell>(_ type: T.Type, for indexPath: IndexPath) -> T {
        return dequeueReusableCell(withReuseIdentifier: "\(type)", for: indexPath) as! T
    }
    
    func registerSectionHeader<T: UICollectionReusableView>(_ type: T.Type) {
        register(type, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "\(type)")
    }
    
    func registerSectionFooter<T: UICollectionReusableView>(_ type: T.Type) {
        register(type, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "\(type)")
    }
    
    func dequeueSectionHeader<T: UICollectionReusableView>(_ type: T.Type, for indexPath: IndexPath) -> T {
        return dequeueReusableSupplementaryView(
            ofKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "\(type)",
            for: indexPath
            ) as! T
    }
    
    func dequeueSectionFooter<T: UICollectionReusableView>(_ type: T.Type, for indexPath: IndexPath) -> T {
        return dequeueReusableSupplementaryView(
            ofKind: UICollectionView.elementKindSectionFooter,
            withReuseIdentifier: "\(type)",
            for: indexPath)
            as! T
    }
}
