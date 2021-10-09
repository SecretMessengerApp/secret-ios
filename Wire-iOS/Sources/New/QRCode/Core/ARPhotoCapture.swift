

import Foundation
import AVFoundation

class ARPhotoCapture: NSObject, AVCapturePhotoCaptureDelegate {
    

    private let photoOutput = AVCapturePhotoOutput()
    var device: AVCaptureDevice? { return deviceInput?.device }
    var output: AVCaptureOutput { return photoOutput }
    let session = AVCaptureSession()
    var isCaptureSessionSetup: Bool = false
    var videoLayer: AVCaptureVideoPreviewLayer!
    var previewView: UIView!
    var isPreviewSetup: Bool = false
    var deviceInput: AVCaptureDeviceInput?
    
    public var generateImgListener: ((UIImage) -> Void)?
    public func start(with previewView: UIView, completion: (() -> Void)? = nil) {
        self.previewView = previewView
        if !self.isCaptureSessionSetup {
            self.setupCaptureSession()
        }
        self.startCamera(completion: {
            completion?()
        })
    }
    
    public func stop() {
        self.session.stopRunning()
    }
    
    private func newSettings() -> AVCapturePhotoSettings {
        var settings = AVCapturePhotoSettings()
        if #available(iOS 11.0, *) {
            settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
        } else {
            // Fallback on earlier versions
        }
        settings.isHighResolutionPhotoEnabled = true
        settings.flashMode = .auto
        return settings
    }
    
    func configure() {
        photoOutput.isHighResolutionCaptureEnabled = true
        // Improve capture time by preparing output with the desired settings.
        photoOutput.setPreparedPhotoSettingsArray([newSettings()], completionHandler: nil)
    }
    
    private func setupCaptureSession() {
        if self.isCaptureSessionSetup {
            return
        }
        session.beginConfiguration()
        session.sessionPreset = .photo
        let aDevice = deviceForPosition(.back)
        if let d = aDevice {
            deviceInput = try? AVCaptureDeviceInput(device: d)
        }
        if let videoInput = deviceInput {
            if session.canAddInput(videoInput) {
                session.addInput(videoInput)
            }
            if session.canAddOutput(output) {
                session.addOutput(output)
                configure()
            }
        }
        session.commitConfiguration()
        isCaptureSessionSetup = true
    }
    
    func startCamera(completion: @escaping (() -> Void)) {
        if !session.isRunning {
            self.session.sessionPreset = .photo
            let status = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
            switch status {
            case .notDetermined, .restricted, .denied:
                self.session.stopRunning()
            case .authorized:
                self.session.startRunning()
                completion()
                self.tryToSetupPreview()
            default:
                break
            }
        }
    }
    
    func tryToSetupPreview() {
        if !isPreviewSetup {
            setupPreview()
            isPreviewSetup = true
        }
    }
    
    func setupPreview() {
        videoLayer = AVCaptureVideoPreviewLayer(session: session)
        DispatchQueue.main.async {
            self.videoLayer.frame = self.previewView.bounds
            self.videoLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
            self.previewView.layer.addSublayer(self.videoLayer)
        }
    }
    
    public func shot() {
        doAfterPermissionCheck { [weak self] in
            self?.shotimpl()
        }
    }
    
    func shotimpl() {
        // Set current device orientation
        setCurrentOrienation()
        let settings = newSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
    
    func setCurrentOrienation() {
        let connection = output.connection(with: .video)
        let orientation = UIDevice.current.orientation
        switch orientation {
        case .portrait:
            connection?.videoOrientation = .portrait
        case .portraitUpsideDown:
            connection?.videoOrientation = .portraitUpsideDown
        case .landscapeRight:
            connection?.videoOrientation = .landscapeLeft
        case .landscapeLeft:
            connection?.videoOrientation = .landscapeRight
        default:
            connection?.videoOrientation = .portrait
        }
    }
    
    func doAfterPermissionCheck(block: @escaping () -> Void) {
        checkPermissionToAccessVideo { hasPermission in
            if hasPermission {
                block()
            }
        }
    }
    
    func checkPermissionToAccessVideo(block: @escaping (Bool) -> Void) {
        UIApplication.wr_requestOrWarnAboutMicrophoneAccess({ accepted in
            block(accepted)
        })
    }
}


extension ARPhotoCapture {
    
    @available(iOS 11.0, *)
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let data = photo.fileDataRepresentation() else { return }
        guard let image = UIImage(data: data) else {return}
        generateImgListener?(image)
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput,
                     didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?,
                     previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?,
                     resolvedSettings: AVCaptureResolvedPhotoSettings,
                     bracketSettings: AVCaptureBracketedStillImageSettings?,
                     error: Error?) {
        guard let buffer = photoSampleBuffer else { return }
        if let data = AVCapturePhotoOutput
            .jpegPhotoDataRepresentation(forJPEGSampleBuffer: buffer,
                                         previewPhotoSampleBuffer: previewPhotoSampleBuffer) {
            guard let image = UIImage(data: data) else {return}
            generateImgListener?(image)
        }
    }
}
