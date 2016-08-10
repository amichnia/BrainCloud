//
//  InfoViewController.swift
//  SkillCloud
//
//  Created by Andrzej Michnia on 10/08/16.
//  Copyright © 2016 amichnia. All rights reserved.
//

import UIKit

class InfoViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Properties
    let menuOffset = 6
    var first = true
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        (self.tableView as UIScrollView).delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tableView.visibleCells.forEach(self.configureColorFor)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if self.first {
            self.first = false
            
            let rowHeight: CGFloat = self.tableView.bounds.height / CGFloat(InfoMenuItem.allItems.count)
            self.tableView.rowHeight = rowHeight
            self.tableView.layoutIfNeeded()
        }
        
        let height = CGFloat(self.menuOffset) * self.tableView.rowHeight
        self.tableView.contentInset = UIEdgeInsets(top: -height, left: 0, bottom: -height, right: 0)
    }
    
    // MARK: - Actions
    
    // MARK: - Helpers
    let colors = [
        (UIColor(netHex: 0x0b1518), UIColor(netHex: 0x25444d)),
        (UIColor(netHex: 0x122125), UIColor(netHex: 0x2b505a)),
        (UIColor(netHex: 0x182d32), UIColor(netHex: 0x315c68))
    ]
    
    func configureColorFor(cell: UITableViewCell) {
        var offset = cell.frame.origin
        offset.y -= self.tableView.contentOffset.y
        offset.y = max(0, min(self.tableView.bounds.height, offset.y))
        
        let factor = offset.y / self.tableView.bounds.height;
        
        let topColor = self.colors[1].0
        let botColor = self.colors[1].1
        
        cell.backgroundColor = UIColor.interpolate(topColor, B: botColor, t: factor)
    }
    
    // MARK: - Navigation

}

extension InfoViewController: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 1:
            return InfoMenuItem.allItems.count
        default:
            return self.menuOffset
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard indexPath.section == 1 else {
            return tableView.dequeueReusableCellWithIdentifier("EmptyCell")!
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier("MenuCell") as! InfoMenuTableViewCell
        
        cell.configureForItem(InfoMenuItem.allItems[indexPath.row])
        
        return cell
    }
    
}

extension InfoViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        guard indexPath.section == 1 else {
            return
        }
        
        switch InfoMenuItem.allItems[indexPath.row] {
        case .Licenses:
            self.performSegueWithIdentifier("ShowLicenses", sender: self)
        default:
            break
        }
    }
    
}

extension InfoViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        self.tableView.visibleCells.forEach(self.configureColorFor)
    }
    
}
