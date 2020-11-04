//
//  PageViewController.swift
//  PageSlideController
//
//  Created by Chen Yiliang on 2020/11/4.
//  Copyright © 2020 Chen Yiliang. All rights reserved.
//

import UIKit

class PageViewController: UIViewController {
    
    @IBOutlet weak var label: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.label.text = self.title
    }
    
    @IBAction
    private func buttonPressed(_ sender: Any?) {
        self.dismiss(animated: true, completion: nil)
    }

}
