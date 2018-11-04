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
    // MARK: - Properties
    var isSyncing: Bool = false
    var howToShown: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "howToShown")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "howToShown")
            UserDefaults.standard.synchronize()
        }
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBar.items?.forEach {
            $0.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
            $0.image = $0.image?.withRenderingMode(.alwaysOriginal)
            $0.selectedImage = $0.selectedImage?.withRenderingMode(.alwaysOriginal)
        }
        
        self.isSyncing = true
        firstly {
            CloudContainer().promiseSync()
        }
        .always {
            self.isSyncing = false
            MRProgressOverlayView.hide()
        }
        .catch { error in
            print("Error: \(error)")
        }

        loadTabs()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if !howToShown {
            howToShown = true
            performSegue(withIdentifier: R.segue.rootTabBarViewController.showHelp.identifier, sender: nil)
        } else if self.isSyncing {
            MRProgressOverlayView.show()
        }
    }

    private func loadTabs() {
        debugPrint("TABS:")
        debugPrint(viewControllers?.count ?? -1)
        viewControllers?.forEach {
            $0.view.setNeedsLayout()
            ($0 as? UINavigationController)?.viewControllers.forEach({
                $0.view.setNeedsLayout()
            })
        }
    }
}
