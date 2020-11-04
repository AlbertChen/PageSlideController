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
            
            updateContentSubviews()
            var selectedIndex = self.selectedIndex
            let count = newValue?.count ?? 0
            if selectedIndex > count {
                selectedIndex = 0
            }
            updateContentSubviews(selectedIndex: selectedIndex, changeOffset: true)
        }
    }
    
    public weak var selectedViewController: UIViewController? {
        get {
            var selectedViewController: UIViewController? = nil
            let count = viewControllers?.count ?? 0
            if selectedIndex < count {
                selectedViewController = viewControllers![selectedIndex]
            }
            return selectedViewController
        }
        set {
            guard let controller = newValue else {
                return
            }
            selectedIndex = viewControllers!.firstIndex(of: controller)!
        }
    }
    
    private var _selectedIndex: Int = 0
    public var selectedIndex: Int {
        get {
            return _selectedIndex
        }
        set {
            _selectedIndex = newValue
            
            if pageSlideBar.items != nil && pageSlideBar.items!.count > 0 {
                updateContentSubviews(selectedIndex: newValue, changeOffset: true)
            }
        }
    }
    
    // MARK: -
    
    public var scrollView: PageSlideScrollView!
    
    @IBOutlet
    public var headerView: UIView!
    
    public var headerStickyHeight: CGFloat {
        var headerHeight: CGFloat = 0.0
        if headerView != nil {
            headerHeight = headerView.frame.height.rounded(.up)
        }
        return headerHeight
    }
    
    public var pageSlideBar: PageSlideBar!
    
    public var pageSlideBarHeight: CGFloat = PageSlideBarHeight
    
    private var _pageSlideBarLayoutStyle: PageSlideBarLayoutStyle = .tite
    public var pageSlideBarLayoutStyle: PageSlideBarLayoutStyle {
        get {
            return _pageSlideBarLayoutStyle
        }
        set {
            _pageSlideBarLayoutStyle = newValue
            if pageSlideBar != nil {
                pageSlideBar.layoutStyle = newValue
            }
        }
    }
    
    public var contentView: PageSlideContentView!
    
    // MARK: -
    
    public weak var delegate: PageSlideControllerDelegate?
    
    private var parentKeyValueObservation: NSKeyValueObservation?
    private var childKeyValueObservation: NSKeyValueObservation?
    private var canParentViewScroll: Bool = true
    private var canChildViewScroll: Bool = false
    
    // MARK: - Lifecycle
    
    public convenience init(viewControllers: [UIViewController], barLayoutStyle: PageSlideBarLayoutStyle) {
        self.init(nibName: nil, bundle: nil)
        
        _pageSlideBarLayoutStyle = barLayoutStyle
        _viewControllers = viewControllers
    }
    
    deinit {
        parentKeyValueObservation?.invalidate()
        childKeyValueObservation?.invalidate()
    }
    
    // MARK: - View Lifecycle

    open override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSubView()
        observeScrollViewContentOffset()
        updateContentSubviews()
        updateContentSubviews(selectedIndex: selectedIndex, changeOffset: true)
    }
    
    private func setupSubView() {
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
        
        var gestureRecognizers: [UIGestureRecognizer] = []
        if let scrollGestureRecognizers = self.pageSlideBar.scrollView.gestureRecognizers {
            gestureRecognizers.append(contentsOf: scrollGestureRecognizers)
        }
        if let scrollGestureRecognizers = self.contentView.gestureRecognizers {
            gestureRecognizers.append(contentsOf: scrollGestureRecognizers)
        }
        self.scrollView.otherGestureRecognizers = gestureRecognizers
    }
    
    private func updateContentSubviews() {
        if contentView == nil {
            return
        }
        
        if #available(iOS 11.0, *) {
            contentView.contentInsetAdjustmentBehavior = .never
        }
        
        for view in contentView.subviews {
            view.removeFromSuperview()
        }
        
        var barItems: [PageSlideBarItem] = []
        let controllerCount = viewControllers?.count ?? 0
        for i in 0..<controllerCount {
            let viewController = viewControllers![i]
            if viewController.pageSlideBarItem == nil {
                viewController.pageSlideBarItem = PageSlideBarItem(title: viewController.title, titleColor: nil, selectedTitleColor: nil)
            }
            barItems.append(viewController.pageSlideBarItem!)
            
            var frame = contentView.bounds
            frame.origin.x = CGFloat(i) * contentView.frame.size.width
            viewController.view.frame = frame
            viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            contentView.addSubview(viewController.view)
            
            addChild(viewController)
        }
        
        pageSlideBar.items = barItems
        var contentSize = contentView.contentSize
        contentSize.width = contentView.frame.size.width * CGFloat(controllerCount)
        contentView.contentSize = contentSize
    }
    
    public func updateContentSubviews(selectedIndex: Int, changeOffset: Bool) {
        let count = viewControllers?.count ?? 0
        if selectedIndex < 0 || selectedIndex >= count {
            return
        }
        
        _selectedIndex = selectedIndex
        let viewController = viewControllers![selectedIndex]
        if pageSlideBar.selectedItem != viewController.pageSlideBarItem {
            if pageSlideBar.selectedItem != nil {
                let preSelectedIndex = pageSlideBar.items!.firstIndex(of: pageSlideBar.selectedItem!) ?? NSNotFound
                if preSelectedIndex < viewControllers!.count {
                    let preViewControler = viewControllers![preSelectedIndex]
                    preViewControler.viewDidDisappear(false)
                }
            }
            
            childKeyValueObservation?.invalidate()
            
            pageSlideBar.setSelectedItem(viewController.pageSlideBarItem, alwaysReset: false)
            viewController.viewWillAppear(false)
            
            if let contentViewDelegate = viewController as? PageSlideContentViewDelegate,
                let scrollView = contentViewDelegate.scrollView {
                let keyValueObservation = scrollView?.observe(\.contentOffset, options: [.new, .old], changeHandler: { [weak self] (scrollView, change) in
                    guard let self = self else {
                        return
                    }
                    guard change.newValue != change.oldValue else {
                        return
                    }
                    self.childScrollViewDidScroll(scrollView)
                })
                childKeyValueObservation = keyValueObservation
            }
            
            delegate?.pageSlideController?(self, didSelectViewController: viewController)
        }
        
        if changeOffset {
            var contentOffset = contentView.contentOffset
            if contentOffset.x != CGFloat(selectedIndex) * contentView.frame.size.width {
                contentOffset.x = CGFloat(selectedIndex) * contentView.frame.size.width
                contentView.setContentOffset(contentOffset, animated: true)
            }
        }
    }
    
    // MARK: - UI Events
    
    private func observeScrollViewContentOffset() {
        parentKeyValueObservation = scrollView.observe(\.contentOffset, options: [.initial, .new, .old], changeHandler: { [weak self] (scrollView, change) in
            guard let self = self else {
                return
            }
            guard change.newValue != change.oldValue else {
                return
            }
            self.parentScrollViewDidScroll(scrollView)
        })
    }
    
    private func parentScrollViewDidScroll(_ parentScrollView: UIScrollView) {
        let parentContentOffsetY = scrollView.contentOffset.y
        if !canParentViewScroll {
            scrollView.contentOffset.y = headerStickyHeight
            canChildViewScroll = true
            return
        } else if parentContentOffsetY >= headerStickyHeight {
            scrollView.contentOffset.y = headerStickyHeight
            canParentViewScroll = false
            canChildViewScroll = true
            return
        }
        resetChildViewControllerContentOffsetY()
    }
    
    private func childScrollViewDidScroll(_ childScrollView: UIScrollView) {
        let childContentOffsetY = childScrollView.contentOffset.y
        if !canChildViewScroll {
            childScrollView.contentOffset.y = 0
        } else if childContentOffsetY <= 0 {
            canChildViewScroll = false
            canParentViewScroll = true
        }
    }
    
    private func resetChildViewControllerContentOffsetY() {
        guard scrollView.contentOffset.y < headerStickyHeight, let viewControllers = viewControllers else {
            return
        }

        for viewController in viewControllers {
            if let contentViewDelegate = viewController as? PageSlideContentViewDelegate,
                let scrollView = contentViewDelegate.scrollView {
                if scrollView?.contentOffset.y != 0.0 {
                    scrollView?.contentOffset.y = 0.0
                }
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
            updateContentSubviews(selectedIndex: index, changeOffset: false)
        }
    }
    
    // MARK: - PageSlideBarDelegate
    
    public func pageSlideBar(_ slideBar: PageSlideBar, didSelectItem item: PageSlideBarItem) {
        let index = pageSlideBar.items?.firstIndex(of: item) ?? 0
        updateContentSubviews(selectedIndex: index, changeOffset: true)
    }

}
