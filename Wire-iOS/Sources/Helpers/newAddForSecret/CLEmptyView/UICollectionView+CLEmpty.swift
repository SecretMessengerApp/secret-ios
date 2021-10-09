//
//  UICollectionView+CLEmpty.swift
//  CLEmptyViewDemo
//


import UIKit

//MARK:
extension UICollectionView {

    ///emptyView
    public func normalEmptyView(){
        config.clEmptyView.addEmptyImage(imageNmae: "secret-launch")
            .addEmptyTis(tips: NSAttributedString(string: "Emptyset.noBillDesciption".localized))
            .addLoadingImage(imageNames: ["loading_imgBlue_78x78"])
            .addLoadingDuration(duration: 0.5) 
            .endConfig()
        
        addToSuperView()
    }

    private func addToSuperView() {
        self.backgroundView = config.clEmptyView
        config.clEmptyView.delegate = self
    }
}


