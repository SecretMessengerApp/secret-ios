//
//  BaseModel.swift
//  Wire-iOS
//

import Foundation
import SwiftyJSON

public protocol Modelable {
    init(json: JSON)
}

public struct BaseModel<T> {
    var data: T?
    var code: Int
    var msg: String
}

extension BaseModel: Decodable where T: Decodable {}

extension BaseModel: Modelable where T: Modelable {
    
    public init(json: JSON) {
        data = T(json: json["data"])
        code = json["code"].intValue
        msg = json["msg"].stringValue
    }
}

extension Array: Modelable where Element: Modelable {
    
    public init(json: JSON) {
        self.init()
        self = json.array?.map { Element(json: $0) } ?? []
    }
}
