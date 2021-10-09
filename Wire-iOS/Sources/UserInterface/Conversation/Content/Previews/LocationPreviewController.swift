
import UIKit
import MapKit
import Cartography

/// Displays the preview of a location message.
class LocationPreviewController: TintColorCorrectedViewController {

    let message: ZMConversationMessage
    private var actionController: ConversationMessageActionController!

    private var mapView = MKMapView()
    private let containerView = UIView()
    private let addressContainerView = UIView()
    private let addressLabel = UILabel()

    let labelFont = UIFont.normalFont
    let labelTextColor = UIColor.dynamic(scheme: .title)
    let containerColor = UIColor.from(scheme: .placeholderBackground)

    // MARK: - Initialization

    init(message: ZMConversationMessage, actionResponder: MessageActionResponder) {
        self.message = message
        super.init(nibName: nil, bundle: nil)
        actionController = ConversationMessageActionController(responder: actionResponder, message: message, context: .content, view: view)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = .from(scheme: .placeholderBackground)

        configureViews()
        createConstraints()
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configuration

    private func configureViews() {
        mapView.isScrollEnabled = false
        mapView.isZoomEnabled = false
        mapView.isRotateEnabled = false
        mapView.isPitchEnabled = false
        mapView.mapType = .standard
        mapView.showsPointsOfInterest = true
        mapView.showsBuildings = true
        mapView.isUserInteractionEnabled = false

        view.addSubview(containerView)
        [mapView, addressContainerView].forEach(containerView.addSubview)
        addressContainerView.addSubview(addressLabel)

        guard let locationData = message.locationMessageData else { return }

        if let address = locationData.name {
            addressContainerView.isHidden = false
            addressLabel.text = address
            addressLabel.numberOfLines = 0
        } else {
            addressContainerView.isHidden = true
        }

        updateMapLocation(withLocationData: locationData)

        let annotation = MKPointAnnotation()
        annotation.coordinate = locationData.coordinate
        mapView.addAnnotation(annotation)

        addressLabel.font = labelFont
        addressLabel.textColor = labelTextColor
        addressContainerView.backgroundColor = containerColor
    }

    private func createConstraints() {
        constrain(view, containerView, mapView) { contentView, container, mapView in
            container.edges == contentView.edges
            mapView.edges == container.edges
        }

        constrain(containerView, addressContainerView, addressLabel) { container, addressContainer, addressLabel in
            addressContainer.left == container.left
            addressContainer.bottom == container.bottom
            addressContainer.right == container.right
            addressContainer.top == addressLabel.top - 12
            addressLabel.bottom == addressContainer.bottom - 12
            addressLabel.left == addressContainer.left + 12
            addressLabel.right == addressContainer.right - 12
        }
    }

    // MARK: - Map

    func updateMapLocation(withLocationData locationData: LocationMessageData) {
        let region: MKCoordinateRegion
        let coor = locationData.coordinate
        if locationData.zoomLevel != 0 {
            let span = MKCoordinateSpan(zoomLevel: Int(locationData.zoomLevel), viewSize: Float(view.frame.size.height))
            region = MKCoordinateRegion(center: coor, span: span)
        } else {
            region = MKCoordinateRegion(center: coor, latitudinalMeters: 250, longitudinalMeters: 250)
        }

        mapView.setRegion(region, animated: false)
    }

    // MARK: - Preview

    override var previewActionItems: [UIPreviewActionItem] {
        return actionController.makePreviewActions()
    }

}
