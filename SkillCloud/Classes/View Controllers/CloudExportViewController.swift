//
//  CloudExportViewController.swift
//  SkillCloud
//
//  Created by Andrzej Michnia on 29.05.2016.
//  Copyright © 2016 amichnia. All rights reserved.
//

import UIKit
import PromiseKit

class CloudExportViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    // MARK: - Properties
    var image: UIImage?
    
    // MARK: - Lifecycle
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.imageView.image = self.image
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.imageView.image = self.image
    }
    
    // MARK: - Actions
    @IBAction func saveAction(sender: AnyObject) {
        guard let image = self.image else {
            return
        }
        
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(imageSaveCompletedFor), nil)
    }
    
    func imageSaveCompletedFor(image: UIImage, error: NSError?, info: AnyObject?) {
        if let e = error {
            DDLogError("Error: \(e)")
        }
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    // MARK: - Navigation

}
