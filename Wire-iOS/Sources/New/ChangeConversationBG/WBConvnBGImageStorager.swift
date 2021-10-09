//
//  WBConvnBGImageStorager.swift
//  Wire-iOS
//

import UIKit

private let fileName = "conversation_bg_image.plist"

class WBConvnBGImageStorager: NSObject {
    static let sharedInstance = WBConvnBGImageStorager()
    private var dictionary: NSMutableDictionary = NSMutableDictionary()

    override init() {
        super.init()
        readDicFromDisk()
    }

    func imageName(conversationId: String) -> String {
        let imageName = self.dictionary[conversationId] as? String

        return imageName ?? "conversation_bg_0"
    }

    func addImageName(conversationId: String, imageName: String) {
        self.dictionary[conversationId] = imageName
        writeDicToDisk()
        NotificationCenter.default.post(
            name: NSNotification.Name(rawValue: "WBConversationChangeBackgroundImage"),
            object: nil,
            userInfo: ["conversationId": conversationId, "imageName": imageName])
    }

    private func readDicFromDisk() {
        let fileManger = FileManager.default
        let filePath = applicationDocumentDirectoryFile()

        let fileExist = fileManger.fileExists(atPath: filePath)
        if !fileExist {
            writeDicToDisk()
        } else {
            self.dictionary = NSMutableDictionary(contentsOfFile: filePath) ?? [:]
        }
    }

    private func writeDicToDisk() {
        self.dictionary.write(toFile: applicationDocumentDirectoryFile(), atomically: true)
    }

    private func applicationDocumentDirectoryFile() -> String {

        let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last
        let path = documentDirectory?.appendingPathComponent(fileName)
        return path ?? ""

    }

}
