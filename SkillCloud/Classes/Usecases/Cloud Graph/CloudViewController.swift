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

let ShowPaletteSelectionSegueIdentifier = "ShowPaletteSelection"

class CloudViewController: UIViewController, SkillsProvider, UIPopoverPresentationControllerDelegate {
    // MARK: - Outlets
    @IBOutlet weak var collectionView: UICollectionView!

    // MARK: - Properties
    let pattern = [SkillLightCellIdentifier, SkillLighterCellIdentifier, SkillLighterCellIdentifier, SkillLightCellIdentifier]
    var skills: [Skill] = []
    var skillsOffset = 16
    var cloudImage: UIImage?
    var cloudEntity: GraphCloudEntity?
    var slot: Int!

    var skillToAdd: Skill?
    var selectedRow: Int = 0
    var collectionConfigured = false

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        SkillEntity.fetchAll()
        .then { entities -> Void in
            self.skills = entities.mapExisting { $0.skill }
            self.collectionView.reloadData()

            guard entities.count > 0 else {
                return
            }

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

        let height = floor(self.collectionView.bounds.height / 2)
        (self.collectionView.collectionViewLayout as! UICollectionViewFlowLayout).itemSize = CGSize(width: height, height: height)

        let sectionWidth = CGFloat((self.skillsOffset + self.skillsOffset % 4) / 2) * height

        self.collectionView.contentInset = UIEdgeInsets(top: 0, left: -sectionWidth, bottom: 0, right: -sectionWidth)
        self.collectionView.bounces = true
        self.collectionView.alwaysBounceHorizontal = true

        if !collectionConfigured {
            (self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.itemSize = CGSize(width: height, height: height)
            collectionConfigured = true
            collectionView.setNeedsLayout()
            collectionView.layoutIfNeeded()
            (self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.invalidateLayout()
        }
    }

    // MARK: - Helpers
    func scrollToItem(at indexPath: IndexPath) {
        guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
            return
        }

        guard let rect = layout.layoutAttributesForItem(at: indexPath)?.frame else {
            return
        }

        collectionView.scrollRectToVisible(rect, animated: true)
    }

    // MARK: - Navigation
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}

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
                let offset = self.collectionView(collectionView, numberOfItemsInSection: 1) % 4
                return self.pattern[(indexPath.row + offset) % 4]
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
        } else {
            cell.configureEmpty()
            cell.isSelected = false
        }

        return cell
    }
}

extension CloudViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.section == 1 && indexPath.row < self.skills.count else {
            return
        }

        self.skillToAdd = self.skills[indexPath.row]
        self.selectedRow = indexPath.row
    }
}

extension CloudViewController: CloudSceneDelegate {
    func didAddSkill() {
        let indexPath = IndexPath(item: selectedRow, section: 1)
        let newIndexPath = IndexPath(item: (indexPath.row + 1) % self.skills.count, section: 1)
        self.collectionView.deselectItem(at: indexPath, animated: false)
        collectionView(self.collectionView, didSelectItemAt: newIndexPath)
        collectionView.reloadItems(at: [indexPath, newIndexPath])

        scrollToItem(at: newIndexPath)
    }
}

enum SCError: Error {
    case createStreamError
    case invalidBundleResourceUrl
}
