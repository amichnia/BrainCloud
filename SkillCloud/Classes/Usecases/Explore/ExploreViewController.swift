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
import Rswift

class ExploreViewController: UIViewController {
    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchBarLeading: NSLayoutConstraint!
    @IBOutlet weak var tableViewBottomConstraint: NSLayoutConstraint!

    // MARK: - Properties
    var skillsResult: CKPageableResult = CKPageableResult(type: Skill.self, skillsPredicate: SkillsPredicate.accepted, database: .public)
    var updating = false {
        didSet { self.tableView.reloadData() }
    }
    var preparedScene: AddScene?
    let menuOffset = 12
    var firstLayout = true

    var ownedSkills: [Skill] = []

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.rowHeight = 82

        (self.tableView as UIScrollView).delegate = self
        self.searchBar.placeholder = R.string.localize.exploreSearchPlaceholder()

        self.skillsResult.desiredKeys = ["name", "experienceValue", "thumbnail", "desc"]
        self.skillsResult.limit = 10

        debugPrint("Explore loaded - loading info")
        self.refetchSelfSkills()
        self.updateIfNeeded()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.refetchSelfSkills()

        if let scene = AddScene(fileNamed: "AddScene") {
            self.preparedScene = scene
            scene.size = self.view.bounds.size
        }

        updateUI()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if firstLayout {
            firstLayout = false

            let height = CGFloat(self.menuOffset) * self.tableView.rowHeight
            tableView.contentInset = UIEdgeInsets(top: -height, left: 0, bottom: -height, right: 0)

            tableView.setNeedsLayout()
            tableView.layoutIfNeeded()

            tableView.reloadData()
            tableView.visibleCells.forEach(configureColorFor)
        }
    }

    // MARK: - Actions
    func addSkillActionFromCell(_ cell: UITableViewCell, withSkill skill: Skill) {
        if let skillCell = cell as? SkillTableViewCell {
            let rect = self.frameForCell(skillCell)
            try! self.promiseShowSkillWith(rect, withSkill: skill)
        } else {
            try! self.promiseShowSkillWith(nil, withSkill: skill)
        }
    }

    // MARK: - Helpers
    @discardableResult fileprivate func updateIfNeeded() -> Promise<Void> {
        guard !self.updating else {
            return Promise<Void>(value: Void())
        }

        self.updating = true

        updateUI()

        return firstly {
            self.skillsResult.promiseNextPage()
        }
        .then { [weak self] _ -> Void in
            print("LOADED more!")
            self?.tableView.reloadData()
            if let strongSelf = self {
                self?.tableView.visibleCells.forEach(strongSelf.configureColorFor)
            }
        }
        .always { [weak self] in
            print("Update finished")
            self?.updating = false
        }
        .asVoid()
    }

    fileprivate func refetchSelfSkills() {
        firstly {
            Skill.fetchAll()
        }
        .then(on: DispatchQueue.main) { skills -> Void in
            self.ownedSkills = skills

            let height = CGFloat(self.menuOffset) * self.tableView.rowHeight
            self.tableView.contentInset = UIEdgeInsets(top: -height, left: 0, bottom: -height, right: 0)

            self.tableView.setNeedsLayout()
            self.tableView.layoutIfNeeded()

            self.tableView.reloadData()
            self.tableView.visibleCells.forEach(self.configureColorFor)
        }
        .catch { error in
            print("Error: \(error)")
        }
    }

    fileprivate func frameForCell(_ cell: SkillTableViewCell) -> CGRect {
        cell.layoutSubviews()
        let imgfrm = cell.skillImageView.frame
        let rect = CGRect(
                origin: CGPoint(x: imgfrm.origin.x + cell.frame.origin.x, y: imgfrm.origin.y + cell.frame.origin.y - self.tableView.contentOffset.y + self.tableView.frame.origin.y),
                size: imgfrm.size
        )

        return self.view.convert(rect, to: self.view.window!)
    }

    fileprivate func updateUI() {
        let backVisible = navigationItem.leftBarButtonItem != nil
        searchBarLeading.constant = backVisible ? 60 : 0
    }

    // MARK: - Table cells coloring
    let colors = [
        (UIColor(netHex: 0x0b1518), UIColor(netHex: 0x25444d)),
        (UIColor(netHex: 0x122125), UIColor(netHex: 0x2b505a)),
        (UIColor(netHex: 0x182d32), UIColor(netHex: 0x315c68))
    ]

    func configureColorFor(_ cell: UITableViewCell) {
        var offset = cell.frame.origin
        offset.y -= self.tableView.contentOffset.y
        offset.y = max(0, min(self.tableView.bounds.height, offset.y))

        let factor = offset.y / self.tableView.bounds.height;

        let topColor = self.colors[0].0
        let botColor = self.colors[0].1

        cell.backgroundColor = UIColor.interpolate(topColor, B: botColor, t: factor)
        cell.selectedBackgroundView?.backgroundColor = UIColor.interpolate(topColor, B: botColor, t: factor)
    }

    func configureLoaderFor(_ cell: UITableViewCell) {
        let tag = 121334
        guard let loader = cell.contentView.viewWithTag(tag) as? UIActivityIndicatorView else { return }

        if self.updating {
            loader.startAnimating()
        } else {
            loader.stopAnimating()
        }
    }

    // MARK: - Promises
    func promiseShowSkillWith(_ rect: CGRect?, withSkill skill: Skill) throws {
        MRProgressOverlayView.show()
        firstly {
            skill.fetchImage(from: .public)
        }
        .then { Void -> Promise<Void> in
            return MRProgressOverlayView.promiseHide()
        }
        .always {
            MRProgressOverlayView.hide()
        }
        .then { Void -> Promise<Skill> in
            return try AddViewController.promiseSelectSkillWith(self, rect: rect, skill: skill, preparedScene: self.preparedScene)
        }
        .then(execute: SkillEntity.promiseToUpdate)                  // Save change to local storage
        .then { [weak self] _ -> Void in
            self?.showSnackBarMessage(R.string.localize.skillAddSnackBarMessage())
            self?.refetchSelfSkills()
        }
        .catch { error in
            print("Error: \(error)")
        }
    }
}

// MARK: - UISearchBarDelegate
extension ExploreViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        search(with: searchBar.text)
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        search(with: searchBar.text)
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        guard searchBar.text?.isEmpty ?? true else { return }

        search(with: nil)
    }

    private func search(with text: String?) {
        let predicate: SkillsPredicate = {
            if let searchText = text, !searchText.isEmpty {
                return SkillsPredicate.whenAll([.accepted, .nameLike(searchText)])
            } else {
                return SkillsPredicate.accepted
            }
        }()

        skillsResult = CKPageableResult(type: Skill.self, skillsPredicate: predicate, database: .public)
        updateIfNeeded()
        .catch { error in
            print("Error: \(error)")
        }

        searchBar.resignFirstResponder()
    }
}

// MARK: - UITableViewDataSource
extension ExploreViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 1:
            return self.skillsResult.results.count
        default:
            return self.menuOffset
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard indexPath.section == 1 else {
            let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.emptyCell, for: indexPath)!
            configureColorFor(cell)
            if indexPath.section == 2, indexPath.row == 0 {
                configureLoaderFor(cell)
            }
            return cell
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.exploreSkillCell, for: indexPath)!

        let skill = self.skillsResult.results[indexPath.row]
        let owned = self.ownedSkills.filter { $0.title == skill.title }.first

        cell.configureForSkill(skill, owned: owned)
        cell.indexPath = indexPath
        configureColorFor(cell)

        return cell
    }
}

// MARK: - UITableViewDelegate
extension ExploreViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.section == 1 else {
            return
        }

        let skill = self.skillsResult.results[indexPath.row]

        if let cell = self.tableView.visibleCells.filter({
            $0 is SkillTableViewCell ? ($0 as! SkillTableViewCell).indexPath.row == indexPath.row : false
        }).first {
            let owned = self.ownedSkills.filter { $0.title == skill.title }.first
            skill.experience = owned?.experience
            self.addSkillActionFromCell(cell, withSkill: skill)
        }
    }
}

// MARK: - UIScrollViewDelegate
extension ExploreViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.tableView.visibleCells.forEach(configureColorFor)

        let bound = tableView.contentSize.height - (CGFloat(menuOffset) * tableView.rowHeight) - 200
        let offset = tableView.contentOffset.y + tableView.bounds.height

        guard !updating, offset >= bound, skillsResult.hasNextPage else {
            return
        }

        self.updating = true
        print("Loading more!")

        firstly {
            self.skillsResult.promiseNextPage()
        }
        .then { [weak self] _ -> Void in
            print("LOADED more!")
            self?.tableView.reloadData()
            if let strongSelf = self {
                self?.tableView.visibleCells.forEach(strongSelf.configureColorFor)
            }
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
