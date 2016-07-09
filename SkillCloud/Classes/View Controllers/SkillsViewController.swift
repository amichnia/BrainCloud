//
//  SkillsViewController.swift
//  SkillCloud
//
//  Created by Andrzej Michnia on 19/04/16.
//  Copyright © 2016 amichnia. All rights reserved.
//

import UIKit
import PromiseKit
import MRProgress

let AddSkillCellIdentifier = "AddSkillCell"
let SkillCellIdentifier = "SkillCell"

class SkillsViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: - Properties
    var skillsOffset = 18
    var skills : [Skill] = []
    var preparedScene : AddScene?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        MRProgressOverlayView.show()
        firstly {
            Skill.fetchAll()
        }
        .then(on: dispatch_get_main_queue()) { skills -> Void in
            self.skills = skills
            self.collectionView.reloadData()
        }
        .always {
            MRProgressOverlayView.hide()
        }
        .error { error in
            print("Error: \(error)")
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let scene = AddScene(fileNamed:"AddScene") {
            self.preparedScene = scene
            scene.size = self.view.bounds.size
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let width = ceil(self.view.bounds.width/3)
        (self.collectionView.collectionViewLayout as! UICollectionViewFlowLayout).itemSize = CGSize(width: width, height: width)
        
        let sectionHeight = CGFloat((self.skillsOffset + self.skillsOffset % 3) / 3) * width
        
        self.collectionView.contentInset = UIEdgeInsets(top: -sectionHeight, left: 0, bottom: -sectionHeight, right: 0)
    }
    
    // MARK: - Actions
    @IBAction func addSkillAction(sender: UIView) {
        let rect = self.view.convertRect(sender.bounds, fromView: sender)
        try! self.promiseAddSkillWith(self.view.convertRect(rect, toView: self.view.window!))
    }
    
    func addSkillActionFromCell(cell: UICollectionViewCell) {
        if let skillCell = cell as? SkillCollectionViewCell {
            let rect = self.frameForCell(skillCell)
            try! self.promiseAddSkillWith(rect)
        }
        else {
            try! self.promiseAddSkillWith(nil)
        }
    }
    
    func changeSkillActionFromCell(cell: UICollectionViewCell, withSkill skill: Skill) {
        if let skillCell = cell as? SkillCollectionViewCell {
            let rect = self.frameForCell(skillCell)
            try! self.promiseChangeSkillWith(rect, withSkill: skill)
        }
        else {
            try! self.promiseChangeSkillWith(nil, withSkill: skill)
        }
    }
    
    // MARK: - Promises
    func promiseAddSkillWith(rect: CGRect?) throws {
        firstly {
            try AddViewController.promiseNewSkillWith(self, rect: rect, preparedScene: self.preparedScene)
        }
        .then(SkillEntity.promiseToInsert)
        .then(on: dispatch_get_main_queue()) { savedEntity -> Promise<Skill> in
            // Insert new skill
            self.skills.append(savedEntity.skill)
            self.collectionView.reloadData()
            
            return savedEntity.skill.promiseInsertTo(DatabaseType.Private)
        }
        .then(SkillEntity.promiseToUpdate)  // TODO: Update only offline flag!!!
        .error { error in
            print("Error: \(error)")
        }
    }
    
    func promiseChangeSkillWith(rect: CGRect?, withSkill skill: Skill) throws {
        firstly {
            try AddViewController.promiseChangeSkillWith(self, rect: rect, skill: skill, preparedScene: self.preparedScene)
        }
        .then(SkillEntity.promiseToUpdate)                  // Save change to local storage
        .then { savedEntity -> Promise<Skill> in
            return firstly {                                // Fetch changed
                Skill.fetchAll()
            }
            .then(on: dispatch_get_main_queue()) { skills -> Void in
                self.skills = skills                        // Reload UI
                self.collectionView.reloadData()            // Reload UI
            }
            .then { _ -> Promise<Skill> in                  // Call and update to CloudKit
                // Handle update cases:
                if savedEntity.toDelete {
                    return savedEntity.skill.promiseDeleteFrom(.Private)
                }
                else {
                    return savedEntity.skill.promiseSyncTo(.Private)
                }
            }
        }
        .then { skill -> Promise<Void> in
            if skill.toDelete {
                return SkillEntity.promiseToDelete(skill)
            }
            else {
                return SkillEntity.promiseToUpdate(skill).asVoid()
            }
        }
        .error { error in
            print("Error: \(error)")
        }
    }
    
    // MARK: - Helpers
    let colors = [
        (UIColor(netHex: 0x0b1518), UIColor(netHex: 0x25444d)),
        (UIColor(netHex: 0x122125), UIColor(netHex: 0x2b505a)),
        (UIColor(netHex: 0x182d32), UIColor(netHex: 0x315c68))
    ]
    
    func configureColorFor(cell: SkillCollectionViewCell) {
        var offset = cell.frame.origin
        offset.y -= self.collectionView.contentOffset.y
        offset.y = max(0, min(self.collectionView.bounds.height, offset.y))
        
        let factor = offset.y / self.collectionView.bounds.height;
        
        let topColor = self.colors[cell.column].0
        let botColor = self.colors[cell.column].1
        
        cell.backgroundColor = UIColor.interpolate(topColor, B: botColor, t: factor)
    }
    
    func frameForCell(cell: SkillCollectionViewCell) -> CGRect {
        cell.layoutSubviews()
        let imgfrm = cell.imageView.frame
        let rect = CGRect(
            origin: CGPoint(x: imgfrm.origin.x + cell.frame.origin.x, y: imgfrm.origin.y + cell.frame.origin.y - self.collectionView.contentOffset.y + self.collectionView.frame.origin.y),
            size: imgfrm.size
        )
        
        return self.view.convertRect(rect, toView: self.view.window!)
    }
    
    // MARK: - Navigation
    
}

// MARK: - UICollectionViewDataSource
extension SkillsViewController: UICollectionViewDataSource {
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 3
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard section == 1 else {
            return self.skillsOffset
        }
        
        let cells = self.skills.count + 1
        return cells + ((3 - cells % 3) % 3)
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        guard indexPath.section == 1 else {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(SkillCellIdentifier, forIndexPath: indexPath) as! SkillCollectionViewCell
            cell.indexPath = indexPath
            cell.prepareForReuse()
            self.configureColorFor(cell)
            cell.setNeedsLayout()
            return cell
        }
        
        let cell : SkillCollectionViewCell = {
            if indexPath.row == self.skills.count {
                let cell = collectionView.dequeueReusableCellWithReuseIdentifier(AddSkillCellIdentifier, forIndexPath: indexPath) as! SkillCollectionViewCell
                cell.prepareForReuse()
                cell.configureAsAddCell(indexPath)
                return cell
            }
            else if indexPath.row > self.skills.count {
                let cell = collectionView.dequeueReusableCellWithReuseIdentifier(SkillCellIdentifier, forIndexPath: indexPath) as! SkillCollectionViewCell
                cell.prepareForReuse()
                cell.indexPath = indexPath
                return cell
            }
            else {
                let cell = collectionView.dequeueReusableCellWithReuseIdentifier(SkillCellIdentifier, forIndexPath: indexPath) as! SkillCollectionViewCell
                cell.prepareForReuse()
                cell.configureWithSkill(self.skills[indexPath.row], atIndexPath: indexPath)
                return cell
            }
        }()
        self.configureColorFor(cell)
        cell.setNeedsLayout()
        return cell
    }
    
}

// MARK: - UICollectionViewDelegate
extension SkillsViewController: UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        guard indexPath.section == 1 else {
            return
        }
        
        if indexPath.row < self.skills.count, let cell = self.collectionView.visibleCells().filter({
            $0 is SkillCollectionViewCell ? ($0 as! SkillCollectionViewCell).indexPath.row == indexPath.row : false
        }).first {
            self.changeSkillActionFromCell(cell, withSkill: self.skills[indexPath.row])
            return
        }
        if indexPath.row == self.skills.count , let cell = self.collectionView.visibleCells().filter({
            $0 is SkillCollectionViewCell ? ($0 as! SkillCollectionViewCell).indexPath.row == indexPath.row : false
        }).first {
            self.addSkillActionFromCell(cell)
            return
        }
    }
    
}

extension SkillsViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        self.collectionView.visibleCells().forEach {
            self.configureColorFor($0 as! SkillCollectionViewCell)
        }
    }
    
}

extension UIColor {
    
    static func interpolate(A:UIColor, B:UIColor, t: CGFloat) -> UIColor {
        var Argba : (CGFloat,CGFloat,CGFloat,CGFloat) = (0,0,0,0)
        var Brgba : (CGFloat,CGFloat,CGFloat,CGFloat) = (0,0,0,0)
        A.getRed(&Argba.0, green: &Argba.1, blue: &Argba.2, alpha: &Argba.3)
        B.getRed(&Brgba.0, green: &Brgba.1, blue: &Brgba.2, alpha: &Brgba.3)
        
        var rgba : (CGFloat,CGFloat,CGFloat,CGFloat) = (0,0,0,0)
        rgba.0 = (Argba.0 * (1-t)) + (Brgba.0 * t)
        rgba.1 = (Argba.1 * (1-t)) + (Brgba.1 * t)
        rgba.2 = (Argba.2 * (1-t)) + (Brgba.2 * t)
        rgba.3 = (Argba.3 * (1-t)) + (Brgba.3 * t)
        
        return UIColor(rgba: rgba)
    }
    
}