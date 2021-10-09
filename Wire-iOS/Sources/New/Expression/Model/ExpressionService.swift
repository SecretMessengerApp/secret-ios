
import Foundation
import SwiftyJSON

class ExpressionService: NSObject {

    @objc class func getExpressions() {
        let path = API.Base.backend + API.Expression.expression
        let request = ZMTransportRequest(path: path, method: .methodGET, payload: nil, authentication: .needsAccess)
        request.addValue("application/json", forAdditionalHeaderField: "Content-Type")
        guard let context = ZMUserSession.shared()?.managedObjectContext else {return}
        request.add(ZMCompletionHandler(on: context, block: { (response) in
            guard let payload = response.payload else {return}
            guard let responsedic = payload.asDictionary() as? [String: Any] else {return}
            let responseJson = JSON(responsedic)
            guard responseJson["code"].intValue == 200 else {
                return
            }
            let data = ExpressionData(json: responseJson["data"])
            ExpressionModel.shared.data = data
            guard let saveData = responsedic["data"] as? [String: Any] else {return}
            LocalExpressionStore.saveExpression(saveData)
        }))
        SessionManager.shared?.activeUserSession?.transportSession.enqueueOneTime(request)
    }
    
    
}
