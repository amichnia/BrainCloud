//
//  PrivacyDataViewController.swift
//  SkillCloud
//
//  Created by Andrzej Michnia on 04/11/2018.
//  Copyright © 2018 amichnia. All rights reserved.
//

import UIKit
import PromiseKit

class PrivacyDataViewController: UIViewController {
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

        textView.text = "Loading..."

        firstly {
            CloudContainer.sharedContainer.promiseAllData()
        }
        .then(on: DispatchQueue.main) { [weak self] data -> Void in
            self?.textView.text = data
        }
        .catch { [weak self] error in
            self?.textView.text = "Error: \(String(describing: error))\nPlease verify your internet conncetion and try again later."
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if self.firstLayout {
            self.textView.setContentOffset(CGPoint.zero, animated: false)
            self.firstLayout = false
        }
    }
}

