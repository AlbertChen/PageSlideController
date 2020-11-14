//
//  PageSlideScrollView.swift
//  PageSlideController
//
//  Created by Chen Yiliang on 2020/11/3.
//  Copyright © 2020 Chen Yiliang. All rights reserved.
//

import UIKit

public class PageSlideScrollView: UIScrollView, UIGestureRecognizerDelegate {
    
    public var otherGestureRecognizers: [UIGestureRecognizer]?
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if let otherGestureRecognizers = otherGestureRecognizers, otherGestureRecognizers.contains(otherGestureRecognizer) {
            return false
        }
        return true
    }
    
}
