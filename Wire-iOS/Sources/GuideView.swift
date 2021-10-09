

import UIKit

final class GuideView: UIView, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    private var imageNames = ["guide_1", "guide_2", "guide_3"]
    
    private let titles = [
        "Chat Encryption",
        "Instant Messaging",
        "Burn After Reading"
    ]
    
    private let subtitles = [
        "End to end chat encryption",
        "Real time calls and video",
        "After viewing, it disappears"
    ]
    
    private var collectionView: UICollectionView!
    private let pageControl = UIPageControl()
    
    private let startButton = UIButton()
    
    private var dataSource: [Item] = []

    init() {
        super.init(frame: .zero)
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .horizontal
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .dynamic(scheme: .background)
        collectionView.bounces = false
        collectionView.isPagingEnabled = true
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.registerCell(GuideCell.self)
        
        pageControl.pageIndicatorTintColor = .gray
        pageControl.currentPageIndicatorTintColor = .red
        
        startButton.layer.cornerRadius = 24
        startButton.setTitle("guide_page_start_title".localized, for: .normal)
        startButton.setTitleColor(.white, for: .normal)
        startButton.backgroundColor = .dynamic(scheme: .brand)
        startButton.titleLabel?.font = .systemFont(ofSize: 20)
        startButton.addTarget(self, action: #selector(startButtonClicked), for: .touchUpInside)
        startButton.isHidden = true
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        startButton.translatesAutoresizingMaskIntoConstraints = false
        [collectionView, startButton, pageControl].forEach(addSubview)
        
        NSLayoutConstraint.activate(
            [
                pageControl.centerXAnchor.constraint(equalTo: centerXAnchor),
                pageControl.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -48),
                
                startButton.bottomAnchor.constraint(equalTo: pageControl.topAnchor, constant: -8),
                startButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 32),
                startButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -32),
                startButton.heightAnchor.constraint(equalToConstant: 48)
            ] + collectionView.edgesToSuperviewEdges()
        )
        
        
        dataSource = zip(zip(imageNames, titles), subtitles).map { arg in
            let ((name, title), subtitle) = arg
            return Item(imageName: name, title: title, subtitle: subtitle)
        }
        
        pageControl.currentPage = 0
        pageControl.numberOfPages = dataSource.count
        collectionView.reloadData()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func startButtonClicked() {
        UIView.animate(withDuration: 0.3, animations: {
            self.alpha = 0
        }) { _ in
            NotificationCenter.default.post(name: .guideStartUsingNotificationName, object: nil)
            self.removeFromSuperview()
            if let window = UIApplication.shared.keyWindow {
                NewVersionInfoView.showIfNewVersionAvailable(onView: window)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueCell(GuideCell.self, for: indexPath)
        cell.item = dataSource[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        collectionView.frame.size
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let idx = Int(scrollView.contentOffset.x / scrollView.frame.width)
        pageControl.currentPage = idx
        startButton.isHidden = idx < 2
    }
}


private class GuideCell: UICollectionViewCell {
    
    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        titleLabel.font = .systemFont(ofSize: 20)
        titleLabel.textAlignment = .center
        titleLabel.textColor = .dynamic(scheme: .title)
        
        subtitleLabel.font = .systemFont(ofSize: 18)
        subtitleLabel.textAlignment = .center
        subtitleLabel.textColor = .dynamic(scheme: .subtitle)
        
        let views = [imageView, titleLabel, subtitleLabel]
        views.forEach(contentView.addSubview)
        
        views.prepareForLayout()
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 80),
            
            subtitleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 32),
        ])
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var item: Item? {
        didSet {
            guard let item = item else { return }
            imageView.image = UIImage(named: item.imageName)
            titleLabel.text = item.title
            subtitleLabel.text = item.subtitle
        }
    }
}


private struct Item {
    let imageName: String, title: String, subtitle: String
}
