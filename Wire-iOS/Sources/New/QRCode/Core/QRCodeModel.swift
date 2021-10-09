//
//  QRCodeModel.swift
//  Wire-iOS
//

import Foundation
import SwiftyJSON

struct QRCodeModel {

    var type: ModelType

    init(string: String) {

        if let url = URL(string: string) {
            if url.host == "u.isecret.im"{
                self.type = .newFriend(id: url.lastPathComponent)
            } else if url.host == "g.isecret.im" {
                if let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
                    let queryItems = components.queryItems,
                    let item = queryItems.first(where: { $0.name == "url" }),
                    let url = item.value {
                    self.type = .group(url: url)
                } else {
                    self.type = .unknown
                }
                
            } else if url.host == "l.isecret.im"{
                self.type = .login(id: url.lastPathComponent)
            } else if url.host == "login.isecret.im"{
                self.type = .h5Auth(code: url.lastPathComponent)
            } else {
                self.type = .unknown
            }
        } else { 
            if string.contains("?1001") {
                self.type = ModelType(type: "", id: "", url: "")
            } else {
                let json = JSON(string.data(using: .utf8)!)
                self.type = ModelType(
                    type: json["type"].stringValue,
                    id: json["userId"].string,
                    url: json["url"].string
                )
            }
        }
        
    }

    enum ModelType {
        case friend(id: String)
        case newFriend(id: String)
        case group(url: String)
        case login(id: String)
        case h5Auth(code: String)
        case unknown

        init(type: String, id: String?, url: String?) {
            switch type {
            case "2" where id != nil:
                self = .friend(id: id!)
            case "3" where url != nil:
                    self = .group(url: url!)
            default: self = .unknown
            }
        }
    }
}
