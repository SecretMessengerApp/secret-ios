//
//  QRCodeScanViewController.swift
//  Wire-iOS
//

import UIKit
import AVFoundation
import avs

class QRCodeScanViewController: UIViewController {

    private let result: (String?) -> Void

    init(result: @escaping (String?) -> Void) {
        self.result = result
        super.init(nibName: nil, bundle: nil)
    }
    
    func restart() {
        self.scanner?.restart()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stop()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.start()
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var scanner: QRCodeScanner?

    override public func viewDidLoad() {
        super.viewDidLoad()
        edgesForExtendedLayout = UIRectEdge(rawValue: 0)

        guard !UIDevice.isSimulator else { return }
        DevicePermission(type: .camera) { [weak self] status in
            guard let self = self else { return }
            if status {
                self.scanner = QRCodeScanner(videoPreview: self.view) { result in
                    self.result(result)
                }
                self.start()
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.scanner?.update(size: view.frame.size)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.scanner?.update(size: view.frame.size)
    }
    
    public func start() {
        self.scanner?.start()
    }
    
    public func stop() {
        self.scanner?.stop()
    }
}

// MARK: - Scanner
class QRCodeScanner: NSObject {

    private let captureSession = AVCaptureSession()
    private let output = AVCaptureMetadataOutput()

    private let result: (String?) -> Void

    private let scanView: QRCodeScanView

    private var observation: NSObjectProtocol?
    private var previewLayer: AVCaptureVideoPreviewLayer?

    init(videoPreview: UIView, result: @escaping (String?) -> Void) {

        self.result = result
        self.scanView = QRCodeScanView(frame: videoPreview.frame)

        super.init()

        do {
            if
                let device = AVCaptureDevice.default(for: .video),
                device.isFocusPointOfInterestSupported,
                device.isFocusModeSupported(.continuousAutoFocus) {
                try device.lockForConfiguration()
                device.focusMode = .continuousAutoFocus
                device.videoZoomFactor = 1.5
                device.unlockForConfiguration()
                let input = try AVCaptureDeviceInput(device: device)
                captureSession.addInput(input)
            }
        } catch { }
    
        if captureSession.canAddOutput(output) {
            captureSession.addOutput(output)
            output.metadataObjectTypes = [.qr]
            output.setMetadataObjectsDelegate(self, queue: .main)
            videoPreview.addSubview(scanView)
            var frame = videoPreview.frame
            frame.origin = .zero
            let layer = AVCaptureVideoPreviewLayer(session: captureSession)
            layer.videoGravity = .resizeAspectFill
            layer.frame = frame

            videoPreview.layer.insertSublayer(layer, at: 0)
            self.previewLayer = layer
            updateOrigination()
            observation = NotificationCenter.default.addObserver(forName: .AVCaptureInputPortFormatDescriptionDidChange, object: nil, queue: .current) {[weak self] _ in
                guard let self = self else {return}
                self.output.rectOfInterest = layer.metadataOutputRectConverted(fromLayerRect: self.scanView.scanRect)
            }
        }
    }
    

    func update(size: CGSize) {
        self.scanView.frame = CGRect(origin: .zero, size: size)
        self.scanView.update()
        self.previewLayer?.frame = self.scanView.frame
        guard let target = self.previewLayer else { return }
        updateOrigination()
        self.output.rectOfInterest = target.metadataOutputRectConverted(fromLayerRect: self.scanView.scanRect)
    }
    
    func updateOrigination() {
        guard let target = self.previewLayer else { return }

        switch UIDevice.current.orientation {
        case .portrait:
            target.connection?.videoOrientation = .portrait
        case .portraitUpsideDown:
            target.connection?.videoOrientation = .portraitUpsideDown
        case .landscapeLeft:
            target.connection?.videoOrientation = .landscapeRight
        case .landscapeRight:
            target.connection?.videoOrientation = .landscapeLeft
        default:
            break
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension QRCodeScanner {

    func start() {
        if !captureSession.isRunning {
            captureSession.startRunning()
            //            scanView.startAnimation()
        }
    }
    func stop() {
        if captureSession.isRunning {
            captureSession.stopRunning()
            AVSMediaManager.sharedInstance()?.playKnockSound()
            //            scanView.stopAnimation()
            if let observation = observation {
                NotificationCenter.default.removeObserver(observation)
            }
        }
    }
    
    func restart() {
        if captureSession.isRunning { return }
        start()
    }
}

extension QRCodeScanner: AVCaptureMetadataOutputObjectsDelegate {

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {

        metadataObjects.forEach { obj in
            stop()
            if let obj = obj as? AVMetadataMachineReadableCodeObject {
                result(obj.stringValue)
            } else {
                result(nil)
            }
        }
    }
}

// MARK: - Scan View
class QRCodeScanView: UIView {

    struct QRCodeScanViewStyle {
        var lineColor: UIColor = .white
        var cornerColor = UIColor(red: 0.0, green: 167.0/255.0, blue: 231.0/255.0, alpha: 1.0)
        var cornerWidth: CGFloat = 24
        var cornerHeight: CGFloat = 6
        var unRecoginitonAreaColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.5)
    }

    var scanRect: CGRect {
        let marginX: CGFloat = 44
        let maxWidth = min(375.0, frame.width)
        let wh = maxWidth - marginX * 2
        let y = center.y - wh * 0.5
        let x = center.x - wh * 0.5
        return CGRect(x: x, y: y, width: wh, height: wh)
    }

    private let style: QRCodeScanViewStyle

    override init(frame: CGRect) {
        self.style = QRCodeScanViewStyle()
        super.init(frame: frame)
        backgroundColor = .clear
        addSubview(netImgView)
        netImgView.frame = scanRect
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private lazy var netImgView: UIImageView = {
        let view = UIImageView(image: UIImage(named: "scan_net"))
        view.clipsToBounds = true
        view.layer.masksToBounds = true
        return view
    }()

    func startAnimation() {
        if netImgView.layer.animation(forKey: "scan_animation") != .none {
            let pause = netImgView.layer.timeOffset
            let begin = CACurrentMediaTime() - pause
            netImgView.layer.timeOffset = 0
            netImgView.layer.beginTime = begin
            netImgView.layer.speed = 1.0
        } else {
            creatAnimation()
        }
    }
    
    func update() {
        self.setNeedsDisplay()
        netImgView.frame = scanRect
    }

    private func creatAnimation() {
        let animation = CABasicAnimation()
        animation.keyPath = "position.y"
        //        animation.fromValue = scanRect.minY
        //        animation.toValue = scanRect.maxY
        animation.byValue = scanRect.height
        animation.duration = 2
        animation.repeatCount = .greatestFiniteMagnitude
        netImgView.layer.add(animation, forKey: "scan_animation")
        let x = scanRect.origin.x + scanRect.width * 0.5
        let y = scanRect.origin.y + scanRect.height * 0.5
        netImgView.layer.position = CGPoint(x: x, y: y)
    }

    func stopAnimation() {
        netImgView.layer.removeAllAnimations()
    }

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }

        context.setStrokeColor(style.lineColor.cgColor)
        context.setLineWidth(1)
        context.addRect(scanRect)
        context.strokePath()


        let wAngle = style.cornerWidth
        let hAngle = style.cornerWidth

    
        let linewidthAngle = style.cornerHeight

        context.setStrokeColor(style.cornerColor.cgColor)
        context.setFillColor(UIColor.white.cgColor)
        context.setLineWidth(linewidthAngle)

        let leftX = scanRect.minX
        let topY = scanRect.minY
        let rightX = scanRect.maxX
        let bottomY = scanRect.maxY


        context.move(to: CGPoint(x: leftX-linewidthAngle/2, y: topY))
        context.addLine(to: CGPoint(x: leftX + wAngle, y: topY))

        context.move(to: CGPoint(x: leftX, y: topY-linewidthAngle/2))
        context.addLine(to: CGPoint(x: leftX, y: topY+hAngle))


        context.move(to: CGPoint(x: leftX-linewidthAngle/2, y: bottomY))
        context.addLine(to: CGPoint(x: leftX + wAngle, y: bottomY))


        context.move(to: CGPoint(x: leftX, y: bottomY+linewidthAngle/2))
        context.addLine(to: CGPoint(x: leftX, y: bottomY - hAngle))


        context.move(to: CGPoint(x: rightX+linewidthAngle/2, y: topY))
        context.addLine(to: CGPoint(x: rightX - wAngle, y: topY))


        context.move(to: CGPoint(x: rightX, y: topY-linewidthAngle/2))
        context.addLine(to: CGPoint(x: rightX, y: topY + hAngle))


        context.move(to: CGPoint(x: rightX+linewidthAngle/2, y: bottomY))
        context.addLine(to: CGPoint(x: rightX - wAngle, y: bottomY))


        context.move(to: CGPoint(x: rightX, y: bottomY+linewidthAngle/2))
        context.addLine(to: CGPoint(x: rightX, y: bottomY - hAngle))

        context.strokePath()
    }
}
