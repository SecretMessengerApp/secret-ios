
import Foundation

final class ServiceDetailView: UIView {
    private let serviceView: ServiceView
    private let descriptionTextView = UITextView()
    
    public let variant: ColorSchemeVariant
    
    public var service: Service {
        didSet {
            updateForService()
            serviceView.service = self.service
        }
    }
    
    init(service: Service, variant: ColorSchemeVariant) {
        self.service = service
        self.variant = variant
        self.serviceView = ServiceView(service: service, variant: variant)
        super.init(frame: .zero)

        [serviceView, descriptionTextView].forEach(addSubview)

        createConstraints()

        switch variant {
        case .dark:
            backgroundColor = .clear
        case .light:
            backgroundColor = .white
        }
        
        descriptionTextView.backgroundColor = .clear
        descriptionTextView.textContainerInset = .zero
        descriptionTextView.textColor = UIColor.dynamic(scheme: .title)
        descriptionTextView.font = FontSpec(.normal, .light).font
        descriptionTextView.isEditable = false
        updateForService()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func createConstraints() {
        [self, serviceView, descriptionTextView].forEach(){ $0.translatesAutoresizingMaskIntoConstraints = false }

        serviceView.fitInSuperview(exclude: [.bottom])

        descriptionTextView.fitInSuperview(exclude: [.top])


        NSLayoutConstraint.activate([
            descriptionTextView.topAnchor.constraint(equalTo: serviceView.bottomAnchor, constant: 16)])
    }

    private func updateForService() {
        descriptionTextView.text = service.serviceUserDetails?.serviceDescription
    }
}

final class ServiceView: UIView {
    private let logoView = UserImageView(size: .normal)
    private let nameLabel = UILabel()
    private let providerLabel = UILabel()

    public let variant: ColorSchemeVariant
    
    public var service: Service {
        didSet {
            updateForService()
        }
    }
    
    init(service: Service, variant: ColorSchemeVariant) {
        self.service = service
        self.variant = variant
        super.init(frame: .zero)
        [logoView, nameLabel, providerLabel].forEach(addSubview)

        createConstraints()


        backgroundColor = .clear
        
        nameLabel.font = FontSpec(.large, .regular).font
        nameLabel.textColor = UIColor.dynamic(scheme: .title)
        nameLabel.backgroundColor = .clear
        
        providerLabel.font = FontSpec(.medium, .regular).font
        providerLabel.textColor = UIColor.dynamic(scheme: .title)
        providerLabel.backgroundColor = .clear
        updateForService()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func createConstraints() {
        self.translatesAutoresizingMaskIntoConstraints = false
        logoView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        providerLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            // logoView
            logoView.leadingAnchor.constraint(equalTo: leadingAnchor),
            logoView.topAnchor.constraint(equalTo: topAnchor),
            logoView.bottomAnchor.constraint(equalTo: bottomAnchor),
            logoView.heightAnchor.constraint(equalToConstant: 80),

            // nameLabel
            nameLabel.leadingAnchor.constraint(equalTo: logoView.trailingAnchor, constant: 16),
            nameLabel.topAnchor.constraint(equalTo: topAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: trailingAnchor),

            // providerLabel
            providerLabel.leadingAnchor.constraint(equalTo: logoView.trailingAnchor, constant: 16),
            providerLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            providerLabel.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }

    private func updateForService() {
        logoView.user = service.serviceUser
        nameLabel.text = service.serviceUser.name
        providerLabel.text = service.provider?.name
    }
}
