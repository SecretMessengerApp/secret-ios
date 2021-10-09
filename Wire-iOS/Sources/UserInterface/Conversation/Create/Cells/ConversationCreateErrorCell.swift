
import Foundation

class ConversationCreateErrorCell: UICollectionViewCell {
    
    let label = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    fileprivate func setup() {
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = FontSpec(.small, .semibold).font!
        label.textColor = .dynamic(scheme: .note)
        
        contentView.addSubview(label)
        label.fitInSuperview(with: EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
    }
}
