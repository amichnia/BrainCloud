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
    @IBOutlet weak var tableViewBottomConstraint: NSLayoutConstraint!
    
    // MARK: - Properties
    var skillsResult: CKPageableResult = CKPageableResult(type: Skill.self, predicate: NSPredicate(format: "accepted = %d", 1), database: .Public)
    var updating: Bool = false
    
    lazy var searchCell: SkillsSearchTableViewCell = {
        return self.tableView.dequeueReusableCellWithIdentifier("SearchSkillsHeader")! as! SkillsSearchTableViewCell
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.estimatedRowHeight = 76
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedSectionHeaderHeight = 40
        self.tableView.sectionHeaderHeight = UITableViewAutomaticDimension
        
        (self.tableView as UIScrollView).delegate = self
        
        self.skillsResult.desiredKeys = ["name","experienceValue","thumbnail"]
        self.skillsResult.limit = 10
        
        MRProgressOverlayView.show()
        self.updating = true
        
        firstly {
            self.skillsResult.promiseNextPage()
        }
        .then { [weak self] _ -> Void in
            print("LOADED more!")
            self?.tableView.reloadData()
        }
        .always { [weak self] in
            print("Update finished")
            self?.updating = false
            MRProgressOverlayView.hide()
        }
        .error { error in
            print("Error: \(error)")
        }
    }
    
    // MARK: - Actions
    func addSkillActionFromCell(cell: UITableViewCell, withSkill skill: Skill) {
        if let skillCell = cell as? SkillTableViewCell {
            let rect = self.frameForCell(skillCell)
            try! self.promiseShowSkillWith(rect, withSkill: skill)
        }
        else {
            try! self.promiseShowSkillWith(nil, withSkill: skill)
        }
    }
    
    // MARK: - Helpers
    func frameForCell(cell: SkillTableViewCell) -> CGRect {
        cell.layoutSubviews()
        let imgfrm = cell.skillImageView.frame
        let rect = CGRect(
            origin: CGPoint(x: imgfrm.origin.x + cell.frame.origin.x, y: imgfrm.origin.y + cell.frame.origin.y - self.tableView.contentOffset.y + self.tableView.frame.origin.y),
            size: imgfrm.size
        )
        
        return self.view.convertRect(rect, toView: self.view.window!)
    }
    
    
    // MARK: - Promises
    func promiseShowSkillWith(rect: CGRect?, withSkill skill: Skill) throws {
        firstly {
            try AddViewController.promiseChangeSkillWith(self, rect: rect, skill: skill, preparedScene: nil)
        }
        .then(SkillEntity.promiseToUpdate)                  // Save change to local storage
        .error { error in
            print("Error: \(error)")
        }
    }
    
    // MARK: - Navigation

}

extension ExploreViewController: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.skillsResult.results.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SkillCell")! as! SkillTableViewCell
        
        let skill = self.skillsResult.results[indexPath.row]
        
        cell.configureForSkill(skill)
        cell.indexPath = indexPath
        
        return cell
    }
    
}

extension ExploreViewController: UITableViewDelegate {

    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return self.searchCell.contentView
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let skill = self.skillsResult.results[indexPath.row]

        if let cell = self.tableView.visibleCells.filter({
            $0 is SkillTableViewCell ? ($0 as! SkillTableViewCell).indexPath.row == indexPath.row : false
        }).first {
            self.addSkillActionFromCell(cell, withSkill: skill)
        }
    }
    
}

extension ExploreViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        // TODO: Implement pagination
        let bound = self.tableView.contentSize.height - 200
        let offset = self.tableView.contentOffset.y + self.tableView.bounds.height
        
        if !updating && offset >= bound && self.skillsResult.hasNextPage {
            self.updating = true
            print("Loading more!")
            
            firstly {
                self.skillsResult.promiseNextPage()
            }
            .then { [weak self] _ -> Void in
                print("LOADED more!")
                self?.tableView.reloadData()
            }
            .always { [weak self] in
                print("Update finished")
                self?.updating = false
            }
            .error { error in
                print("Error: \(error)")
            }
        }
    }
    
}