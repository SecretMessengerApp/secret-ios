//
//  GroupDetailsViewController+Update.swift
//  Wire-iOS
//
import Foundation

extension GroupDetailsViewController: ProfileSelfPictureViewControllerDelegate {
    
    func profileSelfPictureViewController(_ controller: ProfileSelfPictureViewController, didUpdateImageData data: Data?) {
        guard let cid = conversation.remoteIdentifier?.transportString(), let data = data else { return }
        ZMUserSession.shared()?.converastionAvatarUpdate.updateImage(with: cid, imageData: data)
    }
    
    func getInviteUrl(_ done: @escaping (() -> Void)) {
        guard /*self.conversation.joinGroupUrl == nil || self.conversation.joinGroupUrl == "",*/
            let cnvid = self.conversation.remoteIdentifier?.transportString() else { return }
        GroupManageService.innviteUrl(id: cnvid) { (result) in
            if case let .success(value) = result {
                ZMUserSession.shared()?.enqueueChanges({
                    self.conversation.joinGroupUrl = value
                }, completionHandler: {
                    done()
                })
            }
        }
    }
}
