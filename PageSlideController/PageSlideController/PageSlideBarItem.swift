//
//  PageSlideBarItem.swift
//  PageSlideController
//
//  Created by Chen Yiliang on 2020/11/3.
//  Copyright © 2020 Chen Yiliang. All rights reserved.
//

import UIKit

@objcMembers
public class PageSlideBarItem: NSObject {
    
    public var title: String?
    public var titleColor: UIColor? {
        get {
            return _titleColor ?? UIColor.black
        }
        set {
            _titleColor = newValue
        }
    }
    public var selectedTitleColor: UIColor?
    
    private var _titleColor: UIColor?
    
    public init(title: String?, titleColor: UIColor?, selectedTitleColor: UIColor?) {
        super.init()
        self.title = title
        self.titleColor = titleColor
        self.selectedTitleColor = selectedTitleColor
    }

}
