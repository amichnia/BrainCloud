//
//  LicensesViewController.swift
//  SkillCloud
//
//  Created by Andrzej Michnia on 11/08/16.
//  Copyright © 2016 amichnia. All rights reserved.
//

import UIKit
import TSMarkdownParser

class LicensesViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var textView: UITextView!
    
    // MARK: - Properties
    var firstLayout = true
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let path = Bundle.main.path(forResource: "Licenses", ofType: "md"), let licensesString = try? String(contentsOfFile: path) else {
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
