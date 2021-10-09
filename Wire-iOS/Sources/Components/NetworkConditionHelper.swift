

import Foundation
import CoreTelephony

enum NetworkQualityType: Int, Comparable {
    case unknown = 0
    case type2G
    case type3G
    case type4G
    case typeWifi

    static func < (lhs: NetworkQualityType, rhs: NetworkQualityType) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}

final class NetworkConditionHelper {

    static var shared: NetworkConditionHelper = {
        return NetworkConditionHelper()
    }()

    let networkInfo: CTTelephonyNetworkInfo

    init() {
        networkInfo = CTTelephonyNetworkInfo()
    }

    func qualityType() -> NetworkQualityType {
        let serverConnection = SessionManager.shared?.serverConnection

        if serverConnection?.isOffline == true {
            return .unknown
        } else if serverConnection?.isMobileConnection == false {
            return .typeWifi
        }

        if #available(iOS 12, *) {
            return bestQualityType(cellularTypeDict: networkInfo.serviceCurrentRadioAccessTechnology)
        } else {
            return qualityType(from: networkInfo.currentRadioAccessTechnology)
        }
    }

    func bestQualityType(cellularTypeDict: [String : String]?) -> NetworkQualityType {

        guard let cellularTypeDict = cellularTypeDict else { return .unknown }

        return cellularTypeDict.values.map { cellularTypeString in
            self.qualityType(from: cellularTypeString)}.sorted().last ?? .unknown
    }

    private func qualityType(from cellularTypeString: String?) -> NetworkQualityType {
        switch cellularTypeString {
            case CTRadioAccessTechnologyGPRS,
                 CTRadioAccessTechnologyEdge,
                 CTRadioAccessTechnologyCDMA1x:
            return .type2G

            case CTRadioAccessTechnologyWCDMA,
                 CTRadioAccessTechnologyHSDPA,
                 CTRadioAccessTechnologyHSUPA,
                 CTRadioAccessTechnologyCDMAEVDORev0,
                 CTRadioAccessTechnologyCDMAEVDORevA,
                 CTRadioAccessTechnologyCDMAEVDORevB,
                 CTRadioAccessTechnologyeHRPD:
                return .type3G
            case CTRadioAccessTechnologyLTE:
                return .type4G
            default:
                return .unknown
        }
    }
}
