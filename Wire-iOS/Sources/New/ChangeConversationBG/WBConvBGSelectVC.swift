//
//  WBConvBGSelectVC.swift
//  ChooseBG
//

import UIKit
import Cartography

class WBConvBGSelectVC: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    private let contentStyles = [
        ("conversation_bg_0", "conversation_circle_0"),
//        ("conversation_bg_1", "conversation_circle_1"),
        ("conversation_bg_2", "conversation_circle_2"),
        ("conversation_bg_3", "conversation_circle_3"),
        ("conversation_bg_4", "conversation_circle_4")
    ]
    private var conversionId: String?

    private let mPickerView = UIPickerView()
    private let mCancelButton = UIButton(type: .custom)
    private let mSureButton = UIButton(type: .custom)
    private let mBodyLabel = UILabel()
    private let mBGImageView = UIImageView()

    public init(conversionId: String?) {
        super.init(nibName: nil, bundle: nil)
        self.conversionId = conversionId
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 8
        mBodyLabel.attributedText = NSAttributedString(
            string: "conversation.setting.backgroundimage.description".localized,
            attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle])

        self.title = "conversation.setting.backgroundimage.title".localized

        // Do any additional setup after loading the view.
    }

    func setupViews() {
        self.view.backgroundColor = UIColor.white
        mBGImageView.image = UIImage(named: "conversation_bg_0")
        mBGImageView.contentMode = .scaleAspectFill
        self.view.addSubview(mBGImageView)
        constrain(self.view, self.mBGImageView) { contentView, bodyView in
            bodyView.edges == contentView.edges
        }

        self.view.addSubview(mBodyLabel)
        mBodyLabel.numberOfLines = 0
        mBodyLabel.font = UIFont(17, .regular)
        mBodyLabel.textColor = UIColor(red: 79/255, green: 95/255, blue: 103/255, alpha: 1)
        constrain(self.view, self.mBodyLabel) { contentView, bodyView in
            bodyView.leading == contentView.leading + 39
            bodyView.top == contentView.top + 100
            bodyView.centerX == contentView.centerX
        }

        mPickerView.delegate = self
        self.view.addSubview(mPickerView)
        mPickerView.setValue(UIColor.clear, forKey: "magnifierLineColor")
        constrain(self.view, self.mPickerView) { contentView, bodyView in
            bodyView.width == 100
            bodyView.height == contentView.height
            bodyView.centerX == contentView.centerX
            bodyView.centerY == contentView.centerY * 1.53
        }

        mPickerView.transform = CGAffineTransform(rotationAngle: -.pi/2)

        let midImageView = UIImageView(image: UIImage(named: "BigCircle"))
        self.mPickerView.addSubview(midImageView)
        constrain(midImageView, self.mPickerView) { imageView, bodyView in
            imageView.width == 80
            imageView.height == 80
            bodyView.centerX == imageView.centerX
            bodyView.centerY == imageView.centerY
        }

        mCancelButton.backgroundColor = UIColor.init(hex: "#111111")
        mCancelButton.setTitle("conversation.setting.backgroundimage.cancel".localized, for: .normal)
        mCancelButton.addTarget(self, action: #selector(clickCancel), for: .touchUpInside)
        mCancelButton.setTitleColor(UIColor.lightGray, for: .normal)
        mSureButton.backgroundColor = UIColor.init(hex: "#111111")
        mSureButton.setTitle("conversation.setting.backgroundimage.apply".localized, for: .normal)
        mSureButton.addTarget(self, action: #selector(clickSure), for: .touchUpInside)

        let bottomContainView = UIView()
        bottomContainView.backgroundColor = UIColor.init(hex: "#111111")
        self.view.addSubview(bottomContainView)
        
        let stackView = UIStackView(arrangedSubviews: [mCancelButton, mSureButton])
        bottomContainView.addSubview(stackView)
        stackView.distribution = .fillEqually
        
        bottomContainView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            bottomContainView.leftAnchor.constraint(equalTo: view.leftAnchor),
            bottomContainView.rightAnchor.constraint(equalTo: view.rightAnchor),
            bottomContainView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            stackView.leftAnchor.constraint(equalTo: bottomContainView.leftAnchor),
            stackView.rightAnchor.constraint(equalTo: bottomContainView.rightAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomContainView.safeBottomAnchor),
            stackView.topAnchor.constraint(equalTo: bottomContainView.topAnchor),
            stackView.heightAnchor.constraint(equalToConstant: 56)
        ])

        let leftGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeGesture(gesture:)))
        leftGesture.direction = .left
        let rightGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeGesture(gesture:)))
        rightGesture.direction = .right
        self.view.addGestureRecognizer(leftGesture)
        self.view.addGestureRecognizer(rightGesture)
    }

    @objc func swipeGesture(gesture: UISwipeGestureRecognizer) {
        let row = mPickerView.selectedRow(inComponent: 0)
        switch gesture.direction {
        case .right:
            mPickerView.selectRow(max(row - 1, 0), inComponent: 0, animated: true)
            pickerView(mPickerView, didSelectRow: max(row - 1, 0), inComponent: 0)
        default:
            mPickerView.selectRow(min(row + 1, contentStyles.count - 1), inComponent: 0, animated: true)
            pickerView(mPickerView, didSelectRow: min(row + 1, contentStyles.count - 1), inComponent: 0)
        }
    }

    @objc func clickCancel() {

        navigationController?.popViewController(animated: true)
    }

    @objc func clickSure() {
        navigationController?.popViewController(animated: true)

        guard let conversationId = self.conversionId else { return }
        let row = mPickerView.selectedRow(inComponent: 0)
        let style = contentStyles[row]
        WBConvnBGImageStorager.sharedInstance.addImageName(conversationId: conversationId, imageName: style.0)

    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return contentStyles.count
    }

    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {

        let style = contentStyles[row]
        var myImageView = UIImageView()
        myImageView = UIImageView(image: UIImage(named: style.1))

        return myImageView
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let style = contentStyles[row]
        mBGImageView.image = UIImage(named: style.0)
    }

    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 80
    }

}
