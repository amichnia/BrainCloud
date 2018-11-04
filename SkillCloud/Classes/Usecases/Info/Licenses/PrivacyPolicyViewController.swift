//
//  PrivacyPolicyViewController.swift
//  SkillCloud
//
//  Created by Andrzej Michnia on 04/11/2018.
//  Copyright © 2018 amichnia. All rights reserved.
//

import UIKit
import PromiseKit
import TSMarkdownParser
import MRProgress

class PrivacyPolicyViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var textView: UITextView!

    // MARK: - Properties
    var firstLayout = true

    // MARK: - Appearance
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let path = Bundle.main.path(forResource: "PrivacyPolicy", ofType: "md"), let licensesString = try? String(contentsOfFile: path) else {
            assert(false)
            return
        }

        let parser = TSMarkdownParser.standard()
        self.textView.attributedText = parser.attributedString(fromMarkdown: licensesString, attributes: [NSForegroundColorAttributeName : UIColor.white])
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if self.firstLayout {
            self.textView.setContentOffset(CGPoint.zero, animated: false)
            self.firstLayout = false
        }
    }

    // MARK: - Herlpers
    private func showDeleteDataAlert() {
        let alert = UIAlertController(title: R.string.localize.policyDeleteConfirmTitle(),
                                      message: R.string.localize.policyDeleteConfirmMessage(),
                                      preferredStyle: .alert)
        let delete = UIAlertAction(title: R.string.localize.policyDeleteConfirmDelete(), style: .destructive) { [weak self] _ in
            self?.deleteAll()
        }
        let cancel = UIAlertAction(title: R.string.localize.alertCancel(), style: .default) { _ in }

        alert.addAction(delete)
        alert.addAction(cancel)

        present(alert, animated: true, completion: nil)
    }

    private func deleteAll() {
        MRProgressOverlayView.show()

        firstly {
            CloudContainer.sharedContainer.promiseDeleteAll()
        }
        .then { () -> Void in
            try DataManager.deleteAllEntities(SkillEntity.self)
            try DataManager.deleteAllEntities(SkillNodeEntity.self)
            try DataManager.deleteAllEntities(GraphCloudEntity.self)
            try DataManager.saveRootContext()
        }
        .always {
            MRProgressOverlayView.hide()
        }
        .catch { [weak self] error in
            self?.handle(error)
        }
    }

    private func handle(_ error: Error) {
        let alert = UIAlertController(title: R.string.localize.alertErrorTitle(), message: "\(String(describing: error))", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: R.string.localize.alertOk(), style: .default))
        present(alert, animated: true, completion: nil)
    }

    // MARK: - Actions
    @IBAction func accepted() {
        (presentingViewController as? RootTabBarViewController)?.policyAccepted = true
        (presentingViewController as? RootTabBarViewController)?.howToShown = true
    }

    @IBAction func showUserDataOptions() {
        let alert = UIAlertController(title: R.string.localize.policySettingsTitle(), message: nil, preferredStyle: .actionSheet)

        let download = UIAlertAction(title: R.string.localize.policySettingsOptionDownloadTitle(), style: .default) { [weak self] _ in
            self?.performSegue(withIdentifier: R.segue.privacyPolicyViewController.showData, sender: self)
        }
        let delete = UIAlertAction(title: R.string.localize.policySettingsOptionDeleteTitle(), style: .destructive) { [weak self] _ in
            self?.showDeleteDataAlert()
        }
        let cancel = UIAlertAction(title: R.string.localize.alertCancel(), style: .default) { _ in }

        alert.addAction(download)
        alert.addAction(delete)
        alert.addAction(cancel)

        present(alert, animated: true, completion: nil)
    }
}
