
import Foundation
import SwiftyJSON

let myFavoriteExpressionZipId = 10001
let myRecentExpressionZipId = 10002

let expressionFavoriteChangedNotificationName = NSNotification.Name("expressionFavoriteChanged")
let expressionRecentChangedNotificationName = NSNotification.Name("expressionRecentChanged")
let expressionZipsChangedNotificationName = NSNotification.Name("expressionZipsChanged")

public class ExpressionModel {
    
    static let shared = ExpressionModel()
    var data: ExpressionData? {
        didSet {
            self.configPath()
        }
    }
    
    init() {
        guard let localData = LocalExpressionStore.getExpression() else {return}
        data = ExpressionData(json: JSON(localData))
        self.configPath()
    }
    
    func configPath() {
        guard let da = data else {return}
        let path = da.path
        da.zips.forEach { zip in
            zip.icon = "\(path)\(zip.folder)/\(zip.icon)"
            zip.gifs.forEach { item in
                item.url = path + zip.folder + "/" + item.url
            }
        }
    }
    
    func getSecretExpressions() -> [ExpressionZip] {
        guard let da = data else {return []}
        return da.zips.filter {
                $0.isDefault
            }.sorted(by: { (z1, z2) -> Bool in
                return z1.id < z2.id
            })
    }
    
    func getMyExpressionZips() -> [ExpressionZip] {
        guard let da = data else {return []}
        let localZips = LocalExpressionStore.zip.getAllData()
        return da.zips.filter {
            LocalExpressionStore.zip.getAllData().contains(String($0.id))
            }.sorted(by: { (zip1, zip2) -> Bool in
                let index1 = localZips.firstIndex(of: "\(zip1.id)")
                let index2 = localZips.firstIndex(of: "\(zip2.id)")
                return index1 < index2
            })
    }
    
    func getNoMyExpressionZips() -> [ExpressionZip] {
        guard let da = data else {return []}
        return da.zips.filter {
            !LocalExpressionStore.zip.getAllData().contains(String($0.id))
            }.filter { !$0.isDefault }
    }
    
//    func getPopularExpression() -> [ExpressionZip] {
//        return getMyExpressionZips() + getNoMyExpressionZips()
//    }
    
    func getPopularExpression() -> [ExpressionZip] {
        guard let da = data else {return []}
        return da.zips
    }
    
    func getNotDefaultExpression() -> [ExpressionZip] {
        guard let da = data else {return []}
        return da.zips.filter { !$0.isDefault }
    }
    
    func getExpressionById(_ id: Int) -> ExpressionZip? {
        guard let da = data else {return nil}
        return da.zips.filter {
            $0.id == id
        }.first
    }
    
    func getExpressionZipById(_ url: String) -> ExpressionZip? {
        guard let da = data else {return nil}
        return da.zips.filter {
            $0.gifs.contains(where: { (item) -> Bool in
                return item.url == url
            })
        }.first
    }
    
    //url
    func getSingleExpressoionByUrl(_ url: String) -> ExpressionItem? {
        guard let da = data else { return nil }
        for zip in da.zips {
            for gif in zip.gifs {
                if gif.url == url {
                    return gif
                }
            }
        }
        return nil
    }
    
    func getAllExpressions() -> [ExpressionItem] {
        guard let da = data else { return [] }
        return da.zips.reduce([]) { (origin, zip) -> [ExpressionItem] in
            return origin + zip.gifs
        }
    }
    
    func shouldAdd(_ id: Int) -> Bool {
        if id == myFavoriteExpressionZipId || id == myRecentExpressionZipId {
            return false
        }
        if self.getSecretExpressions().contains(where: { (zip) -> Bool in
            return zip.id == id
        }) {
            return false
        }
        return !LocalExpressionStore.zip.getAllData().contains("\(id)")
    }
    
}

extension ExpressionModel {
    
    func removeObserver(_ target: Any) {
        NotificationCenter.default.removeObserver(target)
    }
    
    func postFavoriteExpressionChanged() {
        NotificationCenter.default.post(name: expressionFavoriteChangedNotificationName, object: nil)
    }
    
    func postRecentExpressionChanged() {
        NotificationCenter.default.post(name: expressionRecentChangedNotificationName, object: nil)
    }
    
    func postExpressionZipChanged() {
        NotificationCenter.default.post(name: expressionZipsChangedNotificationName, object: nil)
    }
    
    func addFavoriteExpressionChangedOberver(_ target: Any, selector: Selector) {
        NotificationCenter.default.addObserver(target, selector: selector, name: expressionFavoriteChangedNotificationName, object: nil)
    }
    
    func addRecentExpressionChangedOberver(_ target: Any, selector: Selector) {
        NotificationCenter.default.addObserver(target, selector: selector, name: expressionRecentChangedNotificationName, object: nil)
    }
    
    func addExpressionZipChangedOberver(_ target: Any, selector: Selector) {
        NotificationCenter.default.addObserver(target, selector: selector, name: expressionZipsChangedNotificationName, object: nil)
    }
    
}



class ExpressionData: Modelable {
    
    let name: String
    let version: String
    let path: String
    let zips: [ExpressionZip]
    
    required init(json: JSON) {
        self.name = json["Name"].stringValue
        self.version = json["Version"].stringValue
        self.path = json["Path"].stringValue
        self.zips = json["Zips"].arrayValue.map { ExpressionZip(json: $0)}
    }
}


class ExpressionZip: Modelable {
    let id: Int
    let name: String
    var icon: String
    var folder: String
    var isDefault: Bool
    var gifs: [ExpressionItem]
    var shouldAdd: Bool {
        return ExpressionModel.shared.shouldAdd(id)
    }
    
    var count: Int {
        return gifs.count
    }
    
    var hasAdded: Bool {
        return !shouldAdd
    }
    
    required init(json: JSON) {
        self.id = json["Id"].intValue
        self.name = json["Name"].stringValue
        self.icon = json["Icon"].stringValue
        self.folder = json["Folder"].stringValue
        self.isDefault = json["Default"].boolValue
        self.gifs = json["Emojis"].arrayValue.map { ExpressionItem(json: $0)}
        self.assembleOriginZip()
    }
    
    init(id: Int, name: String, icon: String = "", gifs: [String]) {
        self.id = id
        self.name = name
        self.icon = icon
        self.isDefault = false
        self.folder = ""
        self.gifs = gifs.map({(str) -> ExpressionItem in
            let expression = ExpressionItem(url: str)
            if let zip = ExpressionModel.shared.getExpressionZipById(str) {
                expression.originZip = zip
            }
            return expression
        })
        self.assembleBusiZip()
    }
    
    func assembleBusiZip() {
        let allExpressions = ExpressionModel.shared.getAllExpressions()
        self.gifs.forEach { [weak self] (item) in
            guard let self = self else {return}
            item.busiZip = self
        }
        self.gifs.forEach { (item) in
            if let e = allExpressions.filter({ (aitem) -> Bool in
                return aitem.url == item.url
            }).first {
                item.name = e.name
            }
        }
    }
    
    func assembleOriginZip() {
        self.gifs.forEach { [weak self] (item) in
            guard let self = self else {return}
            item.originZip = self
        }
    }
}

extension ExpressionZip: CustomDebugStringConvertible {
    var debugDescription: String {
        return "\(name)-\(id)"
    }
}

extension ExpressionZip {
    
    var shouldShowEdit: Bool {
        return self.id == myFavoriteExpressionZipId || self.id == myRecentExpressionZipId
    }
    
    var isFavorite: Bool {
        return id == myFavoriteExpressionZipId
    }
    
    var isNotFavorite: Bool {
        return id != myFavoriteExpressionZipId
    }
    
    var isRecent: Bool {
        return id == myRecentExpressionZipId
    }
    
}

class ExpressionItem: Modelable {
    
    var url: String // url
    var name: String //
    
    //zip
    var originZip: ExpressionZip?
    var busiZip: ExpressionZip?
    
    required init(json: JSON) {
        self.url = json["File"].stringValue
        self.name = json["Name"].stringValue
    }
    
    init(url: String, name: String = "") {
        self.url = url
        self.name = name
    }
    
    var canDelete: Bool {
        return isFavorite || isRecent
    }
    
    var isFavorite: Bool {
        return busiZip?.id == myFavoriteExpressionZipId
    }
    
    var isRecent: Bool {
        return busiZip?.id == myRecentExpressionZipId
    }
}
