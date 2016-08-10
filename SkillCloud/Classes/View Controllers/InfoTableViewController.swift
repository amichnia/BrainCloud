//
//  InfoTableViewController.swift
//  SkillCloud
//
//  Created by Andrzej Michnia on 10/08/16.
//  Copyright © 2016 amichnia. All rights reserved.
//

import UIKit

class InfoTableViewController: UITableViewController {

    // MARK: - Outlets
    @IBOutlet var tintedIcons: [UIImageView]!
    
    // MARK: - Properties
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let imageView = UIImageView(frame: self.tableView.bounds)
        imageView.image = UIImage(named: "background-image")
        imageView.contentMode = .ScaleAspectFill
        self.tableView.backgroundView = imageView
        
        self.tintedIcons.forEach {
            $0.tintColor = UIColor.whiteColor()
            $0.image = $0.image?.imageWithRenderingMode(.AlwaysTemplate)
        }
    }
    
    // MARK: - Actions
    
    // MARK: - Navigation

}
