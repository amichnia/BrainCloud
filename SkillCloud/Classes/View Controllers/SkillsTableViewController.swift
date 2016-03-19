//
//  SkillsTableViewController.swift
//  SkillCloud
//
//  Created by Andrzej Michnia on 17.03.2016.
//  Copyright © 2016 amichnia. All rights reserved.
//

import UIKit
import AMKSlidingTableViewCell
import PromiseKit

let AddSkillPopoverSegueIdentifier = "AddSkillPopover"
let BackToListSegueIdentifier = "BackToList"

class SkillsTableViewController: UIViewController {

    var skills : [Skill] = []
    var addSkillViewController : AddSkillViewController?
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        SkillEntity.fetchAll().then { (entities: [SkillEntity]) -> ()  in
            self.skills = entities.map{ $0.skill }
            self.tableView.reloadData()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
    }
    
    // MARK: - Action
    func addSkill(skill: Skill) {
        SkillEntity.promiseToInsert(skill).then { (entity) -> () in
            self.skills.append(skill)
            self.tableView.reloadData()
        }.error { error in
            print(error)
        }
    }
    
    // MARK: - Navigation
    @IBAction func unwindToSkillsTableViewController(unwindSegue: UIStoryboardSegue) { }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let identifier = segue.identifier else {
            return
        }
        
        switch identifier {
        case AddSkillPopoverSegueIdentifier:
            if let popoverViewController = segue.destinationViewController as? AddSkillViewController {
                self.addSkillViewController = popoverViewController
                popoverViewController.modalPresentationStyle = UIModalPresentationStyle.Popover
                popoverViewController.popoverPresentationController!.delegate = self
            }
        default:
            break
        }
    }
    
}

extension SkillsTableViewController : UIPopoverPresentationControllerDelegate {
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }
    
    func popoverPresentationControllerShouldDismissPopover(popoverPresentationController: UIPopoverPresentationController) -> Bool {
        if let _ = self.addSkillViewController where self.addSkillViewController!.isEditingText {
            self.addSkillViewController?.dismissKeyboardAction(self)
            return false
        }
        
        return true
    }
    
}

// MARK: - Table view data source
extension SkillsTableViewController : UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return skills.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let identifier = indexPath.row == self.skills.count ? "AddNewSkillCell" : "SkillCell"
        
        let cell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath)
        
        if let slidingCell = cell as? MKSlidingTableViewCell, foregroundCell = tableView.dequeueReusableCellWithIdentifier("ForegroundCell") as? MKActionTableViewCell, backgroundCell = tableView.dequeueReusableCellWithIdentifier("BackgroundCell") as? MKActionTableViewCell {
            
            slidingCell.delegate = self;
            slidingCell.foregroundView = foregroundCell
            slidingCell.drawerView = backgroundCell
            
            (foregroundCell as? SkillTableViewCell)?.configureForSkill(self.skills[indexPath.row])
            
            return slidingCell
        }
        
        return cell
    }
    
}

// MARK: - AMK Sliding cell delegate
extension SkillsTableViewController : MKSlidingTableViewCellDelegate {
    
    func didSelectSlidingTableViewCell(cell: MKSlidingTableViewCell!) {
        // TODO: goto details
    }
    
}
