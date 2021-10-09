
import UIKit

final class VersionInfoViewController: UIViewController {

    private var closeButton: IconButton!
    private var versionInfoLabel: UILabel!
    private let componentsVersionsFilepath: String


    init(versionsPlist path: String = Bundle.main.path(forResource: "ComponentsVersions", ofType: "plist")!) {
        componentsVersionsFilepath = path

        super.init(nibName: nil, bundle: nil)
    }


    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.dynamic(scheme: .background)

        setupCloseButton()
        setupVersionInfo()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        updateStatusBar()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        updateStatusBar()
    }

    private func setupCloseButton() {
        closeButton = IconButton()
        view.addSubview(closeButton)

        //Cosmetics
        closeButton.setIcon(.cross, size: .small, for: UIControl.State.normal)
        closeButton.setIconColor(UIColor.black, for: UIControl.State.normal)

        //Layout
        closeButton.translatesAutoresizingMaskIntoConstraints = false

        closeButton.pinToSuperview(safely: true, anchor: .top, inset: 24)
        closeButton.pinToSuperview(safely: true, anchor: .trailing, inset: 18)

        //Target
        closeButton.addTarget(self, action: #selector(self.closeButtonTapped(_:)), for: .touchUpInside)
    }

    private func setupVersionInfo() {
        guard let versionsPlist = NSDictionary(contentsOfFile: componentsVersionsFilepath),
              let carthageInfo = versionsPlist["CarthageBuildInfo"] as? [String: String] else { return }


        versionInfoLabel = UILabel()
        versionInfoLabel.numberOfLines = 0
        versionInfoLabel.backgroundColor = UIColor.clear
        versionInfoLabel.textColor = UIColor.black
        versionInfoLabel.font = UIFont.systemFont(ofSize: 11)

        view.addSubview(versionInfoLabel)

        versionInfoLabel.translatesAutoresizingMaskIntoConstraints = false
        versionInfoLabel.fitInSuperview(with: EdgeInsets(top: 80, leading: 24, bottom: 24, trailing: 24))

        var versionString: String = ""

        let dictKeySorted = carthageInfo.sorted(by: <)

        for (dependency, version) in dictKeySorted {
            versionString += "\n\(dependency) \(version)"
        }

        versionInfoLabel.text = versionString
    }

    @objc
    private func closeButtonTapped(_ close: Any?) {
        dismiss(animated: true)
    }

    
}

