//
//  GoogleImageCollectionViewCell.swift
//  SkillCloud
//
//  Created by Andrzej Michnia on 06/04/16.
//  Copyright © 2016 amichnia. All rights reserved.
//

import UIKit
import ASIACheckmarkView

let GoogleImageCellIdentifier = "GoogleImageCell"

class GoogleImageCollectionViewCell: UICollectionViewCell {
 
    // MARK: - Outlets
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var checkmark: ASIACheckmarkView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    // MARK: - Properties
    var googleImage : GoogleImage?
    
    // MARK: - Lifecycle
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.imageView.image = nil
        self.spinner.stopAnimating()
        self.googleImage = nil
    }
    
    // MARK: - Configuration
    func configureWithGoogleImage(googleImage: GoogleImage) {
        self.googleImage = googleImage
        self.spinner.startAnimating()
        
        googleImage.promiseThumbnail().then { [weak self] image -> Void in
            guard let img = self?.googleImage where img === googleImage else {
                return
            }
            
            dispatch_async(dispatch_get_main_queue()) {
                self?.imageView.image = image
                self?.spinner.stopAnimating()
            }
        }
    }
    
    // MARK: - Actions
    @IBAction func selectAction(sender: ASIACheckmarkView) {
        sender.animateTo(!sender.boolValue)
    }
    
    
}