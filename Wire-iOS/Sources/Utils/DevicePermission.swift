//
//  DevicePermission.swift
//  Wire-iOS
//


import Photos

struct DevicePermission {

    enum `Type` {
        case camera, photoLibrary
    }

    @discardableResult
    init(type: Type, completion: @escaping (Bool) -> Void) {
        switch type {
        case .camera:
            let status = AVCaptureDevice.authorizationStatus(for: .video)
            switch status {
            case .authorized: completion(true)
            case .denied, .restricted: completion(false)
            case .notDetermined:
                AVCaptureDevice.requestAccess(for: .video) { status in
                    DispatchQueue.main.async {
                        completion(status)
                    }
                }
            @unknown default:
                completion(false)
            }

        case .photoLibrary:
            let status = PHPhotoLibrary.authorizationStatus()
            switch status {
            case .authorized: completion(true)
            case .denied, .restricted: completion(false)
            case .notDetermined:
                PHPhotoLibrary.requestAuthorization { status in
                    DispatchQueue.main.async {
                        completion(status == .authorized)
                    }
                }
            case .limited:
                completion(false)
            @unknown default:
                completion(false)
            }
        }
    }
}
