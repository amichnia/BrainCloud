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
    var skillsResult: CKPageableResult = CKPageableResult(type: Skill.self, skillsPredicate: SkillsPredicate.accepted, database: .public)
    var updating: Bool = false
    var preparedScene : AddScene?
    
    var ownedSkills: [Skill] = []
    
    lazy var searchCell: SkillsSearchTableViewCell = {
        return self.tableView.dequeueReusableCell(withIdentifier: "SearchSkillsHeader")! as! SkillsSearchTableViewCell
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.estimatedRowHeight = 76
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedSectionHeaderHeight = 40
        self.tableView.sectionHeaderHeight = UITableViewAutomaticDimension
        
        (self.tableView as UIScrollView).delegate = self
        
        self.skillsResult.desiredKeys = ["name","experienceValue","thumbnail","desc"]
        self.skillsResult.limit = 10
        
        self.refetchSelfSkills()
        _ = self.updateIfNeeded()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.refetchSelfSkills()
        
        if let scene = AddScene(fileNamed:"AddScene") {
            self.preparedScene = scene
            scene.size = self.view.bounds.size
        }
    }
    
    // MARK: - Actions
    func addSkillActionFromCell(_ cell: UITableViewCell, withSkill skill: Skill) {
        if let skillCell = cell as? SkillTableViewCell {
            let rect = self.frameForCell(skillCell)
            try! self.promiseShowSkillWith(rect, withSkill: skill)
        }
        else {
            try! self.promiseShowSkillWith(nil, withSkill: skill)
        }
    }
    
    // MARK: - Helpers
    func updateIfNeeded() -> Promise<Void> {
        guard !self.updating else {
            return Promise<Void>(value: Void())
        }
        
        self.updating = true
        
        MRProgressOverlayView.show()
        return firstly {
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
        .asVoid()
    }
    
    func refetchSelfSkills() {
        firstly {
            Skill.fetchAll()
        }
        .then(on: DispatchQueue.main) { skills -> Void in
            self.ownedSkills = skills
            self.tableView.reloadData()
        }
        .catch { error in
            print("Error: \(error)")
        }
    }
    
    func frameForCell(_ cell: SkillTableViewCell) -> CGRect {
        cell.layoutSubviews()
        let imgfrm = cell.skillImageView.frame
        let rect = CGRect(
            origin: CGPoint(x: imgfrm.origin.x + cell.frame.origin.x, y: imgfrm.origin.y + cell.frame.origin.y - self.tableView.contentOffset.y + self.tableView.frame.origin.y),
            size: imgfrm.size
        )
        
        return self.view.convert(rect, to: self.view.window!)
    }
    
    // MARK: - Promises
    func promiseShowSkillWith(_ rect: CGRect?, withSkill skill: Skill) throws {
        firstly {
            try AddViewController.promiseSelectSkillWith(self, rect: rect, skill: skill, preparedScene: self.preparedScene)
        }
        .then(execute: SkillEntity.promiseToUpdate)                  // Save change to local storage
        .then { [weak self] _ -> Void in
            self?.showSnackBarMessage(NSLocalizedString("New skill added.", comment: "New skill added."))
            self?.refetchSelfSkills()
        }
        .catch { error in
            print("Error: \(error)")
        }
    }
    
    // MARK: - Navigation

}

// MARK: - UISearchBarDelegate
extension ExploreViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let predicate: SkillsPredicate = {
            if let searchText = searchBar.text {
                return SkillsPredicate.whenAll([.accepted,.nameLike(searchText)])
            }
            else {
                return SkillsPredicate.accepted
            }
        }()
        
        self.searchCell.searchBar.resignFirstResponder()
        self.skillsResult = CKPageableResult(type: Skill.self, skillsPredicate: predicate, database: .public)
        self.updateIfNeeded()
        .catch { error in
            print("Error: \(error)")
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchCell.searchBar.resignFirstResponder()
        self.skillsResult = CKPageableResult(type: Skill.self, skillsPredicate: .accepted, database: .public)
        
        self.updateIfNeeded()
        .catch { error in
            print("Error: \(error)")
        }
    }
    
}

// MARK: - UITableViewDataSource
extension ExploreViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.skillsResult.results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SkillCell")! as! SkillTableViewCell
        
        let skill = self.skillsResult.results[indexPath.row]
        let owned = self.ownedSkills.filter{ $0.title == skill.title }.first
        
        cell.configureForSkill(skill, owned: owned)
        cell.indexPath = indexPath
        
        return cell
    }
    
}

// MARK: - UITableViewDelegate
extension ExploreViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        self.searchCell.searchBar.delegate = self
        return self.searchCell.contentView
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let skill = self.skillsResult.results[indexPath.row]

        if let cell = self.tableView.visibleCells.filter({
            $0 is SkillTableViewCell ? ($0 as! SkillTableViewCell).indexPath.row == indexPath.row : false
        }).first {
            let owned = self.ownedSkills.filter{ $0.title == skill.title }.first
            skill.experience = owned?.experience
            self.addSkillActionFromCell(cell, withSkill: skill)
        }
    }
    
}

// MARK: - UIScrollViewDelegate
extension ExploreViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
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
            .catch { error in
                print("Error: \(error)")
            }
        }
    }
    
}