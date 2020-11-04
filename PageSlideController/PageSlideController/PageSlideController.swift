//
//  PageSlideController.swift
//  PageSlideController
//
//  Created by Chen Yiliang on 2020/11/3.
//  Copyright © 2020 Chen Yiliang. All rights reserved.
//

import UIKit

@objc
public protocol PageSlideControllerDelegate {
    @objc
    optional func pageSlideController(_ slideController: PageSlideController, didSelectViewController viewController: UIViewController)
}

open class PageSlideController: UIViewController, UIScrollViewDelegate, PageSlideBarDataSource, PageSlideBarDelegate {
    
    private var _viewControllers: [UIViewController]?
    public var viewControllers: [UIViewController]? {
        get {
            return _viewControllers
        }
        set {
            _viewControllers = newValue
            
            self.updateContentSubviews()
            var selectedIndex = self.selectedIndex
            let count = newValue?.count ?? 0
            if selectedIndex > count {
                selectedIndex = 0
            }
            self.updateContentSubviews(selectedIndex: selectedIndex, changeOffset: true)
        }
    }
    
    public weak var selectedViewController: UIViewController? {
        get {
            var selectedViewController: UIViewController? = nil
            let count = self.viewControllers?.count ?? 0
            if self.selectedIndex < count {
                selectedViewController = self.viewControllers![self.selectedIndex]
            }
            return selectedViewController
        }
        set {
            guard let controller = newValue else {
                return
            }
            self.selectedIndex = self.viewControllers!.firstIndex(of: controller)!
        }
    }
    
    private var _selectedIndex: Int = 0
    public var selectedIndex: Int {
        get {
            return _selectedIndex
        }
        set {
            _selectedIndex = newValue
            
            if self.pageSlideBar.items != nil && self.pageSlideBar.items!.count > 0 {
                self.updateContentSubviews(selectedIndex: newValue, changeOffset: true)
            }
        }
    }
    
    @IBOutlet
    public var scrollView: PageSlideScrollView!
    
    @IBOutlet
    public var headerView: UIView!
    
    public var headerStickyHeight: CGFloat {
        var headerHeight: CGFloat = 0.0
        if self.headerView != nil {
            headerHeight = self.headerView.frame.height.rounded(.up)
        }
        return headerHeight
    }
    
    @IBOutlet
    public var pageSlideBar: PageSlideBar!
    
    public var pageSlideBarHeight: CGFloat = PageSlideBarHeight
    
    private var _pageSlideBarLayoutStyle: PageSlideBarLayoutStyle = .tite
    public var pageSlideBarLayoutStyle: PageSlideBarLayoutStyle {
        get {
            return _pageSlideBarLayoutStyle
        }
        set {
            _pageSlideBarLayoutStyle = newValue
            if self.pageSlideBar != nil {
                self.pageSlideBar.layoutStyle = newValue
            }
        }
    }
    
    @IBOutlet
    public var contentView: PageSlideContentView!
    
    public weak var delegate: PageSlideControllerDelegate?
    
    // MARK: - Lifecycle
    
    private func commonInit() {
        // do somethings...
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.commonInit()
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.commonInit()
    }
    
    public convenience init(viewControllers: [UIViewController], barLayoutStyle: PageSlideBarLayoutStyle) {
        self.init(nibName: nil, bundle: nil)
        
        _pageSlideBarLayoutStyle = barLayoutStyle
        _viewControllers = viewControllers
    }
    
    // MARK: - View Lifecycle

    open override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.scrollView == nil {
            let scrollView = PageSlideScrollView(frame: self.view.bounds)
            scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            scrollView.showsVerticalScrollIndicator = false
            scrollView.showsHorizontalScrollIndicator = false
            scrollView.alwaysBounceVertical = true
            
            self.scrollView = scrollView
            self.view.addSubview(scrollView)
        }
        
        var offsetY: CGFloat = 0.0
        if self.headerView != nil {
            var frame = self.headerView.frame
            frame.origin.x = 0.0
            frame.origin.y = 0.0
            self.headerView.frame = frame
            
            self.scrollView.addSubview(self.headerView)
            offsetY += frame.size.height
        }

        if self.pageSlideBar == nil {
            let pageSlideBar = PageSlideBar(layoutStyle: self.pageSlideBarLayoutStyle)
            pageSlideBar.autoresizingMask = [.flexibleWidth]
            pageSlideBar.dataSource = self
            pageSlideBar.delegate = self
            
            var frame = pageSlideBar.frame
            frame.origin.y = offsetY
            frame.size.width = self.view.frame.size.width
            frame.size.height = self.pageSlideBarHeight
            pageSlideBar.frame = frame
            
            self.pageSlideBar = pageSlideBar
            self.scrollView.addSubview(pageSlideBar)
            
            offsetY += frame.size.height
        }
        
        if self.contentView == nil {
            let contentView = PageSlideContentView(frame: .zero)
            contentView.showsVerticalScrollIndicator = false
            contentView.showsHorizontalScrollIndicator = false
            contentView.alwaysBounceVertical = false
            contentView.isPagingEnabled = true
            contentView.delegate = self
            
            var frame = contentView.frame
            frame.origin.y = offsetY
            frame.size.width = UIScreen.main.bounds.size.width
            frame.size.height = UIScreen.main.bounds.size.height - self.pageSlideBarHeight - topLayoutInset - bottomLayoutInset
            contentView.frame = frame
            
            self.contentView = contentView
            self.scrollView.addSubview(contentView)
            
            offsetY += frame.size.height
        }
        
        var contentSize = self.scrollView.contentSize
        contentSize.height = offsetY
        self.scrollView.contentSize = contentSize
        
        self.updateContentSubviews()
        self.updateContentSubviews(selectedIndex: self.selectedIndex, changeOffset: true)
    }
    
    private func updateContentSubviews() {
        if self.contentView == nil {
            return
        }
        
        if #available(iOS 11.0, *) {
            self.contentView.contentInsetAdjustmentBehavior = .never
        }
        
        for view in self.contentView.subviews {
            view.removeFromSuperview()
        }
        
        var barItems: [PageSlideBarItem] = []
        let controllerCount = self.viewControllers?.count ?? 0
        for i in 0..<controllerCount {
            let viewController = self.viewControllers![i]
            if viewController.pageSlideBarItem == nil {
                viewController.pageSlideBarItem = PageSlideBarItem(title: viewController.title, titleColor: nil, selectedTitleColor: nil)
            }
            barItems.append(viewController.pageSlideBarItem!)
            
            var frame = self.contentView.bounds
            frame.origin.x = CGFloat(i) * self.contentView.frame.size.width
            viewController.view.frame = frame
            viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            self.contentView.addSubview(viewController.view)
            
            self.addChild(viewController)
        }
        
        self.pageSlideBar.items = barItems
        var contentSize = self.contentView.contentSize
        contentSize.width = self.contentView.frame.size.width * CGFloat(controllerCount)
        self.contentView.contentSize = contentSize
        
        var gestureRecognizers: [UIGestureRecognizer] = []
        if let scrollGestureRecognizers = self.pageSlideBar.scrollView.gestureRecognizers {
            gestureRecognizers.append(contentsOf: scrollGestureRecognizers)
        }
        if let scrollGestureRecognizers = self.contentView.gestureRecognizers {
            gestureRecognizers.append(contentsOf: scrollGestureRecognizers)
        }
        self.scrollView.otherGestureRecognizers = gestureRecognizers
    }
    
    public func updateContentSubviews(selectedIndex: Int, changeOffset: Bool) {
        let count = self.viewControllers?.count ?? 0
        if selectedIndex < 0 || selectedIndex >= count {
            return
        }
        
        _selectedIndex = selectedIndex
        let viewController = self.viewControllers![selectedIndex]
        if self.pageSlideBar.selectedItem != viewController.pageSlideBarItem {
            if self.pageSlideBar.selectedItem != nil {
                let preSelectedIndex = self.pageSlideBar.items!.firstIndex(of: self.pageSlideBar.selectedItem!) ?? NSNotFound
                if preSelectedIndex < self.viewControllers!.count {
                    let preViewControler = self.viewControllers![preSelectedIndex]
                    preViewControler.viewDidDisappear(false)
                }
            }
            
            self.pageSlideBar.setSelectedItem(viewController.pageSlideBarItem, alwaysReset: false)
            viewController.viewWillAppear(false)
            
            self.delegate?.pageSlideController?(self, didSelectViewController: viewController)
        }
        
        if changeOffset {
            var contentOffset = self.contentView.contentOffset
            if contentOffset.x != CGFloat(selectedIndex) * self.contentView.frame.size.width {
                contentOffset.x = CGFloat(selectedIndex) * self.contentView.frame.size.width
                self.contentView.setContentOffset(contentOffset, animated: true)
            }
        }
    }
    
    // MARK: - UIScrollViewDelegate
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.isDecelerating == false && scrollView.isDragging == false {
            return
        }
        
        let indexF = scrollView.contentOffset.x / scrollView.frame.size.width
        let index = Int(indexF)
        if fabsf(Float(indexF - CGFloat(index))) <= 0.1 {
            self.updateContentSubviews(selectedIndex: index, changeOffset: false)
        }
    }
    
    // MARK: - PageSlideBarDelegate
    
    public func pageSlideBar(_ slideBar: PageSlideBar, didSelectItem item: PageSlideBarItem) {
        let index = self.pageSlideBar.items?.firstIndex(of: item) ?? 0
        self.updateContentSubviews(selectedIndex: index, changeOffset: true)
    }

}
