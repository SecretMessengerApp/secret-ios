

import Foundation
import SwiftyJSON

class TranslationService: NetworkRequest {
    
    class func translate(text: String, completion: @escaping (BaseResult<String?, String>) -> Void) {
        let path = API.Base.backend + API.Translation.translate
        let targetLang = Language.localLanguageRemoveHans()
        let texts = [text]
        request(
            path,
            method: .post,
            parameters: [
                "target_lang": targetLang,
                "text": texts
            ],
            encoding: .json(.default)
        ).responseDataErrorBeLocalized { (response) in
            switch response.result {
            case .success(let data):
                if let text = JSON(data)["data"].arrayValue.first?.stringValue {
                    completion(.success(text))
                    return
                }
                completion(.success(nil))
            case .failure(let err): completion(.failure(err.localizedDescription))
            }
        }
    }
    
}
