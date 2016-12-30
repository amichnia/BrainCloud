//
//  TestViewController.swift
//  SkillCloud
//
//  Created by Andrzej Michnia on 01.04.2016.
//  Copyright © 2016 amichnia. All rights reserved.
//

import UIKit
import SpriteKit
import PromiseKit
import MRProgress
import iRate

let SkillLightCellIdentifier = "SkillLightCell"
let SkillLighterCellIdentifier = "SkillLighterCell"

let ShowExportViewSegueIdentifier = "ShowExportView"
let ShowPaletteSelectionSegueIdentifier = "ShowPaletteSelection"

class CloudViewController: UIViewController, SkillsProvider, UIPopoverPresentationControllerDelegate {

    // MARK: - Outlets
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: - Properties
    let pattern = [SkillLightCellIdentifier,SkillLighterCellIdentifier,SkillLighterCellIdentifier,SkillLightCellIdentifier]
    var skills : [Skill] = []
    var skillsOffset = 16
    var cloudImage: UIImage?
    var cloudEntity: GraphCloudEntity?
    var slot: Int!
    
    var skillToAdd : Skill?
    var selectedRow: Int = 0
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SkillEntity.fetchAll()
        .then { entities -> Void in
            self.skills = entities.mapExisting{ $0.skill }
            self.collectionView.reloadData()
            let initialIndex = IndexPath(item: 0, section: 1)
            self.collectionView.selectItem(at: initialIndex, animated: false, scrollPosition: .centeredHorizontally)
            self.collectionView(self.collectionView, didSelectItemAt: initialIndex)
        }
        .catch { error in
            print("Error: \(error)")
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let height = ceil(self.collectionView.bounds.height/2)
        (self.collectionView.collectionViewLayout as! UICollectionViewFlowLayout).itemSize = CGSize(width: height, height: height)
        
        let sectionWidth = CGFloat((self.skillsOffset + self.skillsOffset % 4) / 2) * height
        
        self.collectionView.contentInset = UIEdgeInsets(top: 0, left: -sectionWidth, bottom: 0, right: -sectionWidth)
        self.collectionView.bounces = true
        self.collectionView.alwaysBounceHorizontal = true
    }
    
    // MARK: - Navigation
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
}

// MARK: - UICollectionViewDataSource
extension CloudViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard section == 1 else {
            return self.skillsOffset
        }
        
        let cells = self.skills.count
        return cells + (cells % 2)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let identifier: String = {
            switch indexPath.section {
            case 2:
                let offset = self.collectionView(collectionView, numberOfItemsInSection: 1) % 2
                return self.pattern[(indexPath.row + (2 * offset)) % 4]
            default:
                return self.pattern[indexPath.row % 4]
            }
        }()
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! SkillCollectionViewCell
        
        if indexPath.section == 1 && indexPath.row < self.skills.count {
            cell.configureWithSkill(self.skills[indexPath.row], atIndexPath: indexPath)
            if indexPath.row == self.selectedRow {
                cell.isSelected = true
            }
        }
        else {
            cell.configureEmpty()
            cell.isSelected = false
        }
        
        return cell
    }
    
}

// MARK: - UICollectionViewDelegate
extension CloudViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.section == 1 && indexPath.row < self.skills.count else {
            return
        }
        
        self.skillToAdd = self.skills[indexPath.row]
        self.selectedRow = indexPath.row
        CloudGraphScene.radius = self.skillToAdd!.experience.radius / Node.scaleFactor
    }
    
}

extension CloudViewController: CloudSceneDelegate {
    
    func didAddSkill() {
        if var indexPath = self.collectionView.indexPathsForSelectedItems?.first {
            self.collectionView.deselectItem(at: indexPath, animated: false)
            indexPath = IndexPath(item: (indexPath.row + 1) % self.skills.count , section: indexPath.section)
            self.collectionView.selectItem(at: indexPath, animated: false, scrollPosition: UICollectionViewScrollPosition())
            self.collectionView(self.collectionView, didSelectItemAt: indexPath)
            self.collectionView.setContentOffset(CGPoint(x:  (80 * CGFloat(self.skillsOffset / 2) + (CGFloat(indexPath.row / 2) * 80)), y: 0), animated: true)
        }
    }
    
}

enum SCError : Error {
    case createStreamError
    case invalidBundleResourceUrl
}




