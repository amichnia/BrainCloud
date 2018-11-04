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

class CloudViewController: UIViewController, SkillsProvider, UIPopoverPresentationControllerDelegate {
    // MARK: - Outlets
    @IBOutlet weak var collectionView: UICollectionView!

    // MARK: - Properties
    let pattern = [
        R.reuseIdentifier.skillLightCell.identifier,
        R.reuseIdentifier.skillLighterCell.identifier,
        R.reuseIdentifier.skillLighterCell.identifier,
        R.reuseIdentifier.skillLightCell.identifier
    ]
    let addPattern = [
        R.reuseIdentifier.addSkillCellLight.identifier,
        R.reuseIdentifier.addSkillCellLighter.identifier,
        R.reuseIdentifier.addSkillCellLighter.identifier,
        R.reuseIdentifier.addSkillCellLight.identifier
    ]
    var skills: [Skill] = []
    var skillsOffset = 16
    var cloudImage: UIImage?
    var cloudEntity: GraphCloudEntity?
    var slot: Int!
    var preparedScene : AddScene?

    var skillToAdd: Skill?
    var selectedRow: Int = 0
    var firstConfigure = true

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        SkillEntity.fetchAll()
        .then { entities -> Void in
            self.skills = entities.mapExisting { $0.skill }
            self.skillToAdd = self.skills.first
            self.collectionView.reloadData()
        }
        .catch { error in
            print("Error: \(error)")
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let scene = AddScene(fileNamed:"AddScene") {
            self.preparedScene = scene
            scene.size = self.view.bounds.size
        }

        MRProgressOverlayView.hide()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let height = floor(self.collectionView.bounds.height / 2)
        (self.collectionView.collectionViewLayout as! UICollectionViewFlowLayout).itemSize = CGSize(width: height, height: height)
        let itemSize = CGSize(width: height, height: height)

        guard let layout = self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
            fatalError()
        }

        let itemSizeChanged = itemSize.width != layout.itemSize.width || itemSize.height != layout.itemSize.height

        guard itemSizeChanged || firstConfigure else { return }

        firstConfigure = false

        let sectionWidth = CGFloat((self.skillsOffset + self.skillsOffset % 4) / 2) * height

        self.collectionView.contentInset = UIEdgeInsets(top: 0, left: -sectionWidth, bottom: 0, right: -sectionWidth)
        self.collectionView.bounces = true
        self.collectionView.alwaysBounceHorizontal = true

        layout.itemSize = itemSize
        collectionView.setNeedsLayout()
        collectionView.layoutIfNeeded()
        layout.invalidateLayout()
        collectionView.setContentOffset(CGPoint(x: sectionWidth, y: 0), animated: false)
    }

    // MARK: - Helpers
    fileprivate func scrollToItem(at indexPath: IndexPath) {
        guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
            return
        }

        guard let rect = layout.layoutAttributesForItem(at: indexPath)?.frame else {
            return
        }

        collectionView.scrollRectToVisible(rect, animated: true)
    }

    fileprivate func frameForCell(_ cell: SkillCollectionViewCell) -> CGRect {
        cell.layoutSubviews()
        let imgfrm = cell.imageView.frame
        let rect = CGRect(
            origin: CGPoint(x: imgfrm.origin.x + cell.frame.origin.x - collectionView.contentOffset.x,
                            y: imgfrm.origin.y + cell.frame.origin.y - collectionView.contentOffset.y + collectionView.frame.origin.y),
            size: imgfrm.size
        )

        let final = self.collectionView.superview!.convert(rect, to: self.view.window!)
        return final
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
            self.skillToAdd = savedEntity.skill

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

    // MARK: - Actions
    func addSkillActionFromCell(_ cell: UICollectionViewCell) {
        if let skillCell = cell as? SkillCollectionViewCell {
            let rect = self.frameForCell(skillCell)
            try! self.promiseAddSkillWith(rect)
        }
        else {
            try! self.promiseAddSkillWith(nil)
        }
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

        let cells = self.skills.count + 1
        return cells + (cells % 2)
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let identifier = cellIdentifier(for: indexPath)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! SkillCollectionViewCell

        if indexPath.section == 1, indexPath.row < self.skills.count {
            cell.configureWithSkill(self.skills[indexPath.row], atIndexPath: indexPath)
            cell.isSelected = indexPath.row == selectedRow
        } else if indexPath.section == 1, indexPath.row == skills.count {
            cell.configureAsAddCell(indexPath)
        } else {
            cell.configureEmpty(indexPath: indexPath)
            cell.isSelected = false
        }

        return cell
    }

    private func cellIdentifier(for indexPath: IndexPath) -> String {
        switch indexPath.section {
            case 2:
                let offset = self.collectionView(collectionView, numberOfItemsInSection: 1) % 4
                return self.pattern[(indexPath.row + offset) % 4]
            case 1 where indexPath.row < skills.count:
                return self.pattern[indexPath.row % 4]
            case 1 where indexPath.row == skills.count:
                return self.addPattern[indexPath.row % 4]
            default:
                return self.pattern[indexPath.row % 4]
        }
    }
}

extension CloudViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.section == 1 && indexPath.row <= self.skills.count else {
            return
        }

        if indexPath.row < skills.count {
            guard indexPath.row != selectedRow else { return }

            skillToAdd = skills[indexPath.row]
            let lastIndex = IndexPath(row: selectedRow, section: 1)
            selectedRow = indexPath.row
            collectionView.reloadItems(at: [indexPath, lastIndex])
        } else if indexPath.row == skills.count {
            guard let cell = self.collectionView.visibleCells.first(where: {
                guard let cell  = $0 as? SkillCollectionViewCell else { return false }
                return cell.applies(to: indexPath)
            }) else {
                return
            }

            addSkillActionFromCell(cell)
        }
    }
}

extension CloudViewController: CloudSceneDelegate {
    func didAddSkill() {
        let indexPath = IndexPath(item: selectedRow, section: 1)
        let newIndexPath = IndexPath(item: (indexPath.row + 1) % self.skills.count, section: 1)
        self.collectionView.deselectItem(at: indexPath, animated: false)
        collectionView(self.collectionView, didSelectItemAt: newIndexPath)
        collectionView.reloadSections([1])

        scrollToItem(at: newIndexPath)
    }
}

enum SCError: Error {
    case createStreamError
    case invalidBundleResourceUrl
}
