//
//  SkillCollectionViewCell.swift
//  SkillCloud
//
//  Created by Andrzej Michnia on 19.03.2016.
//  Copyright © 2016 amichnia. All rights reserved.
//

import UIKit

class SkillCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Outlets
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var selectedView: UIImageView?
    @IBOutlet weak var nameLabel: UILabel!
    
    // MARK: - Properties
    var indexPath: NSIndexPath!
    var column: Int {
        return self.indexPath.row % 3
    }
    override var selected: Bool {
        didSet {
            self.selectedView?.hidden = !self.selected
        }
    }
    
    // MARK: - Lifecycle
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.imageView.image = nil
        self.nameLabel.text = ""
    }
    
    // MARK: - Configuration
    func configureAsAddCell(indexPath: NSIndexPath){
        self.indexPath = indexPath
        self.imageView.image = UIImage(named: "ic-plus")
        self.nameLabel.text = NSLocalizedString("Add new", comment: "Add new")
    }
    
    func configureWithSkill(skill: Skill, atIndexPath indexPath: NSIndexPath) {
        self.indexPath = indexPath
        self.nameLabel.text = skill.title
        self.imageView.image = skill.circleImage
    }
    
    func configureEmpty() {
        self.nameLabel.text = nil
        self.imageView.image = nil
    }
    
}
