//
//  PageSlideBarButton.swift
//  PageSlideController
//
//  Created by Chen Yiliang on 2020/11/3.
//  Copyright © 2020 Chen Yiliang. All rights reserved.
//

import UIKit

public class PageSlideBarButton: UIButton {
    
    public var item: PageSlideBarItem? {
        get {
            return _item
        }
        set {
            _item = newValue
            configTitle()
        }
    }
    
    private var _item: PageSlideBarItem?
    
    public convenience init(type: ButtonType, item: PageSlideBarItem) {
         self.init(type: type)
        
        self.item = item
        self.addObserver(self, forKeyPath: "_item.title", options: [.new, .old], context: nil)
    }
    
    private func configTitle() {
        self.setTitle(_item?.title, for: .normal)
        self.setTitle(_item?.title, for: .selected)
        self.setTitleColor(_item?.titleColor, for: .normal)
        self.setTitleColor(_item?.selectedTitleColor, for: .selected)
    }
    
    deinit {
        self.removeObserver(self, forKeyPath: "_item.title")
    }

}
