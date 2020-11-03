//
//  PageSlideContentView.swift
//  PageSlideController
//
//  Created by Chen Yiliang on 2020/11/3.
//  Copyright © 2020 Chen Yiliang. All rights reserved.
//

import UIKit

public class PageSlideContentView: UIScrollView, UIGestureRecognizerDelegate {
    
    @IBInspectable
    public var alwaysBounceHorizontalLeft: Bool = false
    
    public override var contentOffset: CGPoint {
        get {
            return super.contentOffset
        }
        set {
            var offset = newValue
            if !self.alwaysBounceHorizontalLeft {
                if self.isDragging || self.isDecelerating {
                    if offset.x < 0.0 {
                        offset.x = 0.0
                        self.panGestureRecognizer.isEnabled = false
                    } else {
                        self.panGestureRecognizer.isEnabled = true
                    }
                }
            }
            super.contentOffset = offset
        }
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        let nextResponder = otherGestureRecognizer.view?.next
        if gestureRecognizer is UIPanGestureRecognizer &&
            self.contentOffset.x < UIScreen.main.bounds.self.width &&
            (otherGestureRecognizer is UIPanGestureRecognizer || otherGestureRecognizer is UIScreenEdgePanGestureRecognizer) &&
            nextResponder is UINavigationController {
            return true
        } else {
            return false
        }
    }

}
