
import Foundation
import UIKit
import Cartography

protocol ColorPickerControllerDelegate {
    func colorPicker(_ colorPicker: ColorPickerController, didSelectColor color: UIColor)
    func colorPickerWantsToDismiss(_ colotPicker: ColorPickerController)
}

class ColorPickerController: UIViewController {
    let overlayView = UIView()
    let contentView = UIView()
    let tableView = UITableView()
    let headerView = UIView()
    let titleLabel = UILabel()
    let closeButton = IconButton()

    static fileprivate let rowHeight: CGFloat = 44
    
    let colors: [UIColor]
    var currentColor: UIColor?
    var delegate: ColorPickerControllerDelegate?
    
    init(colors: [UIColor]) {
        self.colors = colors
        super.init(nibName: nil, bundle: nil)
        
        self.modalPresentationStyle = .custom
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var title: String? {
        didSet {
            self.titleLabel.text = self.title
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(self.contentView)
        
        self.contentView.layer.cornerRadius = 10
        self.contentView.clipsToBounds = true
        self.contentView.backgroundColor = UIColor.dynamic(scheme: .background)
        
        self.closeButton.setIcon(.cross, size: .tiny, for: [])
        self.closeButton.addTarget(self, action: #selector(ColorPickerController.didPressDismiss(_:)), for: .touchUpInside)
        self.closeButton.setIconColor(UIColor.darkGray, for: .normal)
        
        self.titleLabel.font = FontSpec(.small, .light).font!
        
        self.headerView.addSubview(self.titleLabel)
        self.headerView.addSubview(self.closeButton)
        
        self.contentView.addSubview(self.tableView)
        self.contentView.addSubview(self.headerView)
        
        constrain(self.contentView, self.headerView, self.titleLabel, self.closeButton) { contentView, headerView, titleLabel, closeButton in
            headerView.left == contentView.left
            headerView.top == contentView.top
            headerView.right == contentView.right
            headerView.height == 44
            
            titleLabel.center == headerView.center
            titleLabel.left >= headerView.left
            titleLabel.right <= closeButton.left
            
            closeButton.centerY == headerView.centerY
            closeButton.right == headerView.right
            closeButton.height == headerView.height
            closeButton.width == closeButton.height
        }
        
        constrain(self.contentView, self.tableView, self.headerView) { contentView, tableView, headerView in
            tableView.left == contentView.left
            tableView.bottom == contentView.bottom
            tableView.right == contentView.right
            
            tableView.top == headerView.bottom
        }
        
        constrain(self.view, self.contentView, self.headerView) { view, contentView, headerView in
            contentView.center == view.center
            contentView.width == 300
            contentView.height == headerView.height + type(of: self).rowHeight * CGFloat(self.colors.count)
        }
        
        self.tableView.register(PickerCell.self, forCellReuseIdentifier: PickerCell.reuseIdentifier)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorStyle = .none
    }
    
    override var prefersStatusBarHidden: Bool {
        get {
            return false
        }
    }
    
    fileprivate class PickerCell: UITableViewCell {
        fileprivate let checkmarkView = UIImageView()
        fileprivate let colorView = UIView()
    
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            self.selectionStyle = .none
            
            self.contentView.addSubview(self.colorView)
            self.contentView.addSubview(self.checkmarkView)
            
            constrain(self.contentView, self.checkmarkView, self.colorView) { contentView, checkmarkView, colorView in
                colorView.edges == contentView.edges
                checkmarkView.center == contentView.center
            }
            
            self.checkmarkView.setIcon(.checkmark, size: .small, color: UIColor.white)
            self.checkmarkView.isHidden = true
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        var color: UIColor? {
            didSet {
                self.colorView.backgroundColor = color
            }
        }

        override func setSelected(_ selected: Bool, animated: Bool) {
            super.setSelected(selected, animated: animated)
            self.checkmarkView.isHidden = !selected
        }
        
        override func prepareForReuse() {
            super.prepareForReuse()
            self.colorView.backgroundColor = UIColor.clear
            self.checkmarkView.isHidden = true
        }
        
    }
    
    @objc func didPressDismiss(_ sender: AnyObject?) {
        self.delegate?.colorPickerWantsToDismiss(self)
    }
}

extension ColorPickerController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.colors.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return type(of: self).rowHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = self.tableView.dequeueReusableCell(withIdentifier: PickerCell.reuseIdentifier) as? PickerCell else {
            fatal("Cannot create cell")
        }
        
        cell.color = self.colors[(indexPath as NSIndexPath).row]
        cell.isSelected = cell.color == self.currentColor
        if cell.isSelected {
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.delegate?.colorPicker(self, didSelectColor: self.colors[(indexPath as NSIndexPath).row])
        self.currentColor = self.colors[(indexPath as NSIndexPath).row]
    }
}

final class AccentColorPickerController: ColorPickerController {
    fileprivate let allAccentColors: [AccentColor]
    
    
    init() {
        self.allAccentColors = AccentColor.allSelectable()
        
        super.init(colors: self.allAccentColors.map { UIColor(for: $0) })
        self.title = "self.settings.account_picture_group.color".localized(uppercased: true)
        
        if let accentColor = AccentColor(ZMAccentColor: ZMUser.selfUser().accentColorValue), let currentColorIndex = self.allAccentColors.firstIndex(of: accentColor) {
            self.currentColor = self.colors[currentColorIndex]
        }
        self.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.isScrollEnabled = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension AccentColorPickerController: ColorPickerControllerDelegate {
    func colorPicker(_ colorPicker: ColorPickerController, didSelectColor color: UIColor) {
        guard let colorIndex = self.colors.firstIndex(of: color) else {
            return
        }
        
        ZMUserSession.shared()?.performChanges {
            ZMUser.selfUser().accentColorValue = self.allAccentColors[colorIndex].zmAccentColor
        }
    }

    func colorPickerWantsToDismiss(_ colotPicker: ColorPickerController) {
        self.dismiss(animated: true, completion: .none)
    }
}


