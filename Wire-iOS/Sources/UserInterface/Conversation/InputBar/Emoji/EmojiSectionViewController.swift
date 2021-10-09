

import Foundation


protocol EmojiSectionViewControllerDelegate: class {
    func sectionViewController(_ viewController: EmojiSectionViewController, didSelect: EmojiSectionType, scrolling: Bool)
}


final class EmojiSectionViewController: UIViewController {
    
    private var typesByButton = [IconButton: EmojiSectionType]()
    private var sectionButtons = [IconButton]()
    private let iconSize = StyleKitIcon.Size.tiny.rawValue
    private var ignoreSelectionUpdates = false
    
    private var selectedType: EmojiSectionType? {
        willSet(value) {
            guard let type = value else { return }
            typesByButton.forEach { button, sectionType in
                button.isSelected = type == sectionType
            }
        }
    }
    
    weak var sectionDelegate: EmojiSectionViewControllerDelegate? = nil
    
    init(types: [EmojiSectionType]) {
        super.init(nibName: nil, bundle: nil)
        createButtons(types)
        
        setupViews()
        createConstraints()
        view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(didPan)))
        selectedType = typesByButton.values.first
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func createButtons(_ types: [EmojiSectionType]) {
        sectionButtons = types.map(createSectionButton)
        zip(types, sectionButtons).forEach { (type, button) in
            typesByButton[button] = type
        }
    }
    
    private func setupViews() {
        sectionButtons.forEach(view.addSubview)
    }
    
    private func createSectionButton(for type: EmojiSectionType) -> IconButton {
        
        let button: IconButton = {
            let button = IconButton(style: .default)
            button.setIconColor(UIColor.from(scheme: .textDimmed, variant: .dark), for: .normal)
            button.setIconColor(.from(scheme: .textForeground, variant: .dark), for: .selected)
            button.setIconColor(.from(scheme: .iconHighlighted, variant: .dark), for: .highlighted)
            button.setBackgroundImageColor(.clear, for: .selected)
            button.setBorderColor(.clear, for: .normal)
            button.circular = false
            button.borderWidth = 0
            
            button.setIcon(type.icon, size: .tiny, for: .normal)
            
            return button
        }()
        
        button.addTarget(self, action: #selector(didTappButton), for: .touchUpInside)
        return button
    }
    
    func didSelectSection(_ type: EmojiSectionType) {
        guard let selected = selectedType, type != selected, !ignoreSelectionUpdates else { return }
        selectedType = type
    }
    
    @objc private func didTappButton(_ sender: IconButton) {
        guard let type = typesByButton[sender] else { return }
        sectionDelegate?.sectionViewController(self, didSelect: type, scrolling: false)
    }
    
    @objc private func didPan(_ recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .possible: break
        case .began:
            ignoreSelectionUpdates = true
            fallthrough
        case .changed:
            let location = recognizer.location(in: view)
            guard let button = sectionButtons.filter ({ $0.frame.contains(location) }).first else { return }
            guard let type = typesByButton[button] else { return }
            sectionDelegate?.sectionViewController(self, didSelect: type, scrolling: true)
            selectedType = type
        case .ended, .failed, .cancelled:
            ignoreSelectionUpdates = false
        @unknown default:
            break
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        sectionButtons.forEach {
            $0.removeFromSuperview()
            view.addSubview($0)
        }
        
        createConstraints()
        sectionButtons.forEach {
            $0.hitAreaPadding = CGSize(width: 5, height: view.bounds.height / 2)
        }
    }
    
    private func createConstraints() {
        
        let inset: CGFloat = 16
        let count = CGFloat(sectionButtons.count)
        let fullSpacing = (view.bounds.width - 2 * inset) - iconSize
        let padding: CGFloat = fullSpacing / (count - 1)
        
        var constraints = [NSLayoutConstraint]()
        
        sectionButtons.enumerated().forEach { idx, button in
            
            button.translatesAutoresizingMaskIntoConstraints = false
            
            switch idx {
            case 0:
                constraints.append(button.pinToSuperview(anchor: .leading, inset: inset, activate: false))
                constraints.append(view.heightAnchor.constraint(equalToConstant: iconSize + inset))
            default:
                let previous = sectionButtons[idx - 1]
                constraints.append(button.centerXAnchor.constraint(equalTo: previous.centerXAnchor, constant: padding))
            }
            
            constraints.append(button.pinToSuperview(anchor: .top, activate: false))
        }
        
        NSLayoutConstraint.activate(constraints)
    }
    
}
