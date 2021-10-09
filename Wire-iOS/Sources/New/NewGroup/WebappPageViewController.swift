//
//  WebappPageViewController.swift
//  Wire-iOS
//
//  Created by 刘超 on 2019/6/24.
//  Copyright © 2019 Zeta Project Germany GmbH. All rights reserved.
//

import Foundation
import WebKit
import Cartography

protocol WebappPageViewControllerDataSource: class {
    func pageViewControllerGetViewControllers(_ pageViewController: WebappPageViewController) -> [UIViewController]
    func pageViewControllerGetCurrentIndex(_ pageViewController: WebappPageViewController) -> Int?
}

protocol WebappPageViewControllerDeleDelegate: class {
    func pageViewController(_ pageViewController: WebappPageViewController, totalCount: Int, didSelectIndex: Int, endDecelerating: Bool)
}

class WebappPageViewController: UIViewController {
    public var currentIndex: Int = 0
    public let scrollView: UIScrollView
    public var itemsCount: Int {
        return viewcontrollers.count
    }
    private var viewcontrollers: [UIViewController] = []
    private weak var dataSource: WebappPageViewControllerDataSource?
    private weak var delegate: WebappPageViewControllerDeleDelegate?
    private var frame: CGRect {
        return self.scrollView.frame
    }
    
    deinit {
        print("WebappPageViewController deinit")
    }
    
    init(dataSource: WebappPageViewControllerDataSource, delegate: WebappPageViewControllerDeleDelegate? = nil) {
        self.scrollView = UIScrollView()
        super.init(nibName: nil, bundle: nil)
        self.delegate = delegate
        self.dataSource = dataSource
        self.scrollView.isPagingEnabled = true
        self.scrollView.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        guard let datasoruce = self.dataSource else {return}
        viewcontrollers = datasoruce.pageViewControllerGetViewControllers(self)
        currentIndex = datasoruce.pageViewControllerGetCurrentIndex(self) ?? 0
        
        self.scrollView.contentSize = CGSize(width: self.frame.size.width * CGFloat(self.viewcontrollers.count), height: self.frame.size.height)
        self.view.addSubview(self.scrollView)
        constrain(scrollView, view) { (scrollView, view) in
            scrollView.edges == view.edges
        }
        
        self.addViewcontrollers()

        let dismissGestureRecognizer = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(onEdgeSwipe(gestureRecognizer:)))
        dismissGestureRecognizer.edges = [.left]
        dismissGestureRecognizer.delegate = self
        self.view.addGestureRecognizer(dismissGestureRecognizer)
    }
    
    @objc func onEdgeSwipe(gestureRecognizer: UIScreenEdgePanGestureRecognizer) {
        if let currentVC = viewcontrollers[self.currentIndex] as? LeftEdgeSwipeProtocol {
            self.scrollView.isScrollEnabled = currentVC.canResponseLeftEdgeSwipe(gestureRecognizer: gestureRecognizer)
        } else {
            self.scrollView.isScrollEnabled = true
        }
    }
    
    func addViewcontrollers() {
        for (index, vc) in viewcontrollers.enumerated() {
            self.addView(optionalVc: vc, index: index)
            self.addChild(vc)
        }
    }
    
    public func reload() {
        guard let datasource = self.dataSource else {return}
        viewcontrollers.forEach {
            $0.removeFromParent()
            $0.view.removeFromSuperview()
        }
        viewcontrollers = datasource.pageViewControllerGetViewControllers(self)
        currentIndex = datasource.pageViewControllerGetCurrentIndex(self) ?? currentIndex
        self.resetState()
        self.addViewcontrollers()
        self.respondsToDelegate()
    }
    
    public func scrollToIndex(toIndex: Int?) {
        guard let index = toIndex else {return}
        currentIndex = index
        self.resetState()
        self.respondsToDelegate(endDecelerating: true)
    }
    
    private func resetState() {
        self.scrollView.setContentOffset(CGPoint(x: CGFloat(currentIndex) * self.frame.size.width, y: 0), animated: true)
        delay(0.25) {
            self.scrollView.contentSize = CGSize(width: self.frame.size.width * CGFloat(self.viewcontrollers.count), height: self.frame.size.height)
            self.scrollView.setContentOffset(CGPoint(x: Int(self.frame.size.width) * self.currentIndex, y: 0), animated: false)
        }
    }
    
    private func respondsToDelegate(endDecelerating: Bool = false) {
        delegate?.pageViewController(self, totalCount: viewcontrollers.count, didSelectIndex: self.currentIndex, endDecelerating: endDecelerating)
    }
    
    private func addView(optionalVc: UIViewController?, index: Int) {
        guard let vc = optionalVc else {return}
        
        vc.view.tag = 100 + index
        self.scrollView.addSubview(vc.view)
        
        if let preView = self.scrollView.viewWithTag(100 + index - 1) {
            constrain(self.scrollView, preView, vc.view) { scrollView, preView, view in
                view.width == scrollView.width
                view.height == scrollView.height
                view.top == scrollView.top
                view.bottom == scrollView.bottom
                
                view.left == preView.right
                if index == viewcontrollers.count - 1 {
                    view.right == scrollView.right
                }
            }
        } else {
            constrain(self.scrollView, vc.view) { scrollView, view in
                view.width == scrollView.width
                view.height == scrollView.height
                view.top == scrollView.top
                view.bottom == scrollView.bottom

                view.left == scrollView.left
                if index == viewcontrollers.count - 1 {
                    view.right == scrollView.right
                }
            }
        }
        
    }
}

extension WebappPageViewController: UIScrollViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.currentIndex = Int(scrollView.contentOffset.x) / Int(scrollView.frame.size.width)
        self.respondsToDelegate(endDecelerating: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x > 0.01 {
            self.view.endEditing(true)
        }
    }
}

extension WebappPageViewController {
    func scrollTo(appid: String) {
        let index = self.viewcontrollers.firstIndex { (viewcontroller) -> Bool in
            if let webappcover = viewcontroller as? GroupConvPageAppConvertible {
                return webappcover.appID == appid
            }
            return false
        }
        guard let ind = index else {return}
        self.scrollToIndex(toIndex: ind)
    }
}

extension WebappPageViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
