//
//  InfoViewController.swift
//  SkillCloud
//
//  Created by Andrzej Michnia on 10/08/16.
//  Copyright © 2016 amichnia. All rights reserved.
//

import UIKit
import MessageUI
import PromiseKit
import DRNSnackBar
import iRate

class InfoViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Properties
    let menuOffset = 6
    var firstLayout = true
    var menu: [InfoMenuItem] = []
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.menu = [.help,.about,.licenses,.feedback,.rate(rated: iRate.sharedInstance().ratedThisVersion)]
        (self.tableView as UIScrollView).delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        iRate.sharedInstance().delegate = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if firstLayout {
            firstLayout = false
            
            let rowHeight: CGFloat = self.tableView.bounds.height / CGFloat(self.menu.count)
            tableView.rowHeight = rowHeight
            
            let height = CGFloat(self.menuOffset) * self.tableView.rowHeight
            tableView.contentInset = UIEdgeInsets(top: -height, left: 0, bottom: -height, right: 0)
            
            tableView.setNeedsLayout()
            tableView.layoutIfNeeded()
            
            tableView.visibleCells.forEach(configureColorFor)
            tableView.reloadData()
        }
    }
    
    // MARK: - Actions
    func sendFeedback() {
        let mailComposeViewController = MFMailComposeViewController()
        
        mailComposeViewController.setToRecipients(["skillcloud@girappe.com"])
        mailComposeViewController.setSubject("SkillCloud Feedback")
        
        _ = self.promise(mailComposeViewController)
        .then { result -> Void in
            switch result {
            case MFMailComposeResult.sent:
                self.showSnackBarMessage(R.string.localize.feedbackSentSuccessSnackBarMessage())
            case MFMailComposeResult.failed:
                self.promiseHandleError(CommonError.failure(reason: R.string.localize.feedbackSentFailureSnackBarMessage()))
            default:
                break
            }
        }
        .catch { error in
            self.promiseHandleError(CommonError.other(error))
        }
    }
    
    // MARK: - Helpers
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
//        let selectedTopColor = self.colors[2].0
//        let selectedBotColor = self.colors[2].1
//        
//        cell.selectedBackgroundView?.backgroundColor = UIColor.interpolate(selectedTopColor, B: selectedBotColor, t: factor)
    }
    
}

// MARK: - UITableViewDataSource
extension InfoViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 1:
            return self.menu.count
        default:
            return self.menuOffset
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard indexPath.section == 1 else {
            return tableView.dequeueReusableCell(withIdentifier: "EmptyCell")!
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuCell") as! InfoMenuTableViewCell
        
        cell.selectedBackgroundView = UIView()
        
        cell.configureForItem(self.menu[indexPath.row])
        
        return cell
    }
    
}

// MARK: - UITableViewDelegate
extension InfoViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.section == 1 else {
            return
        }
        
        switch self.menu[indexPath.row] {
        case .help:
            self.tabBarController?.performSegue(withIdentifier: "ShowHelp", sender: self)
        case .about:
            self.performSegue(withIdentifier: "ShowAbout", sender: self)
        case .licenses:
            self.performSegue(withIdentifier: "ShowLicenses", sender: self)
        case .feedback:
            self.sendFeedback()
        case .rate:
            iRate.sharedInstance().delegate = self
            iRate.sharedInstance().promptForRating()
        }
        
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

// MARK: - UIScrollViewDelegate
extension InfoViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.tableView.visibleCells.forEach(configureColorFor)
    }
    
}

// MARK: - iRateDelegate
extension InfoViewController: iRateDelegate {
    
    func iRateDidOpenAppStore() {
        self.menu = [.help,.about,.licenses,.feedback,.rate(rated: iRate.sharedInstance().ratedThisVersion)]
        self.tableView.reloadData()
    }
    
}
