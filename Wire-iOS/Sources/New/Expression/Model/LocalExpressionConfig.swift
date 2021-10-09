
import Foundation

class LocalExpressionConfig {
    
    static let data: LocalExpressionData = {
        let fileURL = Bundle.main.url(forResource: "expression", withExtension: "json")!
        let fileData = try! Data(contentsOf: fileURL)
        let decoder = JSONDecoder()
        let expression = try! decoder.decode(LocalExpressionData.self, from: fileData)
        return expression
    }()
    
}


struct LocalExpressionData: Decodable {
    let favoriteLimit: Int
    let recentLimit: Int
    let zipLimit: Int
}
