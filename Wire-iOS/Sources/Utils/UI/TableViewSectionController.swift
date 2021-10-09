

import UIKit

protocol TableViewDataSource: UITableViewDataSource, UITableViewDelegate {
    
    var isHidden: Bool { get }
    func prepareForUse(in tableView: UITableView?)
}


@objc protocol TableViewSectionControllerScrollViewDelegate {
    
    @objc optional func scrollViewDidScroll(_ scrollView: UIScrollView)
}


class TableViewSectionController: NSObject {
    
    weak var delegate: TableViewSectionControllerScrollViewDelegate? = nil
    
    var tableView: UITableView? = nil {
        didSet {
            tableView?.dataSource = self
            tableView?.delegate = self
        }
    }
    
    var sections: [TableViewDataSource] {
        didSet {
            sections.forEach {
                $0.prepareForUse(in: tableView)
            }
            
            tableView?.reloadData()
        }
    }
    
    var visibleSections: [TableViewDataSource] {
        return sections.filter { !$0.isHidden }
    }
    
    init(sections: [TableViewDataSource] = []) {
        self.sections = sections
    }
}


extension TableViewSectionController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return visibleSections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return visibleSections[section].tableView(tableView, numberOfRowsInSection: 0)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //print(visibleSections[indexPath.section])
        return visibleSections[indexPath.section].tableView(tableView, cellForRowAt: indexPath)
    }
}

extension TableViewSectionController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        visibleSections[indexPath.section].tableView?(tableView, didSelectRowAt: indexPath)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        visibleSections[indexPath.section].tableView?(tableView, didDeselectRowAt: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return visibleSections[indexPath.section].tableView?(tableView, heightForRowAt: indexPath) ?? 0
    }
}

extension TableViewSectionController {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        delegate?.scrollViewDidScroll?(scrollView)
    }
}
