//
//  ViewController.swift
//  PageSlideController
//
//  Created by Chen Yiliang on 2020/10/28.
//  Copyright © 2020 Chen Yiliang. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction
    private func titeButtonPressed(_ sender: Any?) {
        self.showPageSlideController(style: .tite, count: 3)
    }
    
    @IBAction
    private func normalButtonPressed(_ sender: Any?) {
        self.showPageSlideController(style: .normal, count: 6)
    }
    
    private func showPageSlideController(style: PageSlideBarLayoutStyle, count: Int) {
        var viewControllers: [UIViewController] = []
        for i in 0..<count {
            let controller = PageViewController(nibName: nil, bundle: nil)
            controller.title = String(format: "controller %d", i + 1)
            viewControllers.append(controller)
        }
        
        let slideControlelr = PageSlideController(viewControllers: viewControllers, barLayoutStyle: style)
        slideControlelr.title = "Page Slide Controller"
        let navController = UINavigationController(rootViewController: slideControlelr)
        navController.navigationBar.isTranslucent = false
        navController.modalPresentationStyle = .fullScreen
        self.present(navController, animated: true, completion: nil)
    }

}

