//
//  File.swift
//  Wire-iOS
//

import UIKit

// MARK: ConversationRootViewControllerExpandDelegate
protocol ConversationRootViewControllerExpandDelegate: AnyObject {
    func shouldExpand()
    func shouldUnexpand()
}

extension ConversationViewController {
    
    func createNavBarContainer() {
        self.navBarContainer = UINavigationBarContainer(DefaultNavigationBar())
        self.addToSelf(self.navBarContainer)
        self.navBarContainer.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.navBarContainer.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.navBarContainer.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.navBarContainer.view.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.navBarContainer.view.bottomAnchor.constraint(equalTo: self.view.safeTopAnchor, constant: 44)
        ])
        self.navBarContainer.navigationBar.pushItem(self.navigationItem, animated: false)
    }

}


extension ConversationViewController {
    
    @objc func backButtonPressed() {
        openConversationList()
    }
}
