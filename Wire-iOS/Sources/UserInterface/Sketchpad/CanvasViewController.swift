
import UIKit
import WireCanvas
import Cartography

protocol CanvasViewControllerDelegate : NSObjectProtocol {
    func canvasViewController(_ canvasViewController : CanvasViewController,  didExportImage image: UIImage, isOriginal: Bool)
}

enum CanvasViewControllerEditMode : UInt {
    case draw
    case emoji
}


final class CanvasViewController: UIViewController, UINavigationControllerDelegate {
    
    weak var delegate : CanvasViewControllerDelegate?
    var canvas = Canvas()
    var toolbar : SketchToolbar!
    let drawButton = IconButton()
    let emojiButton = IconButton()
    let sendButton = IconButton.sendButton()
    let photoButton = IconButton()
    let separatorLine = UIView()
    let hintLabel = UILabel()
    let hintImageView = UIImageView()
    var isEmojiKeyboardInTransition = false
    var sketchImage : UIImage? = nil {
        didSet {
            if let image = sketchImage {
                canvas.referenceImage = image
            }
            
        }
    }
    
    let emojiKeyboardViewController = EmojiKeyboardViewController()
    let colorPickerController = SketchColorPickerController()
    
    
    override var shouldAutorotate: Bool {
        switch UIDevice.current.userInterfaceIdiom {
        case .pad:
            return true
        default:
            return false
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        canvas.setNeedsDisplay()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        canvas.delegate = self
        canvas.backgroundColor = .dynamic(scheme: .background)
        
        emojiKeyboardViewController.delegate = self
        
        toolbar = SketchToolbar(buttons: [photoButton, drawButton, emojiButton, sendButton])
        separatorLine.backgroundColor = UIColor.dynamic(scheme: .separator)
        hintImageView.setIcon(.brush, size: 172, color: .dynamic(scheme: .placeholder))
        hintLabel.text = "sketchpad.initial_hint".localized.uppercased(with: Locale.current)
        hintLabel.numberOfLines = 0
        hintLabel.font = FontSpec(.small, .regular).font!
        hintLabel.textAlignment = .center
        hintLabel.textColor = .dynamic(scheme: .placeholder)
        view.backgroundColor = .dynamic(scheme: .background)
        
        [canvas, hintLabel, hintImageView, toolbar].forEach(view.addSubview)
        
        if sketchImage != nil {
            hideHint()
        }
        
        configureNavigationItems()
        configureColorPicker()
        configureButtons()
        updateButtonSelection()
        createConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateStatusBar(onlyFullScreen: false)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        updateStatusBar(onlyFullScreen: false)
    }
    
    func configureNavigationItems() {
        let undoImage = StyleKitIcon.undo.makeImage(size: .tiny, color: .black)
        let closeImage = StyleKitIcon.cross.makeImage(size: .tiny, color: .black)
        
        let closeButtonItem = UIBarButtonItem(image: closeImage, style: .plain, target: self, action: #selector(CanvasViewController.close))
        closeButtonItem.accessibilityIdentifier = "closeButton"
        
        let undoButtonItem = UIBarButtonItem(image: undoImage, style: .plain, target: canvas, action: #selector(Canvas.undo))
        undoButtonItem.isEnabled = false
        undoButtonItem.accessibilityIdentifier = "undoButton"
        
        navigationItem.leftBarButtonItem = undoButtonItem
        navigationItem.rightBarButtonItem = closeButtonItem
    }
    
    func configureButtons() {
        let hitAreaPadding = CGSize(width: 16, height: 16)
        
        sendButton.addTarget(self, action: #selector(exportImage), for: .touchUpInside)
        sendButton.isEnabled = false
        sendButton.hitAreaPadding = hitAreaPadding
        
        drawButton.setIcon(.brush, size: .tiny, for: .normal)
        drawButton.addTarget(self, action: #selector(toggleDrawTool), for: .touchUpInside)
        drawButton.hitAreaPadding = hitAreaPadding
        drawButton.accessibilityIdentifier = "drawButton"
        
        photoButton.setIcon(.photo, size: .tiny, for: .normal)
        photoButton.addTarget(self, action: #selector(pickImage), for: .touchUpInside)
        photoButton.hitAreaPadding = hitAreaPadding
        photoButton.accessibilityIdentifier = "photoButton"
        
        emojiButton.setIcon(.emoji, size: .tiny, for: .normal)
        emojiButton.addTarget(self, action: #selector(openEmojiKeyboard), for: .touchUpInside)
        emojiButton.hitAreaPadding = hitAreaPadding
        emojiButton.accessibilityIdentifier = "emojiButton"
        
        [photoButton, drawButton, emojiButton].forEach { iconButton in
            iconButton.setIconColor(.dynamic(scheme: .iconNormal), for: .normal)
            iconButton.setIconColor(.dynamic(scheme: .iconHighlighted), for: .highlighted)
            iconButton.setIconColor(.accent(), for: .selected)
        }
    }
    
    func configureColorPicker() {
        colorPickerController.sketchColors = [.black,
                                              .white,
                                              .strongBlue,
                                              .strongLimeGreen,
                                              .brightYellow,
                                              .vividRed,
                                              .brightOrange,
                                              .softPink,
                                              .violet,
                                              UIColor(red: 0.688, green: 0.342, blue: 0.002, alpha: 1),
                                              UIColor(red: 0.381, green: 0.192, blue: 0.006, alpha: 1),
                                              UIColor(red: 0.894, green: 0.735, blue: 0.274, alpha: 1),
                                              UIColor(red: 0.905, green: 0.317, blue: 0.466, alpha: 1),
                                              UIColor(red: 0.58,  green: 0.088, blue: 0.318, alpha: 1),
                                              UIColor(red: 0.431, green: 0.65,  blue: 0.749, alpha: 1),
                                              UIColor(red: 0.6,   green: 0.588, blue: 0.278, alpha: 1),
                                              UIColor(red: 0.44,  green: 0.44,  blue: 0.44,  alpha: 1)]
        
        colorPickerController.view.addSubview(separatorLine)
        colorPickerController.delegate = self
        colorPickerController.willMove(toParent: self)
        view.addSubview(colorPickerController.view)
        addChild(colorPickerController)
        colorPickerController.selectedColorIndex = colorPickerController.sketchColors.firstIndex(of: .accent()) ?? 0
    }
    
    func createConstraints() {
        constrain(view, canvas, colorPickerController.view, toolbar, separatorLine) { container, canvas, colorPicker, toolbar, separatorLine in
            colorPicker.top == container.top
            colorPicker.left == container.left
            colorPicker.right == container.right
            colorPicker.height == 48
            
            separatorLine.top == colorPicker.bottom
            separatorLine.left == colorPicker.left
            separatorLine.right == colorPicker.right
            separatorLine.height == .hairline
            
            canvas.top == colorPicker.bottom
            canvas.left == container.left
            canvas.right == container.right
            
            toolbar.top == canvas.bottom
            toolbar.bottom == container.bottom
            toolbar.left == container.left
            toolbar.right == container.right
        }
        
        constrain(view, colorPickerController.view, hintImageView, hintLabel) { container, colorPicker, hintImageView, hintLabel in
            hintImageView.center == container.center
            hintLabel.top == colorPicker.bottom + 16
            hintLabel.leftMargin == container.leftMargin
            hintLabel.rightMargin == container.rightMargin
        }
    }
    
    func updateButtonSelection() {
        drawButton.isSelected = canvas.mode == .draw
        colorPickerController.view.isHidden = canvas.mode != .draw
    }
    
    func hideHint() {
        hintLabel.isHidden = true
        hintImageView.isHidden = true
    }
    
    // MARK - actions
    
    @objc func toggleDrawTool() {
        if canvas.mode == .edit {
            canvas.mode = .draw
        } else {
            canvas.mode = .edit
        }
        
        updateButtonSelection()
    }
    
    @objc func openEmojiKeyboard() {
        select(editMode: .emoji, animated: true)
    }
    
    @objc func exportImage() {
        if let image = canvas.trimmedImage {
            delegate?.canvasViewController(self, didExportImage: image,isOriginal: true)
        }
    }
    
    @objc func close() {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        hideEmojiKeyboard(animated: true)
    }
    
    func select(editMode: CanvasViewControllerEditMode, animated: Bool) {
        
        switch editMode {
        case .draw:
            hideEmojiKeyboard(animated: animated)
            canvas.mode = .draw
            updateButtonSelection()
        case .emoji:
            canvas.mode = .edit
            updateButtonSelection()
            showEmojiKeyboard(animated: animated)
        }
    }
}

extension CanvasViewController : CanvasDelegate {
    
    func canvasDidChange(_ canvas: Canvas) {
        sendButton.isEnabled = canvas.hasChanges
        navigationItem.leftBarButtonItem?.isEnabled = canvas.hasChanges
        hideHint()
    }
    
}

extension CanvasViewController : EmojiKeyboardViewControllerDelegate {
    
    func showEmojiKeyboard(animated: Bool) {
        guard !isEmojiKeyboardInTransition else { return }
        
        emojiKeyboardViewController.willMove(toParent: self)
        view.addSubview(emojiKeyboardViewController.view)
        
        constrain(view, emojiKeyboardViewController.view) { container, emojiKeyboardView in
            emojiKeyboardView.height == KeyboardHeight.current
            emojiKeyboardView.left == container.left
            emojiKeyboardView.right == container.right
            emojiKeyboardView.bottom == container.bottom
        }
        
        addChild(emojiKeyboardViewController)
        
        if (animated) {
            isEmojiKeyboardInTransition = true
            
            let offscreen = CGAffineTransform(translationX: 0, y: KeyboardHeight.current)
            emojiKeyboardViewController.view.transform = offscreen
            view.layoutIfNeeded()
            
            UIView.animate(withDuration: 0.25,
                           delay: 0,
                           options: UIView.AnimationOptions(rawValue: UInt(7)),
                           animations: {
                            self.emojiKeyboardViewController.view.transform = CGAffineTransform.identity
            },
                           completion: { (finished) in
                            self.isEmojiKeyboardInTransition = false
            })
        }
    }
    
    func hideEmojiKeyboard(animated: Bool) {
        guard children.contains(emojiKeyboardViewController), !isEmojiKeyboardInTransition else { return }
        
        emojiKeyboardViewController.willMove(toParent: nil)
        
        let removeEmojiKeyboardViewController = {
            self.emojiKeyboardViewController.view.removeFromSuperview()
            self.emojiKeyboardViewController.removeFromParent()
        }
        
        if (animated) {
            
            isEmojiKeyboardInTransition = true
            
            UIView.animate(withDuration: 0.25,
                           delay: 0,
                           options: UIView.AnimationOptions(rawValue: UInt(7)),
                           animations: {
                            let offscreen = CGAffineTransform(translationX: 0, y: self.emojiKeyboardViewController.view.bounds.size.height)
                            self.emojiKeyboardViewController.view.transform = offscreen
            },
                           completion: { (finished) in
                            self.isEmojiKeyboardInTransition = false
                            removeEmojiKeyboardViewController()
            })
        } else {
            removeEmojiKeyboardViewController()
        }
    }
    
    func emojiKeyboardViewControllerDeleteTapped(_ viewController: EmojiKeyboardViewController) {
        
    }
    
    func emojiKeyboardViewController(_ viewController: EmojiKeyboardViewController, didSelectEmoji emoji: String) {
        
        let attributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 82)]
        
        if let image = emoji.image(renderedWithAttributes: attributes)?.imageWithAlphaTrimmed {
            canvas.insert(image: image, at: CGPoint(x: canvas.center.x - image.size.width / 2, y: canvas.center.y - image.size.height / 2))
        }
        
        hideEmojiKeyboard(animated: true)
    }
}

extension CanvasViewController : UIImagePickerControllerDelegate {
    
    @objc func pickImage() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        defer {
            picker.dismiss(animated: true, completion: nil)
        }

        guard let image = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage else {

            return
        }

        canvas.referenceImage = image
        canvas.mode = .draw
        updateButtonSelection()
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
}

extension CanvasViewController : SketchColorPickerControllerDelegate {
    
    func sketchColorPickerController(_ controller: SketchColorPickerController, changedSelectedColor color: UIColor) {
        canvas.brush = Brush(size: Float(controller.brushWidth(for: color)), color: color)
    }
    
}
