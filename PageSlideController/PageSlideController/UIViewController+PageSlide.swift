//
//  UIViewController+PageSlideController.swift
//  PageSlideController
//
//  Created by Chen Yiliang on 2020/11/4.
//  Copyright © 2020 Chen Yiliang. All rights reserved.
//

import UIKit

extension UIViewController {
    
    private struct AssociatedKeys {
        static var pageSlideBarItem: Void?
    }
    
    public var pageSlideBarItem: PageSlideBarItem? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.pageSlideBarItem) as? PageSlideBarItem
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.pageSlideBarItem, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    public var pageSlideController: PageSlideController? {
        var pageSlideController: PageSlideController? = nil
        if self.parent is PageSlideController {
            pageSlideController = self.parent as? PageSlideController
        }
        return pageSlideController
    }
    
}
