

import Foundation
import Security
import CoreEncryption
import SwiftProtobuf
import WireSyncEngine

class AuthKeyHandler {
    
    static let shared = AuthKeyHandler()
    
    var nonce: Data?
    var newNonce: Data?
    var serverNonce: Data?
    var pq: String?
    var p: String?
    var q: String?
    
    var dhPublicKeyFingerprint: UInt64?
    var dhPublicKeyString: String?
    
    var encryptedData: Data?
    
    var serverPublicKeyFingerprints: [String]?
    var pems: [String] = []
    
    var g: Int32?
    var dhPrime: Data?
    var gA: Data?
    var b: Data?
    
    var tmpAesKey: Data?
    var tmpAesIv: Data?
    
    var retryId: Int32 = 0
    
    let authKeyProvider = AuthKeyEncryption.shared()
    
    var authKey: Data?
    var authKeyId: UInt64?
    
    func nonceData() -> Data? {
        var keyData = Data(count: 16)
        let result = keyData.withUnsafeMutableBytes {
            SecRandomCopyBytes(kSecRandomDefault, 32, $0.baseAddress!)
        }
        if result == errSecSuccess {
            return keyData
        } else {
            return nil
        }
    }
    
    func createAuthKeyIfNeed() {
        guard let context = ZMUserSession.shared()?.managedObjectContext else {
            return
        }
        if let client = ZMUser.selfUser(in: context).selfClient(), let authKey = client.authKey, let authKeyId = client.authKeyId {
            print("authKey: \(authKey), authKeyId: \(authKeyId)")
            return
        }
        self.sendReqPQ()
    }
    
    func sendReqPQ() {
        ProtobufRequestClient.shared.request(rqConvertible: ReqPQRequest()) { (result) in
            switch result {
            case .success(let serverRes):
                switch serverRes.content {
                case .resPq(let pq):
                    print("nonce:\(pq.nonce), server_nonce:\(pq.serverNonce), pq: \(pq.pq), key: \(pq.serverPublicKeyFingerprints)")
                    guard let reqDHData = self.createReqDHParams(respq: pq) else {
                        return
                    }
                    self.sendReqDHParams(data: reqDHData)
                default:
                    break
                }
            case .failure(let error):
                print("error: \(error)")
            }
        }
    }
    
    func sendReqDHParams(data: Data) {
        ProtobufRequestClient.shared.request(rqConvertible: ReqDHParamsRequest(data: data)) { (result) in
            switch result {
            case .success(let serverRes):
                switch serverRes.content {
                case .resDhparams(let params):
                    print("params nonce:\(params.nonce), params server_nonce:\(params.serverNonce), params encrypted_answer: \(params.encryptedAnswer)")
                    let bytes = [UInt8](params.encryptedAnswer)
                    print("dData.encryptedAnswer: \(bytes)")
                    guard let newNonce = self.newNonce else {
                        return
                    }
                    guard let serverNonce = self.serverNonce else {
                        return
                    }
                    self.tmpAesKey = self.authKeyProvider.tmpAesKey(newNonce, serverNonce: serverNonce)
                    self.tmpAesIv = self.authKeyProvider.tmpAesIv(newNonce, serverNonce: serverNonce)
                    guard let key = self.tmpAesKey, let iv = self.tmpAesIv else {
                        return
                    }
                    guard let dData = self.authKeyProvider.aesDecrypt(params.encryptedAnswer, key: key, iv: iv) else {
                        return
                    }
                    if let answer = try? EncryptedAnswer.init(serializedData: dData) {
                        guard let nextData = self.createReqClientDHParams(answer: answer) else {
                            return
                        }
                        self.sendReqClientDHParams(data: nextData)
                    }
                    
                default:
                    break
                }
            default:
                break
            }
        }
    }
    
    func sendReqClientDHParams(data: Data) {
        ProtobufRequestClient.shared.request(rqConvertible: ReqClientDHParamsRequest(data: data)) { (result) in
            switch result {
            case .success(let serverRes):
                switch serverRes.content {
                case .resDhgenOk(let ok):
                    print("resDhgenOk-- nonce: \(ok.nonce), serverNonce: \(ok.serverNonce), newNonceHash1: \(ok.newNonceHash1)")
                    guard let context = ZMUserSession.shared()?.managedObjectContext else {
                        return
                    }
                    guard let client = ZMUser.selfUser(in: context).selfClient() else {
                        return
                    }
                    ZMUserSession.shared()?.enqueueChanges {
                        if let authKey = self.authKey {
                            client.authKey = authKey
                        }
                        if let authKeyId = self.authKeyId {
                            client.authKeyId = authKeyId
                        }
                    }
                case .resDhgenRetry(let retry):
                    print("resDhgenRetry-- nonce: \(retry.nonce), serverNonce: \(retry.serverNonce), newNonceHash2: \(retry.newNonceHash2)")
                case .resDhgenFail(let fail):
                    print("resDhgenFail-- nonce: \(fail.nonce), serverNonce: \(fail.serverNonce), newNonceHash3: \(fail.newNonceHash3)")
                default:
                    break
                }
            case .failure(let error):
                print("sendReqClientDHParams error:\(error)")
            }
        }
    }
    
    // Converts a hexadecimal string to Data
    func hexToData(from hexStr: String) -> Data? {
        let bytes = self.bytes(from: hexStr)
        return Data(bytes)
    }

    // Convert hexadecimal string to [UInt8]
   func bytes(from hexStr: String) -> [UInt8] {
        assert(hexStr.count % 2 == 0, "The input string format is not correct. 8 bits represent one character")
        var bytes = [UInt8]()
        var sum = 0
        let intRange = 48...57
        let lowercaseRange = 97...102
        // The encoding range of uppercase A to F utF8
        let uppercasedRange = 65...70
        for (index, c) in hexStr.utf8CString.enumerated() {
            var intC = Int(c.byteSwapped)
            if intC == 0 {
                break
            } else if intRange.contains(intC) {
                intC -= 48
            } else if lowercaseRange.contains(intC) {
                intC -= 87
            } else if uppercasedRange.contains(intC) {
                intC -= 55
            } else {
                assertionFailure("The input string format is incorrect. Each character must be within 0 to 9, A to F, or a to f")
            }
            sum = sum * 16 + intC
            // Each two hexadecimal letters represents eight bits, or one byte
            if index % 2 != 0 {
                bytes.append(UInt8(sum))
                sum = 0
            }
        }
        return bytes
    }
    
    func createReqDHParams(respq: ResPQ) -> Data? {
        self.nonce = respq.nonce
        self.serverNonce = respq.serverNonce
        self.pq = respq.pq
        self.serverPublicKeyFingerprints = respq.serverPublicKeyFingerprints
        if let pqData = self.hexToData(from: respq.pq) {
            let pqarr = authKeyProvider.calculatePAndQ(pqData)
            if let p = pqarr[0] as? UInt64 {
                self.p = String(format: "%0X", p)
            }
            if let q = pqarr[1] as? UInt64 {
                self.q = String(format: "%0X", q)
            }
            print("p: \(String(describing: self.p)), q: \(String(describing: self.q))")
            self.newNonce = authKeyProvider.newNonce()
        }
        var innerData = PQInnerData()
        if let pq = self.pq {
            innerData.pq = pq
        }
        if let p = self.p {
            innerData.p = p
        }
        if let q = self.q {
            innerData.q = q
        }
        if let nonce = self.nonce {
            innerData.nonce = nonce
        }
        if let snonce = self.serverNonce {
            innerData.serverNonce = snonce
        }
        if let newNonce = self.newNonce {
            innerData.newNonce = newNonce
        }
        self.dhPublicKeyFingerprint = authKeyProvider.publicKeyFingerprint(from: respq.serverPublicKeyFingerprints)
        self.dhPublicKeyString = authKeyProvider.publicKeyString(from: respq.serverPublicKeyFingerprints)
        if let protoInnerData = try? innerData.serializedData(), let publicKey = self.dhPublicKeyString {
            let dataWithHash = authKeyProvider.data(withHash: protoInnerData)
            self.encryptedData = authKeyProvider.rsaEncrypt(withPublicKey: publicKey, data: dataWithHash)
        }
        var reqDHParams = ReqDHParams()
        if let nonce = self.nonce {
            reqDHParams.nonce = nonce
        }
        if let snonce = self.serverNonce {
            reqDHParams.serverNonce = snonce
        }
        if let p = self.p, let pdata = self.hexToData(from: p) {
            reqDHParams.p = pdata
        }
        if let q = self.q, let qdata = self.hexToData(from: q) {
            reqDHParams.q = qdata
        }
        if let finger = self.dhPublicKeyFingerprint {
            reqDHParams.publicKeyFingerprint = "\(finger)"
        }
        if let enData = self.encryptedData {
            reqDHParams.encryptedData = enData
        }
        var clientRq = ClientReq()
        clientRq.content = .reqDhparams(reqDHParams)
        
        if let resultData = try? clientRq.serializedData() {
            return resultData
        }
        return nil
    }
    
    func createReqClientDHParams(answer: EncryptedAnswer) -> Data? {
        print("EncryptedAnswer nonce:\(answer.nonce) servernonce: \(answer.serverNonce)  g: \(answer.g)  g_a: \(answer.gA), servertime: \(answer.serverTime),dh:\(answer.dhPrime)")
        assert(self.nonce == answer.nonce, "invalid DH nonce")
        assert(self.serverNonce == answer.serverNonce, "invalid DH server nonce")
        assert(self.authKeyProvider.checkIsSafeG(UInt32(answer.g)), "invalid DH g")
        assert(self.authKeyProvider.checkIsSafeGAOrB(answer.gA, dhPrime: answer.dhPrime), "invalid DH g_a")
        
        self.b = self.authKeyProvider.b()
        guard let b = self.b else {return nil}
        
        self.g = answer.g
        self.dhPrime = answer.dhPrime
        self.gA = answer.gA
        
        let gb = authKeyProvider.createG_B(withG: answer.g, b: b, prime: answer.dhPrime)
        //authKey
        self.authKey = self.authKeyProvider.createAuthKey(answer.gA, b: b, prime: answer.dhPrime)
        if let authk = self.authKey, let nonce = self.nonce, let serverNonce = self.serverNonce {
            self.authKeyId = self.authKeyProvider.createAuthId(authk, newNonce: nonce, serverNonce: serverNonce)
            print("authKey: \(authk), authKeyId: \(String(describing: self.authKeyId))")
        }
        var clientDHInnerData = ClientDHInnerData()
        guard let nonce = self.nonce else {
            return nil
        }
        guard let snonce = self.serverNonce else {
            return nil
        }
        clientDHInnerData.retryID = 0
        clientDHInnerData.gB = gb
        clientDHInnerData.nonce = nonce
        clientDHInnerData.serverNonce = snonce
        var clientDataWithHash: Data?
        if let innerBytes = try? clientDHInnerData.serializedData() {
            clientDataWithHash = authKeyProvider.createClientData(innerBytes)
        }
        guard let cDataWithHash = clientDataWithHash else {
            print("create clientDataWithHash fail")
            return nil
        }
        guard let key = self.tmpAesKey, let iv = self.tmpAesIv else {
            return nil
        }
        let encryptedClientData = self.authKeyProvider.aesEncrypt(cDataWithHash, key: key, iv: iv)
        guard let encrypted = encryptedClientData else {
            return nil
        }
        var reqClientDHParams = ReqClientDHParams()
        reqClientDHParams.nonce = nonce
        reqClientDHParams.serverNonce = snonce
        reqClientDHParams.encryptedData = encrypted
        var clientReq = ClientReq()
        clientReq.reqClientDhparams = reqClientDHParams
        if let result = try? clientReq.serializedData() {
            return result
        }
        return nil
    }
    
}
