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
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    // MARK: - Properties
    var image: UIImage?
    
    // MARK: - Lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.imageView.image = self.image
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.imageView.image = self.image
    }
    
    // MARK: - Actions
    @IBAction func exportAction(_ sender: AnyObject) {
        guard let image = self.image else {
            return
        }
        
        let activityVC = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        self.present(activityVC, animated: true, completion: nil)
    }
    
    @IBAction func saveAction(_ sender: AnyObject) {
        guard let image = self.image else {
            return
        }
        
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(imageSaveCompletedFor), nil)
    }
    
    func imageSaveCompletedFor(_ image: UIImage, error: NSError?, info: AnyObject?) {
        if let e = error {
            DDLogError("Error: \(e)")
        }
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Navigation

}

extension CloudExportViewController: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    
}
