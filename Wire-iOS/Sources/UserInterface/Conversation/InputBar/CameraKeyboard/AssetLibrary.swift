

import Foundation
import Photos

public protocol AssetLibraryDelegate: class {
    func assetLibraryDidChange(_ library: AssetLibrary)
}

open class AssetLibrary: NSObject, PHPhotoLibraryChangeObserver {
    open weak var delegate: AssetLibraryDelegate?
    fileprivate var fetchingAssets = false
    public let synchronous: Bool
    let photoLibrary: PhotoLibraryProtocol

    open var count: UInt {
        guard let fetch = self.fetch else {
            return 0
        }
        return UInt(fetch.count)
    }
    
    public enum AssetError: Error {
        case outOfRange, notLoadedError
    }
    
    open func asset(atIndex index: UInt) throws -> PHAsset {
        guard let fetch = self.fetch else {
            throw AssetError.notLoadedError
        }
        
        if index >= count {
            throw AssetError.outOfRange
        }
        return fetch.object(at: Int(index))
    }
    
    open func refetchAssets(synchronous: Bool = false, isFilterVideo: Bool = false) {
        guard !self.fetchingAssets else {
            return
        }
        
        self.fetchingAssets = true
        
        let syncOperation = {
            let options = PHFetchOptions()
            if isFilterVideo {
                options.predicate = NSPredicate(format: "mediaType = \(PHAssetMediaType.image.rawValue)")
            }
            options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            self.fetch = PHAsset.fetchAssets(with: options)
            self.notifyChangeToDelegate()
        }
        
        if synchronous {
            syncOperation()
        }
        else {
            DispatchQueue(label: "WireAssetLibrary", qos: DispatchQoS.background, attributes: [], autoreleaseFrequency: DispatchQueue.AutoreleaseFrequency.inherit, target: .none).async(execute: syncOperation)
        }
    }

    open func photoLibraryDidChange(_ changeInstance: PHChange) {

        guard let fetch = self.fetch else {
            return
        }

        guard let changeDetails = changeInstance.changeDetails(for: fetch) else {
            return
        }

        self.fetch = changeDetails.fetchResultAfterChanges
        self.notifyChangeToDelegate()

    }
    
    fileprivate var fetch: PHFetchResult<PHAsset>?

    fileprivate func notifyChangeToDelegate() {

        let completion = {
            self.delegate?.assetLibraryDidChange(self)
            self.fetchingAssets = false
        }

        if synchronous {
            completion()
        } else {
            DispatchQueue.main.async(execute: completion)
        }

    }

    init(synchronous: Bool = false, photoLibrary: PhotoLibraryProtocol = PHPhotoLibrary.shared()) {
        self.synchronous = synchronous
        self.photoLibrary = photoLibrary

        super.init()

        self.photoLibrary.register(self)
        self.refetchAssets(synchronous: synchronous)
    }

    deinit {
        photoLibrary.unregisterChangeObserver(self)
    }
}
