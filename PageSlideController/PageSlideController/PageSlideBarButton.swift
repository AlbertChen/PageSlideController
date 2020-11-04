//
//  PageSlideBarButton.swift
//  PageSlideController
//
//  Created by Chen Yiliang on 2020/11/3.
//  Copyright © 2020 Chen Yiliang. All rights reserved.
//

import UIKit

@objcMembers
public class PageSlideBarButton: UIButton {
    
    public var item: PageSlideBarItem? {
        didSet {
            self.configTitle()
        }
    }
    
    public convenience init(type: ButtonType, item: PageSlideBarItem) {
         self.init(type: type)
        
        self.item = item
        self.configTitle()
        self.addObserver(self, forKeyPath: "item.title", options: [.new, .old], context: nil)
    }
    
    private func configTitle() {
        self.setTitle(self.item?.title, for: .normal)
        self.setTitle(self.item?.title, for: .selected)
        self.setTitleColor(self.item?.titleColor, for: .normal)
        self.setTitleColor(self.item?.selectedTitleColor, for: .selected)
    }
    
    deinit {
        self.removeObserver(self, forKeyPath: "item.title")
    }

}
