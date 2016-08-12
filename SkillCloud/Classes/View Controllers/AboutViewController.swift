//
//  AboutViewController.swift
//  SkillCloud
//
//  Created by Andrzej Michnia on 11/08/16.
//  Copyright © 2016 amichnia. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet var tintedImages: [UIImageView]!
    
    // MARK: - Properties
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
     
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.tintedImages.forEach {
            $0.tintColor = UIColor.whiteColor()
            $0.image = $0.image?.imageWithRenderingMode(.AlwaysTemplate)
        }
    }
    
    // MARK: - Actions
    @IBAction func writeAction(sender: AnyObject) {
        
    }
    
    @IBAction func visitWebsite(sender: AnyObject) {
        UIApplication.sharedApplication().openURL(Defined.Application.StudioURL)
    }
    
    // MARK: - Navigation

}
