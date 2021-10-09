
import UIKit
import MapKit

class ConversationLocationMessageCell: UIView, ConversationMessageCell {

    struct Configuration {
        let location: LocationMessageData
        let message: ZMConversationMessage
        var isObfuscated: Bool {
            return message.isObfuscated
        }
    }
    private var messageBackgroundView = UIImageView()
    private var lastConfiguration: Configuration?

    private var mapView = MKMapView()
    private let containerView = UIView()
    private let obfuscationView = ObfuscationView(icon: .locationPin)
    private let addressContainerView = UIView()
    private let addressLabel = UILabel()
    private var recognizer: UITapGestureRecognizer?
    private weak var locationAnnotation: MKPointAnnotation? = nil
    
    weak var delegate: ConversationMessageCellDelegate? = nil
    weak var message: ZMConversationMessage? = nil

    var labelFont: UIFont? = .normalFont
    var labelTextColor: UIColor? = .dynamic(scheme: .title)
    var containerHeightConstraint: NSLayoutConstraint!

    var isSelected: Bool = false

    var selectionView: UIView? {
        return containerView
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureViews()
        createConstraints()
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureViews() {
        messageBackgroundView.isUserInteractionEnabled = true
        addSubview(messageBackgroundView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.layer.cornerRadius = 4
        containerView.clipsToBounds = true

        mapView.isScrollEnabled = false
        mapView.isZoomEnabled = false
        mapView.isRotateEnabled = false
        mapView.isPitchEnabled = false
        mapView.mapType = .standard
        mapView.showsPointsOfInterest = true
        mapView.showsBuildings = true
        mapView.isUserInteractionEnabled = false

        recognizer = UITapGestureRecognizer(target: self, action: #selector(openInMaps))
        containerView.addGestureRecognizer(recognizer!)
        messageBackgroundView.addSubview(containerView)
        [mapView, addressContainerView, obfuscationView].forEach(containerView.addSubview)
        addressContainerView.addSubview(addressLabel)
        obfuscationView.isHidden = true

        guard let font = labelFont, let color = labelTextColor else { return }
        addressLabel.font = font
        addressLabel.textColor = color
        addressContainerView.backgroundColor = .dynamic(scheme: .secondaryBackground)
    }

    private func createConstraints() {
        messageBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        containerView.translatesAutoresizingMaskIntoConstraints = false
        mapView.translatesAutoresizingMaskIntoConstraints = false
        obfuscationView.translatesAutoresizingMaskIntoConstraints = false
        addressContainerView.translatesAutoresizingMaskIntoConstraints = false
        addressLabel.translatesAutoresizingMaskIntoConstraints = false
        messageBackgroundView.fitInSuperview()
//        containerView.fitInSuperview()
        mapView.fitInSuperview()
        obfuscationView.fitInSuperview()

        NSLayoutConstraint.activate([
            // containerView
            containerView.heightAnchor.constraint(equalToConstant: 160),
            
            containerView.leadingAnchor.constraint(equalTo: messageBackgroundView.leadingAnchor, constant: 10),
            containerView.topAnchor.constraint(equalTo: messageBackgroundView.topAnchor, constant: 3),
            containerView.trailingAnchor.constraint(equalTo: messageBackgroundView.trailingAnchor, constant: -10),
            containerView.bottomAnchor.constraint(equalTo: messageBackgroundView.bottomAnchor, constant: -3),
            
            // addressContainerView
            addressContainerView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            addressContainerView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            addressContainerView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            addressContainerView.heightAnchor.constraint(equalToConstant: 42),

            // addressLabel
            addressLabel.leadingAnchor.constraint(equalTo: addressContainerView.leadingAnchor, constant: 12),
            addressLabel.topAnchor.constraint(equalTo: addressContainerView.topAnchor),
            addressLabel.trailingAnchor.constraint(equalTo: addressContainerView.trailingAnchor, constant: -12),
            addressLabel.bottomAnchor.constraint(equalTo: addressContainerView.bottomAnchor)
        ])
    }

    override func willMove(toSuperview newSuperview: UIView?) {
        if newSuperview == nil {
            locationAnnotation.map(mapView.removeAnnotation)
        }
    }

    func configure(with object: Configuration, animated: Bool) {
        lastConfiguration = object
        recognizer?.isEnabled = !object.isObfuscated
        obfuscationView.isHidden = !object.isObfuscated
        mapView.isHidden = object.isObfuscated
        
        /// messageBackgroundView
        let message = object.message
        let senderIsSelf = message.sender?.remoteIdentifier == ZMUser.selfUser()?.remoteIdentifier
        if senderIsSelf{
            messageBackgroundView.image = UIImage.init(named: MessageBackImage.mineWithTail.rawValue)
        }else{
            messageBackgroundView.image = UIImage.init(named: MessageBackImage.otherWithTail.rawValue)
        }

        if let address = object.location.name {
            addressContainerView.isHidden = false
            addressLabel.text = address
        } else {
            addressContainerView.isHidden = true
        }

        updateMapLocation(withLocationData: object.location)

        if let annotation = locationAnnotation {
            mapView.removeAnnotation(annotation)
        }

        let annotation = MKPointAnnotation()
        annotation.coordinate = object.location.coordinate
        mapView.addAnnotation(annotation)
        locationAnnotation = annotation
    }

    func updateMapLocation(withLocationData locationData: LocationMessageData) {
        if locationData.zoomLevel != 0 {
            mapView.setCenterCoordinate(locationData.coordinate, zoomLevel: Int(locationData.zoomLevel))
        } else {
            // As the zoom level is optional we use a viewport of 250m x 250m if none is specified
            let region = MKCoordinateRegion(center: locationData.coordinate, latitudinalMeters: 250, longitudinalMeters: 250)
            mapView.setRegion(region, animated: false)
        }
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        // The zoomLevel calculation depends on the frame of the mapView, so we need to call this here again
        guard let locationData = lastConfiguration?.location else { return }
        updateMapLocation(withLocationData: locationData)
    }

    @objc func openInMaps() {
        lastConfiguration?.location.openInMaps(with: mapView.region.span)
    }

}

class ConversationLocationMessageCellDescription: ConversationMessageCellDescription {
    typealias View = ConversationLocationMessageCell
    let configuration: View.Configuration

    var message: ZMConversationMessage?
    weak var delegate: ConversationMessageCellDelegate?     
    weak var actionController: ConversationMessageActionController?
    
    var showEphemeralTimer: Bool = false
    var topMargin: Float = 0

    let isFullWidth: Bool = false
    let supportsActions: Bool = true
    let containsHighlightableContent: Bool = true

    let accessibilityIdentifier: String? = nil
    let accessibilityLabel: String? = nil

    init(message: ZMConversationMessage, location: LocationMessageData) {
        configuration = View.Configuration(location: location, message: message)
    }
}
