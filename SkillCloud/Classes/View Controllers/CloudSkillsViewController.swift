//
//  CloudSkillsViewController.swift
//  SkillCloud
//
//  Created by Andrzej Michnia on 26/06/16.
//  Copyright © 2016 amichnia. All rights reserved.
//

import UIKit
import PromiseKit
import MRProgress

class CloudSkillsViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: - Properties
    var skillsOffset = 18
    var skills : [Skill] = []
    var preparedScene : AddScene?
    var cloudContainer: CloudContainer!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        MRProgressOverlayView.showOverlayAddedTo(self.view, animated: true)
        self.cloudContainer = CloudContainer()
        
        self.cloudContainer.promiseAllSkillsFromDatabase(.Public)
        .then { skills -> Void in
            self.skills = skills
            self.collectionView.reloadData()
        }
        .always {
            MRProgressOverlayView.dismissAllOverlaysForView(self.view, animated: true)
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
        try! self.promiseAddSkillWith(self.view.convertRect(sender.bounds, fromView: sender))
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
    
    func frameForCell(cell: SkillCollectionViewCell) -> CGRect {
        cell.layoutSubviews()
        let imgfrm = cell.imageView.frame
        let rect = CGRect(
            origin: CGPoint(x: imgfrm.origin.x + cell.frame.origin.x, y: imgfrm.origin.y + cell.frame.origin.y - self.collectionView.contentOffset.y + self.collectionView.frame.origin.y),
            size: imgfrm.size
        )
        return rect
    }
    
    func promiseAddSkillWith(rect: CGRect?) throws {
        try AddViewController.promiseNewSkillWith(self, rect: rect, preparedScene: self.preparedScene)
        .then { skill -> Skill in
            self.skills.append(skill)
            
            MRProgressOverlayView.showOverlayAddedTo(self.view, animated: true)
            
            return skill
        }
        .then { skill -> Promise<Skill> in
            return skill.promiseSyncTo()
        }
        .then { skill -> Void in
            print("Added record with ID = \(skill.recordID)")
        }
        .always {
            MRProgressOverlayView.dismissAllOverlaysForView(self.view, animated: true)
            self.collectionView.reloadData()
        }
        .error { error in
            print("Error: \(error)")
        }
    }
    
    func promiseChangeSkillWith(rect: CGRect?, withSkill skill: Skill) throws {
        try AddViewController.promiseChangeSkillWith(self, rect: rect, skill: skill, preparedScene: self.preparedScene)
    }
    
    // MARK: - Helpers
    let colors = [
        (UIColor(rgba: (69/255, 76/255, 89/255, 1)), UIColor(rgba: (88/255, 93/255, 102/255, 1))),
        (UIColor(rgba: (75/255, 81/255, 92/255, 1)), UIColor(rgba: (95/255, 100/255, 107/255, 1))),
        (UIColor(rgba: (82/255, 87/255, 97/255, 1)), UIColor(rgba: (102/255, 107/255, 113/255, 1)))
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
    
    // MARK: - Navigation
    
}

// MARK: - UICollectionViewDataSource
extension CloudSkillsViewController: UICollectionViewDataSource {
    
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
extension CloudSkillsViewController: UICollectionViewDelegate {
    
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

extension CloudSkillsViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        self.collectionView.visibleCells().forEach {
            self.configureColorFor($0 as! SkillCollectionViewCell)
        }
    }
    
}