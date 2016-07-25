//
//  ExploreViewController.swift
//  SkillCloud
//
//  Created by Andrzej Michnia on 25/07/16.
//  Copyright © 2016 amichnia. All rights reserved.
//

import UIKit
import PromiseKit
import MRProgress

class ExploreViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Properties
    var skills : [Skill] = []
    
    lazy var searchCell: SkillsSearchTableViewCell = {
        return self.tableView.dequeueReusableCellWithIdentifier("SearchSkillsHeader")! as! SkillsSearchTableViewCell
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.estimatedRowHeight = 72
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedSectionHeaderHeight = 40
        self.tableView.sectionHeaderHeight = UITableViewAutomaticDimension
        
        (self.tableView as UIScrollView).delegate = self
        
        MRProgressOverlayView.show()
        firstly {
            CloudContainer.sharedContainer.promiseAllSkillsFromDatabase(.Public)
        }
        .then { skills -> Void in
            self.skills = skills
            self.tableView.reloadData()
        }
        .always { 
            MRProgressOverlayView.hide()
        }
    }
    
    // MARK: - Actions
    
    // MARK: - Navigation

}

extension ExploreViewController: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.skills.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SkillCell")! as! SkillTableViewCell
        
        let skill = self.skills[indexPath.row]
        
        cell.configureForSkill(skill)
        
        return cell
    }
    
}

extension ExploreViewController: UITableViewDelegate {

    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return self.searchCell.contentView
    }

}

extension ExploreViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        // TODO: Implement pagination
    }
    
}