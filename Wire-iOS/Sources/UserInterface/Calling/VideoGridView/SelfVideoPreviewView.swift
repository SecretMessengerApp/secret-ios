
import Foundation
import avs

protocol AVSIdentifierProvider {
    var stream: Stream { get }
}

extension AVSVideoView: AVSIdentifierProvider {
    
    var stream: Stream {
        return Stream(userId: UUID(uuidString: userid)!, clientId: clientid)
    }
    
}

final class SelfVideoPreviewView: UIView, AVSIdentifierProvider {
    
    private let previewView = AVSVideoPreview()
    
    let stream: Stream
    
    init(stream: Stream) {
        self.stream = stream
        
        super.init(frame: .zero)
        print("init(stream currentThread----\(Thread.current)")
        setupViews()
        createConstraints()
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        stopCapture()
    }
    
    private func setupViews() {
        [previewView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }
    }
    
    private func createConstraints() {
        previewView.fitInSuperview()
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        print("didMoveToWindow currentThread----\(Thread.current)")
        if window != nil {
            startCapture()
        }
    }
    
    func startCapture() {
        previewView.startVideoCapture()
    }
    
    func stopCapture() {
        previewView.stopVideoCapture()
    }

}
