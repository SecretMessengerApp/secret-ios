
import Foundation

final class ReplyRoundCornersView: UIControl {
    let containedView: UIView
    private let grayBoxView = UIView()
    private let highlightLayer = UIView()
    
    init(containedView: UIView) {
        self.containedView = containedView
        super.init(frame: .zero)
        setupSubviews()
        setupConstraints()
    }
    
    private func setupSubviews() {
//        layer.cornerRadius = 8
//        layer.borderWidth = 1
//        layer.borderColor = UIColor.from(scheme: .replyBorder).cgColor
//        layer.masksToBounds = true

        highlightLayer.alpha = 0

        highlightLayer.backgroundColor = .from(scheme: .replyHighlight)
        grayBoxView.backgroundColor = UIColor.init(hex: 0xf27405)

        addSubview(containedView)
        addSubview(grayBoxView)
        addSubview(highlightLayer)
    }
    
    private func setupConstraints() {
        containedView.translatesAutoresizingMaskIntoConstraints = false
        grayBoxView.translatesAutoresizingMaskIntoConstraints = false
        highlightLayer.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            containedView.leadingAnchor.constraint(equalTo: grayBoxView.trailingAnchor),
            containedView.topAnchor.constraint(equalTo: topAnchor),
            containedView.bottomAnchor.constraint(equalTo: bottomAnchor),
            containedView.trailingAnchor.constraint(equalTo: trailingAnchor),
            grayBoxView.leadingAnchor.constraint(equalTo: leadingAnchor),
            grayBoxView.topAnchor.constraint(equalTo: topAnchor),
            grayBoxView.bottomAnchor.constraint(equalTo: bottomAnchor),
            grayBoxView.widthAnchor.constraint(equalToConstant: 4),
            highlightLayer.leadingAnchor.constraint(equalTo: leadingAnchor),
            highlightLayer.topAnchor.constraint(equalTo: topAnchor),
            highlightLayer.bottomAnchor.constraint(equalTo: bottomAnchor),
            highlightLayer.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UIControl

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        setHighlighted(true, animated: false)
        sendActions(for: .touchDown)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        defer {
            setHighlighted(false, animated: true)
        }

        guard
            let touchLocation = touches.first?.location(in: self),
            bounds.contains(touchLocation)
        else {
            return sendActions(for: .touchUpOutside)
        }

        sendActions(for: .touchUpInside)
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        setHighlighted(false, animated: true)
        sendActions(for: .touchCancel)
    }

    private func setHighlighted(_ isHighlighted: Bool, animated: Bool) {
        let changes = {
            self.highlightLayer.alpha = isHighlighted ? 1 : 0
            self.layer.borderWidth = isHighlighted ? 0 : 1
        }

        if animated {
            UIView.animate(withDuration: 0.15, animations: changes)
        } else {
            changes()
        }
    }
}
