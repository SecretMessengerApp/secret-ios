
import Foundation
import UIKit
import avs

final class VideoPreviewView: UIView, AVSIdentifierProvider {

    var stream: Stream
    var isPaused = false {
        didSet {
            guard oldValue != isPaused else { return }
            updateState(animated: true)
        }
    }

    private var previewView: AVSVideoView?
    private let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    private let pausedLabel = UILabel(
        key: "call.video.paused",
        size: .normal,
        weight: .semibold,
        color: .textForeground,
        variant: .dark
    )

    private var userHasSetFillMode: Bool = false
    private var snapshotView: UIView?

    init(stream: Stream) {
        self.stream = stream
        
        super.init(frame: .zero)
        
        setupViews()
        createConstraints()
        updateState()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        [blurView, pausedLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }
        pausedLabel.textAlignment = .center
    }

    private func createConstraints() {
        blurView.fitInSuperview()
        pausedLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        pausedLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
    
    private func createPreviewView() {
        let preview = AVSVideoView()
        preview.userid = stream.userId.transportString()
        preview.clientid = stream.clientId
        preview.translatesAutoresizingMaskIntoConstraints = false
        if let snapshotView = snapshotView {
            insertSubview(preview, belowSubview: snapshotView)
        } else {
            addSubview(preview)
        }
        preview.fitInSuperview()
        preview.shouldFill = true

        previewView = preview
    }

    public func switchFillMode() {
        guard let previewView = previewView else { return }
        userHasSetFillMode = true
        previewView.shouldFill = !previewView.shouldFill
    }
    
    private func createSnapshotView() {
        guard let snapshotView = previewView?.snapshotView(afterScreenUpdates: true) else { return }
        insertSubview(snapshotView, belowSubview: blurView)
        snapshotView.translatesAutoresizingMaskIntoConstraints = false
        snapshotView.fitInSuperview()
        self.snapshotView = snapshotView
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if !userHasSetFillMode {
            previewView?.shouldFill = (previewView?.videoSize.aspectRatio == previewView?.frame.size.aspectRatio)
        }
    }

    private func updateState(animated: Bool = false) {
        if isPaused {
            createSnapshotView()
            blurView.effect = nil
            pausedLabel.alpha = 0
            blurView.isHidden = false
            pausedLabel.isHidden = false

            let animationBlock = { [weak self] in
                self?.blurView.effect = UIBlurEffect(style: .dark)
                self?.pausedLabel.alpha = 1
            }
            
            let completionBlock = { [weak self] (_: Bool) -> () in
                self?.previewView?.removeFromSuperview()
                self?.previewView = nil
            }
            
            if animated {
                UIView.animate(withDuration: 0.2, animations: animationBlock, completion: completionBlock)
            }
            else {
                animationBlock()
                completionBlock(true)
            }
        } else {
            createPreviewView()
            let animationBlock = { [weak self] in
                self?.blurView.effect = nil
                self?.snapshotView?.alpha = 0
                self?.pausedLabel.alpha = 0
            }
            
            let completionBlock =  { [weak self] (_: Bool) -> () in
                self?.snapshotView?.removeFromSuperview()
                self?.snapshotView = nil
                self?.blurView.isHidden = true
                self?.pausedLabel.isHidden = true
            }
            
            if animated {
                UIView.animate(withDuration: 0.2, animations: animationBlock, completion: completionBlock)
            }
            else {
                animationBlock()
                completionBlock(true)
            }
        }
    }

}
