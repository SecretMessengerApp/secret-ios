//
//  NetworkError.swift
//  Wire-iOS
//
import Foundation

struct NetworkError {

    fileprivate private(set) var msg: String = ""
    var code: Int
    let data: [String: Any]?
    
    /// - parameter path: url path
    /// - parameter code: network code
    init(path: String?, code: Int, data: [String: Any]? = nil) {
        self.code = code
        self.data = data
        guard var path = path else {
            self.msg = "secret_unknown_error".localized
            return
        }
        // TODO:
        if path.contains("join_invite") || path.contains("member_join_confirm") { path = "join_invite" }
        if path.contains("judge/conversations") { path = "judge" }

        switch path {
        case API.H5Auth.accept:
            self.msg = "hud.error.invalid.qrcode".localized
            
        case "join_invite":
            let target = "join_invite_response_error_code_\(code)"
            self.msg = localized(target)
            
        case "judge":
            let target = "conversation.group.report.response.error.\(code)"
            self.msg = localized(target)
            
        default:
            if let msg = data?["msg"] as? String {
                self.msg = msg
            } else {
                self.msg = "secret_unknown_error".localized
            }
        }
    }

    private func localized(_ key: String) -> String {
        let value = "secret_unknown_error".localized
        return NSLocalizedString(key, tableName: nil,
                                 bundle: Bundle.main,
                                 value: value, comment: "")
    }
}

extension NetworkError: Error {}

extension NetworkError: LocalizedError {
    var errorDescription: String? {
        return localizedDescription
    }
}

extension NetworkError {
    var localizedDescription: String {
        return self.msg
    }
}
