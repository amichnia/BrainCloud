//
//  RootTabBarViewController.swift
//  SkillCloud
//
//  Created by Andrzej Michnia on 30/06/16.
//  Copyright © 2016 amichnia. All rights reserved.
//

import UIKit
import PromiseKit
import CloudKit
import MRProgress

class RootTabBarViewController: UITabBarController {

    // MARK: - Outlets
    
    // MARK: - Properties
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        MRProgressOverlayView.show()
        firstly {
            CloudContainer().promiseSync()
        }
        .always {
            MRProgressOverlayView.hide()
        }
        .error { error in
            print("Error: \(error)")
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    // MARK: - Actions
    
    // MARK: - Navigation
    
}
