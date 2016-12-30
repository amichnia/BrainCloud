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
    
    override var isSelected : Bool {
        didSet {
            self.checkmark.animate(checked: self.isSelected)
        }
    }
    
    // MARK: - Lifecycle
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.checkmark.animate(checked: false)
        self.imageView.image = nil
        self.spinner.stopAnimating()
        self.googleImage = nil
    }
    
    // MARK: - Configuration
    func configureWithGoogleImage(_ googleImage: GoogleImage) {
        self.googleImage = googleImage
        self.spinner.startAnimating()
        
        let _ = googleImage.promiseThumbnail().then { [weak self] image -> Void in
            guard let img = self?.googleImage, img === googleImage else {
                return
            }
            
            DispatchQueue.main.async() {
                self?.imageView.image = image
                self?.spinner.stopAnimating()
            }
        }
    }
    
    // MARK: - Actions
    @IBAction func selectAction(_ sender: ASIACheckmarkView) {
//        sender.animateTo(!sender.boolValue)
//        self.selected = !self.selected
    }
    
    
}
