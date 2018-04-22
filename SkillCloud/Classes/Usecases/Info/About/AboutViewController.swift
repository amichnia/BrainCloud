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
            $0.tintColor = UIColor.white
            $0.image = $0.image?.withRenderingMode(.alwaysTemplate)
        }
    }
    
    // MARK: - Actions
    @IBAction func writeAction(_ sender: AnyObject) {
        
    }
    
    @IBAction func visitWebsite(_ sender: AnyObject) {
        UIApplication.shared.openURL(Defined.Application.StudioURL)
    }
    
    // MARK: - Navigation

}
