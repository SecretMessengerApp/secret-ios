

import Foundation
import Cartography

class FingerprintTableViewCell: UITableViewCell {

    let fingerprintLabel = CopyableLabel()
    let spinner = UIActivityIndicatorView(style: .gray)

    var fingerprintLabelFont: UIFont? {
        didSet {
            self.updateFingerprint()
        }
    }
    var fingerprintLabelBoldFont: UIFont? {
        didSet {
            self.updateFingerprint()
        }
    }
    
    var fingerprint: Data? {
        didSet {
            self.updateFingerprint()
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        self.fingerprintLabel.numberOfLines = 0
        self.fingerprintLabel.accessibilityIdentifier = "fingerprint"
        self.spinner.hidesWhenStopped = true
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        
        contentView.addSubview(fingerprintLabel)
        contentView.addSubview(spinner)
        
        constrain(self.contentView, self.fingerprintLabel, self.spinner) { contentView, fingerprintLabel, spinner in
            
            fingerprintLabel.top == contentView.top + 16
            fingerprintLabel.left == contentView.left + 16
            fingerprintLabel.right == contentView.right - 16
            fingerprintLabel.bottom == contentView.bottom - 16
            
            spinner.centerX == contentView.centerX
            spinner.bottom <= contentView.bottom - 16
        }

        contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: 56).isActive = true
        
        backgroundColor = .dynamic(scheme: .cellBackground)
        backgroundView = UIView()
        selectedBackgroundView = UIView()

        setupStyle()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupStyle() {
        fingerprintLabelFont = .normalLightFont
        fingerprintLabelBoldFont = .normalSemiboldFont
    }

    func updateFingerprint() {

        if let fingerprintLabelBoldMonoFont = self.fingerprintLabelBoldFont?.monospaced(),
            let fingerprintLabelMonoFont = self.fingerprintLabelFont?.monospaced(),
            let attributedFingerprint = self.fingerprint?.attributedFingerprint(
                attributes: [.font: fingerprintLabelMonoFont, .foregroundColor: fingerprintLabel.textColor],
                boldAttributes: [.font: fingerprintLabelBoldMonoFont, .foregroundColor: fingerprintLabel.textColor],
                uppercase: false) {
                
                    self.fingerprintLabel.attributedText = attributedFingerprint
                    self.spinner.stopAnimating()
        }
        else {
            self.fingerprintLabel.attributedText = .none
            self.spinner.startAnimating()
        }
        self.layoutIfNeeded()
    }
}
