//
//  PageSlideBar.swift
//  PageSlideController
//
//  Created by Chen Yiliang on 2020/11/3.
//  Copyright © 2020 Chen Yiliang. All rights reserved.
//

import UIKit

internal let PageSlideBarHeight: CGFloat = 35.0
internal let PageSlideBarTitleFont = UIFont.systemFont(ofSize: 15.0)
internal let PageSlideBarTintColor = UIColor(red: 6/255.0, green: 151/255.0, blue: 218/255.0, alpha: 1.0)
internal let PageSlideBarIndicatorViewHeight: CGFloat = 2.0
internal let PageSlideBarItemsGap: CGFloat = 15.0
internal let PageSlideBarSeparatorBackgroundColor = UIColor(red: 238/255.0, green: 238/255.0, blue: 238/255.0, alpha: 1.0)

public enum PageSlideBarLayoutStyle: Int {
    case normal = 0 // Buttons layout one by one
    case tite       // Buttons layout in full screen width
}

@objc
public protocol PageSlideBarDataSource {
    @objc
    optional func pageSlideBar(_ slideBar: PageSlideBar, buttonForItem item: PageSlideBarItem, atIndex index: NSNumber) -> PageSlideBarButton
}

@objc
public protocol PageSlideBarDelegate {
    @objc
    optional func pageSlideBar(_ slideBar: PageSlideBar, didSelectItem item: PageSlideBarItem)
    
    @objc
    optional func pageSlideBar(_ slideBar: PageSlideBar, didLoadButton button: PageSlideBarButton, atIndex index: NSNumber)
}

public class PageSlideBar: UIView {
    
    public override var frame: CGRect {
        get {
            return super.frame
        }
        set {
            let originalFrame = self.frame
            super.frame = newValue
            
            if !__CGSizeEqualToSize(newValue.size, originalFrame.size) {
                self.reloadSubviews()
            }
        }
    }
    
    private var _layoutStyle: PageSlideBarLayoutStyle = .normal
    public var layoutStyle: PageSlideBarLayoutStyle {
        get {
            return _layoutStyle
        }
        set {
            if _layoutStyle != newValue {
                _layoutStyle = newValue
                self.layoutButtons()
                self.setSelectedItem(self.selectedItem, alwaysReset: true)
            }
            
            if newValue == .tite {
                self.scrollView.isScrollEnabled = false
                self.scrollView.bounces = false
            } else {
                self.scrollView.isScrollEnabled = true
                self.scrollView.bounces = true
                self.scrollView.alwaysBounceHorizontal = true
            }
        }
    }
    
    public private(set) var scrollView: UIScrollView!
    public private(set) var separatorView: UIView!
    
    public private(set) var indicatorView: UIView!
    public var indicatorViewHeight: CGFloat {
        get {
            return self.indicatorView.frame.self.height
        }
        set {
            var frame = self.indicatorView.frame
            frame.origin.y -= newValue - frame.size.height
            frame.size.height = newValue
            self.indicatorView.frame = frame
        }
    }
    
    public var titleFont: UIFont? {
        didSet {
            for view in self.scrollView.subviews {
                if let button = view as? PageSlideBarButton {
                    if button.isSelected || self.selectedTitleFont == nil {
                        button.titleLabel?.font = titleFont
                    }
                }
            }
        }
    }
    
    public var selectedTitleFont: UIFont? {
        didSet {
            self.setSelectedItem(self.selectedItem, alwaysReset: true)
        }
    }
    
    public var items: [PageSlideBarItem]? {
        didSet {
            self.layoutButtons()
        }
    }
    
    public private(set) weak var selectedItem: PageSlideBarItem?
    
    @IBOutlet
    public weak var dataSource: PageSlideBarDataSource?
    
    @IBOutlet
    public weak var delegate: PageSlideBarDelegate?
    
    // MARK: - Lifecycle
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.commonInit()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    public convenience init(layoutStyle: PageSlideBarLayoutStyle) {
        self.init(frame: .zero)
        self.layoutStyle = layoutStyle
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        self.commonInit()
    }
    
    private func commonInit() {
        self.backgroundColor = UIColor.white
        
        if self.scrollView == nil {
            let scrollView = UIScrollView(frame: .zero)
            scrollView.translatesAutoresizingMaskIntoConstraints = false
            scrollView.showsHorizontalScrollIndicator = false
            scrollView.showsVerticalScrollIndicator = false
            scrollView.alwaysBounceVertical = false
            scrollView.backgroundColor = UIColor.clear
            
            if #available(iOS 11.0, *) {
                scrollView.contentInsetAdjustmentBehavior = .never
            }
            self.scrollView = scrollView
        }
        self.addSubview(self.scrollView)
        
        if self.separatorView == nil {
            let separatorView = UIView(frame: .zero)
            separatorView.translatesAutoresizingMaskIntoConstraints = false
            separatorView.backgroundColor = PageSlideBarSeparatorBackgroundColor
            self.separatorView = separatorView
        }
        self.addSubview(self.separatorView)
        
        if self.indicatorView == nil {
            let indicatorView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 0.0, height: PageSlideBarIndicatorViewHeight))
            indicatorView.translatesAutoresizingMaskIntoConstraints = false
            indicatorView.backgroundColor = self.tintColor
            self.indicatorView = indicatorView
        }
        self.scrollView.addSubview(self.indicatorView)
        
        self.setupLayoutConstraints()
        
        self.titleFont = PageSlideBarTitleFont
        self.tintColor = PageSlideBarTintColor
    }
    
    private func setupLayoutConstraints() {
        let views: [String: Any] = [
            "scrollView": self.scrollView as Any,
            "separatorView": self.separatorView as Any
        ]
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[scrollView]|", options: [], metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[scrollView]|", options: [], metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[separatorView]|", options: [], metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[separatorView(0.5)]|", options: [], metrics: nil, views: views))
    }
    
    // MARK: - Private Methods
    
    private func layoutButtons() {
        for view in self.scrollView.subviews {
            if view is PageSlideBarButton {
                view.removeFromSuperview()
            }
        }
        
        if self.items == nil || self.items?.count == 0 {
            return
        }
        
        var offsetX = self.layoutStyle == .tite ? 0.0 : PageSlideBarItemsGap
        for i in 0..<self.items!.count {
            let item = self.items![i]
            var button: PageSlideBarButton? = nil
            button = self.dataSource?.pageSlideBar?(self, buttonForItem: item, atIndex: NSNumber(value: i))
            if button == nil {
                button = PageSlideBarButton(type: .custom, item: item)
                button?.backgroundColor = UIColor.clear
                button?.titleLabel?.font = self.titleFont
                button?.setTitleColor(item.titleColor, for: .normal)
                button?.setTitleColor(item.selectedTitleColor ?? self.tintColor, for: .selected)
            }
            button?.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchUpInside)
            
            button?.sizeToFit()
            var frame = button!.frame
            frame.origin.x = offsetX
            if self.layoutStyle == .tite {
                let width = self.frame.size.width / CGFloat(self.items!.count)
                frame.size.width = CGFloat(floorf(Float(width)))
            }
            frame.size.height = self.frame.size.height
            button?.frame = frame
            button?.tag = i + 100
            self.scrollView.addSubview(button!)
            
            if self.layoutStyle == .tite {
                offsetX = offsetX + frame.size.width
            } else {
                offsetX = offsetX + frame.size.width + PageSlideBarItemsGap
            }
            
            self.delegate?.pageSlideBar?(self, didLoadButton: button!, atIndex: NSNumber(value: i))
        }
        
        var contentSize = self.scrollView.contentSize
        contentSize.width = offsetX
        self.scrollView.contentSize = contentSize
    }
    
    @objc
    private func buttonPressed(_ sender: Any?) {
        var selectedItem: PageSlideBarItem? = nil
        if sender != nil {
            let button = sender as! PageSlideBarButton
            selectedItem = self.items![button.tag - 100]
        } else {
            selectedItem = self.items!.first
        }
        
        self.delegate?.pageSlideBar?(self, didSelectItem: selectedItem!)
    }
    
    // MARK: - Public Methods
    
    public func reloadSubviews() {
        self.layoutButtons()
        self.setSelectedItem(self.selectedItem, alwaysReset: true)
    }
    
    public func setSelectedItem(_ selectedItem: PageSlideBarItem?, alwaysReset: Bool) {
        if self.selectedItem != selectedItem || alwaysReset {
            var preSelectedIndex = -1
            if let preSelectedItem = self.selectedItem {
                if let firstIndex = self.items!.firstIndex(of: preSelectedItem) {
                    preSelectedIndex = firstIndex
                }
            }
            if preSelectedIndex >= 0 && preSelectedIndex < self.items!.count {
                let preSelectedButton = self.scrollView.viewWithTag(preSelectedIndex + 100) as? PageSlideBarButton
                preSelectedButton?.isSelected = false
                preSelectedButton?.titleLabel?.font = self.titleFont
                preSelectedButton?.setTitleColor(self.selectedItem?.titleColor, for: .normal)
            }
            
            self.selectedItem = selectedItem
            var selectedIndex = -1
            if selectedItem != nil {
                if let firstIndex = self.items!.firstIndex(of: selectedItem!) {
                    selectedIndex = firstIndex
                }
            }
            if selectedIndex >= 0 && selectedIndex < self.items!.count {
                let selectedButton = self.scrollView.viewWithTag(selectedIndex + 100) as? PageSlideBarButton
                selectedButton?.isSelected = true
                selectedButton?.titleLabel?.font = self.selectedTitleFont ?? self.titleFont
                selectedButton?.setTitleColor(selectedItem?.selectedTitleColor ?? self.tintColor, for: .selected)
                
                var frame = self.indicatorView.frame
                frame.origin.x = selectedButton!.frame.origin.x
                frame.origin.y = selectedButton!.frame.size.height - frame.size.height
                frame.size.width = selectedButton!.frame.size.width
                self.indicatorView.frame = frame
                
                if self.layoutStyle == .normal {
                    var offsetX: CGFloat = 0.0
                    if self.scrollView.bounds.size.width > 0.0 {
                        let halfWidth = self.scrollView.bounds.size.width / 2
                        if selectedButton!.center.x < halfWidth {
                            offsetX = 0.0
                        } else {
                            let maxOffsetX = self.scrollView.contentSize.width - self.scrollView.bounds.size.width
                            if maxOffsetX < 0.0 {
                                offsetX = 0.0
                            } else {
                                offsetX = selectedButton!.center.x - halfWidth
                                offsetX = min(offsetX, maxOffsetX)
                            }
                        }
                    }
                    
                    var contentOffset = self.scrollView.contentOffset
                    if contentOffset.x != offsetX {
                        contentOffset.x = offsetX
                        self.scrollView.setContentOffset(contentOffset, animated: true)
                    }
                }
            }
        }
    }
    
}
