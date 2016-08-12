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
    var isSyncing: Bool = false
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBar.items?.forEach {
            $0.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
            $0.image = $0.image?.imageWithRenderingMode(.AlwaysOriginal)
            $0.selectedImage = $0.selectedImage?.imageWithRenderingMode(.AlwaysOriginal)
        }
        
        self.isSyncing = true
        firstly {
            CloudContainer().promiseSync()
        }
        .always {
            self.isSyncing = false
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
        
        if self.isSyncing {
            MRProgressOverlayView.show()
        }
    }
    
    // MARK: - Actions
    
    // MARK: - Navigation
    
}
