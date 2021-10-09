

import Foundation
import MapKit
import Contacts

public extension Message {
    @objc class func openInMaps(_ messageData: LocationMessageData) {
        messageData.openInMaps(with: MKCoordinateSpan(zoomLevel: Int(messageData.zoomLevel), viewSize: Float(UIScreen.main.bounds.height)))
    }
}

public extension LocationMessageData {
    
    func openInMaps(with span: MKCoordinateSpan) {
        let launchOptions = [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: coordinate),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: span)
        ]
        
        if let url = googleMapsURL, url.openAsLocation() {
            return
        }
        
        mapItem?.openInMaps(launchOptions: launchOptions)
    }
    
    var googleMapsURL: URL? {
        let location = "\(coordinate.latitude),\(coordinate.longitude)"
        return URL(string: "comgooglemaps://?q=\(location)&center=\(location)&zoom=\(zoomLevel)")
    }
    
    var mapItem: MKMapItem? {
        var addressDictionary: [String : AnyObject]? = nil
        if let name = name {
            addressDictionary = [CNPostalAddressStreetKey: name as AnyObject]
        }
        
        let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: addressDictionary)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = name
        return mapItem
    }
}
