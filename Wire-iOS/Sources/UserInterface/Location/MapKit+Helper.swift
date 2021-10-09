

import MapKit

extension CLLocationCoordinate2D {
    
    var location: CLLocation {
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
}

extension CLPlacemark {
    
    func formattedAddress(_ includeCountry: Bool) -> String? {
        let lines: [String]?
        
        if #available(iOS 11.0, *) {
            lines = [subThoroughfare, thoroughfare, locality, subLocality, administrativeArea, postalCode, country].compactMap { $0 }
            
        } else {
            lines = addressDictionary?["FormattedAddressLines"] as? [String]
        }
        
        return includeCountry ? lines?.joined(separator: ", ") : lines?.dropLast().joined(separator: ", ")
    }
    
}

extension MKMapView {
    
    var zoomLevel: Int {
        get {
            let float = log2(360 * (Double(frame.height / 256) / region.span.longitudeDelta))
            // MKMapView does not like NaN and Infinity, so we return 16 as a default, as 0 would represent the whole world
            guard float.isNormal else { return 16 }
            return Int(float)
        }
        
        set {
            setCenterCoordinate(centerCoordinate, zoomLevel: newValue)
        }
    }
    
    func setCenterCoordinate(_ coordinate: CLLocationCoordinate2D, zoomLevel: Int, animated: Bool = false) {
        guard CLLocationCoordinate2DIsValid(coordinate) else { return }
        let region = MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(zoomLevel: zoomLevel, viewSize: Float(frame.height)))
        setRegion(region, animated: animated)
    }

}

extension MKCoordinateSpan {
    init(zoomLevel: Int, viewSize: Float) {
        self.init(latitudeDelta: min(360 / pow(2, Double(zoomLevel)) * Double(viewSize) / 256, 180), longitudeDelta: 0)
    }
}

extension LocationData {

    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: CLLocationDegrees(latitude), longitude: CLLocationDegrees(longitude))
    }

}

extension MKMapView {
    
    func locationData(name: String?) -> LocationData {
        return .locationData(
            withLatitude: Float(centerCoordinate.latitude),
            longitude: Float(centerCoordinate.longitude),
            name: name,
            zoomLevel: Int32(zoomLevel)
        )
    }
    
    func storeLocation() {
        let location: LocationData = locationData(name: nil)
        Settings.shared[.lastUserLocation] = location
    }
    
    func restoreLocation(animated: Bool) {
        guard let location: LocationData = Settings.shared[.lastUserLocation] else { return }
        setCenterCoordinate(location.coordinate, zoomLevel: Int(location.zoomLevel), animated: animated)
    }
    
}
