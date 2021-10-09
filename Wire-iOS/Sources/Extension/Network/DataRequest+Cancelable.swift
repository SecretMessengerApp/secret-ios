//
//  DataRequest+Cancelable.swift
//  Wire-iOS
//


import Alamofire
import Ziphy

extension DataRequest: CancelableTask {
    
    public func cancel() {
        _ = super.cancel()
    }
}
