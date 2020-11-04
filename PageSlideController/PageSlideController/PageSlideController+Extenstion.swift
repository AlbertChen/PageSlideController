//
//  PageSlideController+Extenstion.swift
//  PageSlideController
//
//  Created by Chen Yiliang on 2020/11/4.
//  Copyright © 2020 Chen Yiliang. All rights reserved.
//

import UIKit

extension PageSlideController {

    internal var topLayoutInset: CGFloat {
        var topLayoutInset: CGFloat
        if #available(iOS 11, *) {
            topLayoutInset = view.safeAreaInsets.top
        } else {
            topLayoutInset = topLayoutGuide.length
        }
        if topLayoutInset == 0.0 {
            topLayoutInset = UIApplication.shared.statusBarFrame.size.height
        }
        if let navigationController = self.navigationController {
            topLayoutInset += navigationController.navigationBar.frame.size.height
        }
        return topLayoutInset
    }
    
    internal var bottomLayoutInset: CGFloat {
        var bottomLayoutInset: CGFloat
        if #available(iOS 11, *) {
            bottomLayoutInset = view.safeAreaInsets.bottom
        } else {
            bottomLayoutInset = bottomLayoutGuide.length
        }
        if let tabBarController = self.tabBarController {
            bottomLayoutInset += tabBarController.tabBar.frame.size.height
        }
        return bottomLayoutInset
    }

}
