//
//  SkillsViewController.swift
//  SkillCloud
//
//  Created by Andrzej Michnia on 19/04/16.
//  Copyright © 2016 amichnia. All rights reserved.
//

import UIKit

let AddSkillCellIdentifier = "AddSkillCell"
let SkillCellIdentifier = "SkillCell"

class SkillsViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: - Properties
    var skills : [Skill] = []
    var preparedScene : AddScene?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SkillEntity.fetchAll()
        .then { entities -> Void in
            self.skills = entities.mapExisting{ $0.skill }
            self.skills += self.skills // TODO: Remove later
            self.collectionView.reloadData()
            self.collectionView.visibleCells().forEach {
                self.configureColorFor($0 as! SkillCollectionViewCell)
            }
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
    }
    
    // MARK: - Actions
    @IBAction func addSkillAction(sender: UIBarButtonItem?) {
        let point = CGPoint(x: self.view.bounds.width - 20, y: self.view.bounds.height - 20)
        
        self.addSkillFromPoint(point)
    }
    
    func addSkillActionFromCell(cell: UICollectionViewCell) {
        var point = cell.bounds.centerOfMass
        point.x += cell.frame.origin.x
        point.y = self.view.bounds.height - (cell.frame.origin.y - self.collectionView.contentOffset.y) - point.y
        
        self.addSkillFromPoint(point)
    }
    
    func addSkillFromPoint(point: CGPoint){
        try! AddViewController.promiseNewSkillWith(self, point: point, preparedScene: self.preparedScene)
            .then(SkillEntity.promiseToInsert).asVoid()
            .then(SkillEntity.fetchAll)
            .then { entities -> Void in
                self.skills = entities.mapExisting{ $0.skill }
                self.skills += self.skills // TODO: Remove later
                self.collectionView.reloadData()
            }
            .error { error in
                print("Error: \(error)")
        }
    }
    
    // MARK: - Helpers
    let colors = [
        (UIColor(rgba: (69/255, 76/255, 89/255, 1)), UIColor(rgba: (88/255, 93/255, 102/255, 1))),
        (UIColor(rgba: (75/255, 81/255, 92/255, 1)), UIColor(rgba: (95/255, 100/255, 107/255, 1))),
        (UIColor(rgba: (82/255, 87/255, 97/255, 1)), UIColor(rgba: (102/255, 107/255, 113/255, 1)))
    ]
    
    func configureColorFor(cell: SkillCollectionViewCell) {
        let offset = self.collectionView.convertPoint(cell.frame.origin, toView: self.collectionView)
        var offsetY = offset.y - (self.collectionView.bounds.width / 3)
        offsetY = max(0, min(self.collectionView.bounds.height, offsetY))
        let factor = offsetY / self.collectionView.bounds.height;
        
        let topColor = self.colors[cell.column].0
        let botColor = self.colors[cell.column].1
        
        cell.backgroundColor = UIColor.interpolate(topColor, B: botColor, t: factor)
    }
    
    // MARK: - Navigation

}

// MARK: - UICollectionViewDataSource
extension SkillsViewController: UICollectionViewDataSource {
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.skills.count + 1
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        guard indexPath.row < self.skills.count else {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(AddSkillCellIdentifier, forIndexPath: indexPath) as! SkillCollectionViewCell
            cell.indexPath = indexPath
            return cell
        }
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(SkillCellIdentifier, forIndexPath: indexPath) as! SkillCollectionViewCell
        cell.configureWithSkill(self.skills[indexPath.row], atIndexPath: indexPath)
    
        return cell
    }
    
}

// MARK: - UICollectionViewDelegate
extension SkillsViewController: UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        guard indexPath.row < self.skills.count else {
            let cell = self.collectionView(self.collectionView, cellForItemAtIndexPath: indexPath)
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