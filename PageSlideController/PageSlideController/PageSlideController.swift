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

open class PageSlideController: UIViewController {
    
    public var viewControllers: [UIViewController]?
    public weak var selectedViewController: UIViewController?
    public var selectedIndex: Int = 0
    
    @IBOutlet
    public var pageSlideBar: PageSlideBar!
    
    public var pageSlideBarHeight: CGFloat = PageSlideBarHeight
    public var pageSlideBarLayoutStyle: PageSlideBarLayoutStyle = .normal
    
    @IBOutlet
    public var contentView: PageSlideContentView!
    
    public weak var delegate: PageSlideControllerDelegate?
    
    // MARK: - Lifecycle
    
    private func commonInit() {
        
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
        
    }
    
    // MARK: - View Lifecycle

    open override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    public func updateSubviews(selectedIndex: Int, changeOffset: Bool) {
        
    }

}
