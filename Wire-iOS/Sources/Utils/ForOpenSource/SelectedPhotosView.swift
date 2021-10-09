//
//  SelectedPhotosView.swift
//  Wire-iOS
//

import Foundation

class SelectedPhotosView: UIView {
    
    enum Configure {
        case nine
        case three
        
        var maxCount: Int {
            switch self {
            case .nine:
                return 9
            case .three:
                return 3
            }
        }
        
        var gap: CGFloat {
            switch self {
            case .nine:
                return 6
            case .three:
                return 15
            }
        }
        
        var singleRowCount: Int {
            switch self {
            case .nine:
                return 5
            case .three:
                return 3
            }
        }
        
        var showAddWhenNonePic: Bool {
            switch self {
            case .nine:
                return false
            case .three:
                return true
            }
        }
        
        var canDel: Bool {
            switch self {
            case .nine:
                return false
            case .three:
                return true
            }
        }

        var startY: CGFloat {
            switch self {
            case .nine:
                return 0
            case .three:
                return 10
            }
        }
        

        var needAllViewTapGesture: Bool {
            switch self {
            case .nine:
                return true
            case .three:
                return false
            }
        }
        
    }
    
    public var type: Configure = .nine
    

    public var responseHeight: ((CGFloat) -> Void)?
    public var responseClickAction: (() -> Void)?
    public var responseDelIndex: ((Int) -> Void)?
    
    private var chooseItems: [WRChooseMediaItem] = []
    public func updateView(with items: [WRChooseMediaItem]) {
        self.chooseItems = items
        self.setupViews()
    }
    
    private func setupViews() {
        self.backgroundColor = .dynamic(scheme: .background)
        self.subviews.forEach { $0.removeFromSuperview() }
        
        var isVideo: Bool = false
        var chooseImages: [UIImage] = []
        for item in chooseItems {
            switch item.type {
            case .photo(let p, _):
                chooseImages.append(p)
            case .video(let v):
                chooseImages.append(v.thumbnail)
                isVideo = true
            }
        }
        

        var needAddBtn: Bool = false
        if !isVideo {
            if chooseImages.count < type.maxCount && chooseImages.count != 0 {
                needAddBtn = true
            }
        }
        if type.showAddWhenNonePic && chooseItems.count == 0 {
            needAddBtn = true
        }
        if needAddBtn {
            chooseImages.append(UIImage(named: "pic_add")!)
        }
        
        let gap: CGFloat = type.gap
        let singleWidth: CGFloat = (UIScreen.main.bounds.width - (CGFloat(type.singleRowCount + 1) * type.gap))/CGFloat(type.singleRowCount)
        var height: CGFloat = 0
        for (i, image) in chooseImages.enumerated() {
            let imgV = UIImageView(image: image)
            imgV.contentMode = .scaleAspectFill
            imgV.layer.masksToBounds = true
            self.addSubview(imgV)
            imgV.frame = CGRect.init(
                x: gap + CGFloat(i%type.singleRowCount) * (singleWidth + gap),
                y: (gap + singleWidth) * CGFloat(i/type.singleRowCount) + type.startY,
                width: singleWidth, height: singleWidth)
            
            if i == chooseImages.count - 1 {
                height = imgV.frame.maxY
                self.responseHeight?(height)
        
                if needAddBtn && !type.needAllViewTapGesture {
                    let tap = UITapGestureRecognizer.init(target: self, action: #selector(clickAction))
                    tap.numberOfTapsRequired = 1
                    imgV.isUserInteractionEnabled = true
                    imgV.addGestureRecognizer(tap)
                }
            }
            if isVideo {
                let playIcon = UIImageView(image: UIImage(named: "release_video_play"))
                playIcon.bounds = CGRect.init(x: 0, y: 0, width: 26, height: 26)
                playIcon.center = imgV.center
                imgV.addSubview(playIcon)
            }
            
            if type.canDel {
                if needAddBtn && (i == chooseImages.count-1) {
                    break
                }
                let delBtn = UIButton()
                delBtn.tag = 100 + i
                delBtn.setBackgroundImage(UIImage(named: "action_normal_del"), for: .normal)
                delBtn.layer.masksToBounds = true
                delBtn.layer.cornerRadius = 9
                delBtn.bounds = CGRect(x: 0, y: 0, width: 18, height: 18)
                delBtn.center = CGPoint(x: imgV.frame.maxX - 4.5, y: imgV.frame.minY)
                delBtn.addTarget(self, action: #selector(delAction), for: .touchUpInside)
                self.addSubview(delBtn)
            }
        }
        
        if type.needAllViewTapGesture {
            let tap = UITapGestureRecognizer.init(target: self, action: #selector(clickAction))
            tap.numberOfTapsRequired = 1
            self.addGestureRecognizer(tap)
        }
    }
    
    @objc func delAction(sender: UIButton) {
        let index = sender.tag - 100
        guard self.chooseItems.count > index else { return }
        self.chooseItems.remove(at: index)
        self.responseDelIndex?(index)
        self.updateView(with: self.chooseItems)
    }
    
    @objc func clickAction() {
        self.responseClickAction?()
    }
    
}
