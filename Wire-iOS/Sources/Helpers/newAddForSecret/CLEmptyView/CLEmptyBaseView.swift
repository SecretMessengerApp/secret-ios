//
//  CLEmptyBaseView.swift
//  CLEmptyViewDemo
//


import UIKit
import Cartography

public protocol CLEmptyBaseViewDelegate:NSObjectProtocol {
    func clickEmptyView()
}

public class CLEmptyBaseView: UIView {
    
    fileprivate let rotationAnimKey = "rotationAnimKey"

    fileprivate let contentView:UIView = UIView()
    /// loading view
    fileprivate let loadingView:UIView = UIView()
    
    fileprivate var loadingTitleLabel:UILabel?
    fileprivate var emptyImage:UIButton?
    fileprivate var titleLabel:UILabel?
    fileprivate var detailTitleLabel:UILabel?

    fileprivate var loadingImage:UIImageView?

    fileprivate var isGroupAnimation:Bool = false
    fileprivate var emptyTips:NSAttributedString?
    fileprivate var emptyImageName:String = ""
    fileprivate var loadingImageName:[String] = []
    fileprivate var loadingTips:NSAttributedString?
    fileprivate var loadingDuration:Double = 1.0
    fileprivate var detailTips:NSAttributedString?
    

    weak public var delegate:CLEmptyBaseViewDelegate?
    
    public func setEmptyImage(imageName:String?,tips:NSAttributedString?) {
        emptyImage?.setImage(UIImage(named: imageName ?? emptyImageName), for: .normal)
        titleLabel?.attributedText = tips
    }
    

    ///
    /// - Parameters:
    ///   - imageName:
    ///   - title: title
    ///   - text:
    ///   - firstBtn:
    ///   - secondBtn:
    open func setUpEmpty(imageName: String?,
                         title: NSAttributedString?,
                         text: NSAttributedString?) {
        config(imageName: imageName,
               title: title,
               detailTitle: text)
    }
    
    

    /// - Parameters:
    ///   - imageName:
    ///   - titleAttr:
    ///   - duration:
    open func setUpEmptyLoading(imageNames:[String],
                                titleAttr:NSAttributedString?,
                                duration:Double = 1.0){
//        loadingView.frame = self.bounds
        loadingView.isHidden = true
        addSubview(loadingView)
        loadingView.secret.pin(ignoreSafeArea: true)
        
        loadingImage = UIImageView(image: UIImage(named: imageNames.first ?? ""))
        loadingImage?.contentMode = .center
        if imageNames.count > Int(1) {
            isGroupAnimation = true
            loadingImage?.animationImages = imageNames.compactMap{UIImage(named: $0)}
        }else{
            isGroupAnimation = false
        }
        loadingView.addSubview(loadingImage!)
        
        loadingTitleLabel = UILabel()
        loadingTitleLabel?.textAlignment = .center
        loadingTitleLabel?.attributedText = titleAttr
        loadingTitleLabel?.translatesAutoresizingMaskIntoConstraints = false
        loadingView.addSubview(loadingTitleLabel!)
        
        configLoadingViewConstraint()
    }
    
    func setContentFrame(with frame: CGRect) {
        self.contentView.frame = frame
        self.loadingView.frame = frame
    }
    
}
//MARK:
public extension CLEmptyBaseView {
    
    func addEmptyImage(imageNmae:String) -> CLEmptyBaseView {
        emptyImageName = imageNmae
        return self
    }
    func addEmptyTis(tips:NSAttributedString) -> CLEmptyBaseView {
        emptyTips = tips
        return self
    }
    func addEmptyDetailTips(tips:NSAttributedString) -> CLEmptyBaseView {
        detailTips = tips
        return self
    }
    func addLoadingImage(imageNames:[String]) -> CLEmptyBaseView {
        loadingImageName = imageNames
        return self
    }
    func addLoadingTips(tips:NSAttributedString) -> CLEmptyBaseView {
        loadingTips = tips
        return self
    }
    func addLoadingDuration(duration:Double) -> CLEmptyBaseView {
        loadingDuration = duration
        return self
    }

    func endConfig(){
        setUpEmpty(imageName: emptyImageName, title: emptyTips, text: detailTips)
        setUpEmptyLoading(imageNames: loadingImageName, titleAttr: loadingTips, duration: loadingDuration)
    }
}

//MARK:emptyView
extension CLEmptyBaseView {
    
    fileprivate func config(imageName: String?,
                            title: NSAttributedString?,
                            detailTitle: NSAttributedString?){
        
//        contentView.frame = self.bounds
        contentView.isHidden = true
        addSubview(contentView)
        
        contentView.accessibilityIdentifier = "empty_container"
        contentView.secret.pin()
        
        if let imageName = imageName {
            emptyImage = UIButton()
            guard let emptyImage = emptyImage else {return}
            emptyImage.setImage(UIImage(named:imageName), for: .normal)
            emptyImage.addTarget(self, action: #selector(self.clickEmptyView), for: .touchUpInside)
            
            emptyImage.sizeToFit()
            emptyImage.imageView?.contentMode = .scaleAspectFit
            contentView.addSubview(emptyImage)
            emptyImage.translatesAutoresizingMaskIntoConstraints = false
            constrain(contentView,emptyImage, block: { (contentview,emptyimage) in
                emptyimage.centerX == contentview.centerX
                emptyimage.centerY == contentview.centerY - 50
                emptyimage.width == 100 ///282x272
                emptyimage.height == 100*(272/282.0)
            })
        }
        
        if let title = title {
            titleLabel = UILabel()
            titleLabel?.textColor = UIColor.dynamic(scheme: .subtitle)
            guard let titleLabel = titleLabel else {return}
            titleLabel.attributedText = title
            titleLabel.textAlignment = .center
            titleLabel.numberOfLines = 0
            titleLabel.sizeToFit()
            contentView.addSubview(titleLabel)
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            let lay1 = NSLayoutConstraint(item: titleLabel, attribute: .centerX, relatedBy: .equal, toItem: contentView, attribute: .centerX, multiplier: 1, constant: 0)
            let lay3 = NSLayoutConstraint(item: titleLabel, attribute: .top, relatedBy: .equal, toItem: emptyImage, attribute: .bottom, multiplier: 1, constant: 15)
            let lay2 = NSLayoutConstraint(item: titleLabel, attribute: .width, relatedBy: .equal, toItem: contentView, attribute: .width, multiplier: 0.8, constant: 0)
            contentView.addConstraints([lay1,lay2,lay3])
        }
        
        if let detailTitle = detailTitle {
            detailTitleLabel = UILabel()
            detailTitleLabel?.textColor = UIColor.dynamic(scheme: .subtitle)
            detailTitleLabel?.numberOfLines = 0
            guard let detailTitleLabel = detailTitleLabel else {return}
            detailTitleLabel.attributedText = detailTitle
            detailTitleLabel.textAlignment = .center
            detailTitleLabel.sizeToFit()
            contentView.addSubview(detailTitleLabel)
            detailTitleLabel.translatesAutoresizingMaskIntoConstraints = false
            let lay1 = NSLayoutConstraint(item: detailTitleLabel, attribute: .centerX, relatedBy: .equal, toItem: contentView, attribute: .centerX, multiplier: 1, constant: 0)
            let lay3 = NSLayoutConstraint(item: detailTitleLabel, attribute: .top, relatedBy: .equal, toItem: titleLabel ?? emptyImage, attribute: .bottom, multiplier: 1, constant: 15)
            let lay2 = NSLayoutConstraint(item: detailTitleLabel, attribute: .width, relatedBy: .equal, toItem: contentView, attribute: .width, multiplier: 0.8, constant: 0)
            contentView.addConstraints([lay1,lay2,lay3])
        }
    }
    
    @objc fileprivate func clickEmptyView(){
        delegate?.clickEmptyView()
    }
}

//MARK:LoadingView
extension CLEmptyBaseView {
    
    fileprivate func configLoadingViewConstraint(){
        loadingImage?.translatesAutoresizingMaskIntoConstraints = false
        /// loadingImage
        let loadingCenterX = NSLayoutConstraint(item: loadingImage!, attribute: .centerX, relatedBy: .equal, toItem: loadingView, attribute: .centerX, multiplier: 1, constant: 0)
        let loadingCenterY = NSLayoutConstraint(item: loadingImage!, attribute: .bottom, relatedBy: .equal, toItem: loadingView, attribute: .centerY, multiplier: 1, constant: -50)
        var loadingW:NSLayoutConstraint = NSLayoutConstraint()
        var loadingH:NSLayoutConstraint = NSLayoutConstraint()
        if loadingImage!.bounds.width > (loadingView.bounds.width * 0.5) {
            loadingW = NSLayoutConstraint(item: loadingImage!, attribute: .width, relatedBy: .equal, toItem: loadingView, attribute: .width, multiplier: 0.5, constant: 0)
            loadingH = NSLayoutConstraint(item: loadingImage!, attribute: .height, relatedBy: .equal, toItem: loadingView, attribute: .width, multiplier: 0.5, constant: 0)
        }
        
        loadingTitleLabel?.translatesAutoresizingMaskIntoConstraints = false
        let titleLabelCenterX = NSLayoutConstraint(item: loadingTitleLabel!, attribute: .centerX, relatedBy: .equal, toItem: loadingView, attribute: .centerX, multiplier: 1, constant: 0)
        let titleLabelCenterY = NSLayoutConstraint(item: loadingTitleLabel!, attribute: .top, relatedBy: .equal, toItem: loadingImage, attribute: .bottom, multiplier: 1, constant: 20)
        let titleLabelW = NSLayoutConstraint(item: loadingTitleLabel!, attribute: .width, relatedBy: .equal, toItem: loadingImage, attribute: .width, multiplier: 1, constant: 0)
        loadingView.addConstraints([loadingCenterX,loadingCenterY,loadingW,loadingH,titleLabelCenterX,titleLabelCenterY,titleLabelW])
    }
    
}

//MARK: Loading
extension CLEmptyBaseView {

    public func showLoading() {

        hideEmpty()
        
        loadingView.isHidden = false
        startLoadingAnmation()
    }
    

    public func hideLoading() {
        stopLoadingAnmation()
        loadingView.isHidden = true
    }
    

    public func showEmpty() {
        hideLoading()
        contentView.isHidden = false
    }


    public func hideEmpty() {
        contentView.isHidden = true
    }
    
}

//MARK: Loading
extension CLEmptyBaseView {
    
  
    fileprivate func startLoadingAnmation() {
        guard let imageView = loadingImage else {return}
        if isGroupAnimation {
            self.setUpGroupAnimation(imageView: imageView)
        }else{
            self.setUpRotationAnimation(imageView: imageView)
        }
    }

    fileprivate func stopLoadingAnmation() {
        guard let imageView = loadingImage else {return}
        if isGroupAnimation {
            imageView.stopAnimating()
        }else{
            imageView.layer.speed = 0.0
        }
    }
    

    private func setUpRotationAnimation(imageView:UIImageView){
        let anim = CABasicAnimation(keyPath: "transform.rotation")
        anim.fromValue = 0.0
        anim.toValue = Double.pi * 2.0
        anim.duration = self.loadingDuration
        anim.repeatCount = MAXFLOAT
        anim.isRemovedOnCompletion = false
        imageView.layer.add(anim, forKey: rotationAnimKey)
        imageView.layer.speed = 1.0
    }
    
    private func setUpGroupAnimation(imageView:UIImageView){
        imageView.animationDuration = self.loadingDuration
        imageView.startAnimating()
    }

}

