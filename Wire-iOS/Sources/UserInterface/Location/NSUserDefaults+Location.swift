

import Foundation

private let latitudeKey = "LastLocationLatitudeKey"
private let longitudeKey = "LastLocationLongitudeKey"
private let zoomLevelKey = "LastLocationZoomLevelKey"

public extension LocationData {

    func toDictionary() -> [String : Any] {
        return [
            latitudeKey: latitude,
            longitudeKey: longitude,
            zoomLevelKey: Int(zoomLevel)
        ]
    }

    static func locationData(fromDictionary dict: [String : Any]) -> LocationData? {
        guard let latitude = dict[latitudeKey],
            let longitude = dict[longitudeKey],
            let zoomLevel = dict[zoomLevelKey] as? Int else { return nil }
        
        let latitudeFloat: Float
        let longitudeFloat: Float
        
        if let latitudeFloatUnwrap = latitude as? Float,
            let longitudeFloatUnwrap = longitude as? Float {
            latitudeFloat = latitudeFloatUnwrap
            longitudeFloat = longitudeFloatUnwrap
        }
        else if let latitudeDoubleUnwrap = latitude as? Double,
                let longitudeDoubleUnwrap = longitude as? Double {
            latitudeFloat = Float(latitudeDoubleUnwrap)
            longitudeFloat = Float(longitudeDoubleUnwrap)
        }
        else {
            return nil
        }
        
        return .locationData(withLatitude: latitudeFloat, longitude: longitudeFloat, name: nil, zoomLevel: Int32(zoomLevel))
    }
    
}
