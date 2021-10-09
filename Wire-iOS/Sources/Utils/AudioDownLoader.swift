//
//  AudioDownLoader.swift
//  Wire-iOS
//


import Foundation

public class AudioDownLoader: NSObject {
    
    private static let cacheAudioPath: String? = {
        let folders = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true) as [NSString]
        guard let cachepath = folders.first else {return nil}
        let cachep: NSString = cachepath as NSString
        let path = cachep.appendingPathComponent("audio_cache")
        if !FileManager.default.fileExists(atPath: path) {
            try? FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
        }
        return path
    }()
    
    private static var downloadingUrls: Set = Set<String>()
    private static var downedUrls: Set = Set<String>()
    

    public static func downLoadAudio(with downloadUrl: String) {

        if cacheFileExists(with: downloadUrl) != nil { return }
        if downedUrls.contains(downloadUrl) { return }
        if downloadingUrls.contains(downloadUrl) { return }
        
        downloadingUrls.insert(downloadUrl)

        guard let cacheFilePath = cacheFile(with: downloadUrl) else { return }
        
        AudioDownloadService.audio(
            from: downloadUrl,
            cacheTo: URL(fileURLWithPath: cacheFilePath),
            option: .removePreviousFile) {
                let index = downloadingUrls.firstIndex(of: downloadUrl)
                if let ind = index {
                    downloadingUrls.remove(at: ind)
                }
                saveCacheDataToPlist(with: downloadUrl)
        }
    }
    
  
    public static func cacheFileExists(with urlString: String) -> String? {
        guard let audioPath = cacheFile(with: urlString) else { return nil }
        if !FileManager.default.fileExists(atPath: audioPath) {
            return nil
        }
        return audioPath
    }
    
    private static func clearFile(with fileName: String) {
        let cachePath = cacheAudioPath! + "/" + fileName + ".mp4"
        guard FileManager.default.fileExists(atPath: cachePath) else {return}
        try? FileManager.default.removeItem(atPath: cachePath)
    }
    
    
    private static func cacheFile(with urlString: String) -> String? {
        
        guard let cache = cacheAudioPath else { return nil }
        return cache + "/" + urlString.md5 + ".mp4"
    }
    
   
    public static func saveCacheDataToPlist(with url: String) {
        
        let cacheOrderPath = cacheAudioPath! + "/audioCacheDataInfo.plist"
        var arr = NSMutableArray.init(contentsOfFile: cacheOrderPath)
        if arr == nil {
            arr = NSMutableArray.init()
        }
        let total = arr!.componentsJoined(by: ",")
        if total.contains(url.md5) {
            return
        }
        if arr!.count > 50 {
            for (i, obj) in arr!.enumerated() where i < 5 {
                clearFile(with: obj as! String)
            }
            arr!.removeObjects(in: NSMakeRange(0, 5))
        }
        arr!.add(url.md5)
        arr!.write(toFile: cacheOrderPath, atomically: true)
    }

}


class AudioDownloadService: NetworkRequest {
    
    class func audio(from url: String,
                     cacheTo destinationURL: URL,
                     option: NetworkDownloadRequestOption,
                     completion: @escaping () -> Void) {
        download(url,
                 to: destinationURL,
                 option: option).response { _ in
            completion()
        }
    }
}
