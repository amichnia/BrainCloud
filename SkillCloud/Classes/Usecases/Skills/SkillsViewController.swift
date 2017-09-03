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
    @IBOutlet weak var collectionViewWidth: NSLayoutConstraint!
    
    // MARK: - Properties
    var skillsOffset = 18
    var skills : [Skill] = []
    var preparedScene : AddScene?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        firstly {
            Skill.fetchAll()
        }
        .then(on: DispatchQueue.main) { skills -> Void in
            self.skills = skills
            self.collectionView.reloadData()
        }
        .catch { error in
            print("Error: \(error)")
        }
        
        if let scene = AddScene(fileNamed:"AddScene") {
            self.preparedScene = scene
            scene.size = self.view.bounds.size
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let width = ceil(self.view.bounds.width/3)
        let collectionWidth = 3 * width
        
        if self.collectionViewWidth.constant != collectionWidth {
            self.collectionViewWidth.constant = collectionWidth
            self.collectionView.setNeedsLayout()
        }
        
        (self.collectionView.collectionViewLayout as! UICollectionViewFlowLayout).itemSize = CGSize(width: width, height: width)
        
        let sectionHeight = CGFloat((self.skillsOffset + self.skillsOffset % 3) / 3) * width
        
        self.collectionView.contentInset = UIEdgeInsets(top: -sectionHeight, left: 0, bottom: -sectionHeight, right: 0)
    }
    
    // MARK: - Actions
    @IBAction func addSkillAction(_ sender: UIView) {
        let rect = self.view.convert(sender.bounds, from: sender)
        try! self.promiseAddSkillWith(self.view.convert(rect, to: self.view.window!))
    }
    
    func addSkillActionFromCell(_ cell: UICollectionViewCell) {
        if let skillCell = cell as? SkillCollectionViewCell {
            let rect = self.frameForCell(skillCell)
            try! self.promiseAddSkillWith(rect)
        }
        else {
            try! self.promiseAddSkillWith(nil)
        }
    }
    
    func changeSkillActionFromCell(_ cell: UICollectionViewCell, withSkill skill: Skill) {
        if let skillCell = cell as? SkillCollectionViewCell {
            let rect = self.frameForCell(skillCell)
            try! self.promiseChangeSkillWith(rect, withSkill: skill)
        }
        else {
            try! self.promiseChangeSkillWith(nil, withSkill: skill)
        }
    }
    
    // MARK: - Promises
    func promiseAddSkillWith(_ rect: CGRect?) throws {
        firstly {
            try AddViewController.promiseNewSkillWith(self, rect: rect, preparedScene: self.preparedScene)
        }
        .then(execute: SkillEntity.promiseToInsert)
        .then(on: DispatchQueue.main) { savedEntity -> Promise<Skill> in
            // Insert new skill
            self.skills.append(savedEntity.skill)
            self.collectionView.reloadData()
            
            _ = savedEntity.skill.promiseInsertTo(DatabaseType.public)  // Help building explore section
            
            return savedEntity.skill.promiseInsertTo(DatabaseType.private)
        }
        .then(execute: SkillEntity.promiseToUpdate)  // TODO: Update only offline flag!!!
        .then { [weak self] _ -> Void in
            self?.showSnackBarMessage(R.string.localize.skillAddSnackBarMessage())
        }
        .catch { error in
            print("Error: \(error)")
        }
    }
    
    func promiseChangeSkillWith(_ rect: CGRect?, withSkill skill: Skill) throws {
        firstly {
            try AddViewController.promiseChangeSkillWith(self, rect: rect, skill: skill, preparedScene: self.preparedScene)
        }
        .then(execute: SkillEntity.promiseToUpdate)                  // Save change to local storage
        .then { savedEntity -> Promise<Skill> in
            return firstly {                                // Fetch changed
                Skill.fetchAll()
            }
            .then(on: DispatchQueue.main) { skills -> Void in
                self.skills = skills                        // Reload UI
                self.collectionView.reloadData()            // Reload UI
            }
            .then { _ -> Promise<Skill> in                  // Call and update to CloudKit
                // Handle update cases:
                if savedEntity.toDelete {
                    self.showSnackBarMessage(R.string.localize.skillDeleteSnackBarMessage())
                    return savedEntity.skill.promiseDeleteFrom(.private)
                }
                else {
                    self.showSnackBarMessage(R.string.localize.skillUpdateSnackBarMessage())
                    return savedEntity.skill.promiseSyncTo(.private)
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
        .catch { error in
            DDLogError("Error: \(error)")
        }
    }
    
    // MARK: - Helpers
    let colors = [
        (UIColor(netHex: 0x0b1518), UIColor(netHex: 0x25444d)),
        (UIColor(netHex: 0x122125), UIColor(netHex: 0x2b505a)),
        (UIColor(netHex: 0x182d32), UIColor(netHex: 0x315c68))
    ]
    
    func configureColorFor(_ cell: SkillCollectionViewCell) {
        var offset = cell.frame.origin
        offset.y -= self.collectionView.contentOffset.y
        offset.y = max(0, min(self.collectionView.bounds.height, offset.y))
        
        let factor = offset.y / self.collectionView.bounds.height;
        
        let topColor = self.colors[cell.column].0
        let botColor = self.colors[cell.column].1
        
        cell.backgroundColor = UIColor.interpolate(topColor, B: botColor, t: factor)
    }
    
    func frameForCell(_ cell: SkillCollectionViewCell) -> CGRect {
        cell.layoutSubviews()
        let imgfrm = cell.imageView.frame
        let rect = CGRect(
            origin: CGPoint(x: imgfrm.origin.x + cell.frame.origin.x, y: imgfrm.origin.y + cell.frame.origin.y - self.collectionView.contentOffset.y + self.collectionView.frame.origin.y),
            size: imgfrm.size
        )
        
        return self.view.convert(rect, to: self.view.window!)
    }
    
    // MARK: - Navigation
    
}

// MARK: - UICollectionViewDataSource
extension SkillsViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard section == 1 else {
            return self.skillsOffset
        }
        
        let cells = self.skills.count + 1
        return cells + ((3 - cells % 3) % 3)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard indexPath.section == 1 else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SkillCellIdentifier, for: indexPath) as! SkillCollectionViewCell
            cell.indexPath = indexPath
            cell.prepareForReuse()
            self.configureColorFor(cell)
            cell.setNeedsLayout()
            return cell
        }
        
        let cell : SkillCollectionViewCell = {
            if indexPath.row == self.skills.count {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AddSkillCellIdentifier, for: indexPath) as! SkillCollectionViewCell
                cell.prepareForReuse()
                cell.configureAsAddCell(indexPath)
                return cell
            }
            else if indexPath.row > self.skills.count {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SkillCellIdentifier, for: indexPath) as! SkillCollectionViewCell
                cell.prepareForReuse()
                cell.indexPath = indexPath
                return cell
            }
            else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SkillCellIdentifier, for: indexPath) as! SkillCollectionViewCell
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.section == 1 else {
            return
        }
        
        if indexPath.row < self.skills.count, let cell = self.collectionView.visibleCells.filter({
            $0 is SkillCollectionViewCell ? ($0 as! SkillCollectionViewCell).indexPath.row == indexPath.row : false
        }).first {
            self.changeSkillActionFromCell(cell, withSkill: self.skills[indexPath.row])
            return
        }
        if indexPath.row == self.skills.count , let cell = self.collectionView.visibleCells.filter({
            $0 is SkillCollectionViewCell ? ($0 as! SkillCollectionViewCell).indexPath.row == indexPath.row : false
        }).first {
            self.addSkillActionFromCell(cell)
            return
        }
    }
    
}

extension SkillsViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.collectionView.visibleCells.forEach {
            self.configureColorFor($0 as! SkillCollectionViewCell)
        }
    }
    
}

extension UIColor {
    
    static func interpolate(_ A:UIColor, B:UIColor, t: CGFloat) -> UIColor {
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
