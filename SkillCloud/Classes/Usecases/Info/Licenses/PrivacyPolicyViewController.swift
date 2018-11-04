//
//  PrivacyPolicyViewController.swift
//  SkillCloud
//
//  Created by Andrzej Michnia on 04/11/2018.
//  Copyright © 2018 amichnia. All rights reserved.
//

import UIKit
import TSMarkdownParser

class PrivacyPolicyViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var textView: UITextView!

    // MARK: - Properties
    var firstLayout = true

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

    // MARK: - Actions

    // MARK: - Navigation

}
