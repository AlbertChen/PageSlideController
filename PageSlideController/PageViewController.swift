//
//  PageViewController.swift
//  PageSlideController
//
//  Created by Chen Yiliang on 2020/11/4.
//  Copyright © 2020 Chen Yiliang. All rights reserved.
//

import UIKit

class PageViewController: UIViewController, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.register(UINib(nibName: "PageTableViewCell", bundle: nil), forCellReuseIdentifier: "PageTableViewCell")
    }
    
    @IBAction
    private func buttonPressed(_ sender: Any?) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PageTableViewCell", for: indexPath) as! PageTableViewCell
        cell.titleLabel.text = String(format: "Row %d", indexPath.row + 1)
        return cell
    }

}
