//
//  ViewController.swift
//  ParallaxViewPagerExample
//
//  Created by Ricardo on 17/11/16.
//  Copyright © 2016 Mobile First. All rights reserved.
//

import UIKit
import ParallaxViewPager

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var parallaxViewPager: ParallaxViewPager!
    var tableView: UITableView!

    var navigationBarHeight: CGFloat {
        get {
            if let navController = navigationController {
                return navController.navigationBar.frame.size.height
            }
            return 0
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let imageNames: [String] = ["img_01", "img_02", "img_03"]
        
        tableView = UITableView(frame: view.frame)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.bouncesZoom = true
        
        parallaxViewPager = ParallaxViewPager(frame: view.frame, pagerHeight: 250, imageNames: imageNames)
        parallaxViewPager.setNavigationBarHeight(value: navigationBarHeight)
        parallaxViewPager.addDetailView(view: tableView)
        view.addSubview(parallaxViewPager)
    }

    // MARK: Table view data source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 25
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cellIdentifier") as UITableViewCell?
        
        if cell == nil {
            cell = UITableViewCell(style: .value1, reuseIdentifier: "cellIdentifier")
        }
        
        if let label = cell!.textLabel {
            label.text = "Item \(String(indexPath.row))"
        }
        
        return cell!
    }
    
}
