

import UIKit
import Photos

extension Notification.Name {
    static let UserGrantedAudioPermissions = Notification.Name("UserGrantedAudioPermissionsNotification")
}

extension UIApplication {
    @objc
    class func wr_requestOrWarnAboutMicrophoneAccess(_ grantedHandler: @escaping (_ granted: Bool) -> Void, _ warnAboutMicrophonePermissionAlert: (() -> Void)? = nil) {
        let audioPermissionsWereNotDetermined = AVCaptureDevice.authorizationStatus(for: .audio) == .notDetermined
        
        AVAudioSession.sharedInstance().requestRecordPermission({ granted in
            
            DispatchQueue.main.async(execute: {
                if !granted {
                    if let warnAboutMicrophonePermissionAlert = warnAboutMicrophonePermissionAlert {
                        warnAboutMicrophonePermissionAlert()
                    } else {
                        self.wr_warnAboutMicrophonePermission()
                    }
                }
                
                if audioPermissionsWereNotDetermined && granted {
                    NotificationCenter.default.post(name: Notification.Name.UserGrantedAudioPermissions, object: nil)
                }
                grantedHandler(granted)
            })
        })
    }
    
    @objc
    class func wr_requestOrWarnAboutVideoAccess(_ grantedHandler: @escaping (_ granted: Bool) -> Void) {
        UIApplication.wr_requestVideoAccess({ granted in
            DispatchQueue.main.async(execute: {
                if !granted {
                    self.wr_warnAboutCameraPermission(withCompletion: {
                        grantedHandler(granted)
                    })
                } else {
                    grantedHandler(granted)
                }
            })
        })
    }
    
    @objc
    static func wr_requestOrWarnAboutPhotoLibraryAccess(_ grantedHandler: ((Bool) -> Swift.Void)!) {
        PHPhotoLibrary.requestAuthorization({ status in
            DispatchQueue.main.async(execute: {
                switch status {
                case .restricted:
                    self.wr_warnAboutPhotoLibraryRestricted()
                    grantedHandler(false)
                case .denied,
                     .notDetermined:
                    self.wr_warnAboutPhotoLibaryDenied()
                    grantedHandler(false)
                case .authorized:
                    grantedHandler(true)
                @unknown default:
                    break
                }
            })
        })
    }
    
    @objc
    class func wr_requestVideoAccess(_ grantedHandler: @escaping (_ granted: Bool) -> Void) {
        AVCaptureDevice.requestAccess(for: .video, completionHandler: { granted in
            DispatchQueue.main.async(execute: {
                grantedHandler(granted)
            })
        })
    }
    
    private class func wr_warnAboutCameraPermission(withCompletion completion: @escaping () -> ()) {
        let currentResponder = UIResponder.currentFirst
        (currentResponder as? UIView)?.endEditing(true)
        
        let noVideoAlert = UIAlertController.alertWithOKButton(title: "voice.alert.camera_warning.title".localized,
                                                               message: "voice.alert.camera_warning.explanation".localized,
                                                               okActionHandler: { action in
                                                                completion()
        })
        
        let actionSettings = UIAlertAction(title: "general.open_settings".localized,
                                           style: .default,
                                           handler: { action in
                                            if let url = URL(string: UIApplication.openSettingsURLString) {
                                                UIApplication.shared.open(url, options: [:])
                                            }
                                            completion()
        })
        
        noVideoAlert.addAction(actionSettings)
        
        AppDelegate.shared.window?.rootViewController?.present(noVideoAlert, animated: true)
    }
    
    class func wr_warnAboutMicrophonePermission(_ rootVC: UIViewController? = nil) {
        let noMicrophoneAlert = UIAlertController.alertWithOKButton(title: "voice.alert.microphone_warning.title".localized,
                                                                    message:"voice.alert.microphone_warning.explanation".localized,
                                                                    okActionHandler: nil)
        
        let actionSettings = UIAlertAction(title: "general.open_settings".localized,
                                           style: .default,
                                           handler: { action in
                                            if let url = URL(string: UIApplication.openSettingsURLString) {
                                                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                                            }
        })
        
        noMicrophoneAlert.addAction(actionSettings)
        
        if let rootVC = rootVC {
            rootVC.present(noMicrophoneAlert, animated: true)
        } else {
            AppDelegate.shared.window?.rootViewController?.present(noMicrophoneAlert, animated: true)
        }
    }
    
    private class func wr_warnAboutPhotoLibraryRestricted() {
        let libraryRestrictedAlert = UIAlertController.alertWithOKButton(title:"library.alert.permission_warning.title".localized,
                                                                         message: "library.alert.permission_warning.restrictions.explaination".localized)
        
        AppDelegate.shared.window?.rootViewController?.present(libraryRestrictedAlert, animated: true)
    }
    
    private class func wr_warnAboutPhotoLibaryDenied() {
        let deniedAlert = UIAlertController(title: "library.alert.permission_warning.title".localized,
                                            message: "library.alert.permission_warning.not_allowed.explaination".localized,
                                            alertAction: UIAlertAction.cancel())
        
        deniedAlert.addAction(UIAlertAction(title: "general.open_settings".localized,
                                            style: .default,
                                            handler: { action in
                                                if let url = URL(string: UIApplication.openSettingsURLString) {
                                                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                                                }
        }))
        
        DispatchQueue.main.async(execute: {
            AppDelegate.shared.window?.rootViewController?.present(deniedAlert, animated: true)
        })
    }
}

//extension UIAlertController {
//    convenience init(title: String? = nil,
//                     message: String,
//                     alertAction: UIAlertAction) {
//        self.init(title: title,
//                  message: message,
//                  preferredStyle: .alert)
//        addAction(alertAction)
//    }
//}
