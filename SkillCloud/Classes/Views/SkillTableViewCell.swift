//
//  AddNewSkillTableViewCell.swift
//  SkillCloud
//
//  Created by Andrzej Michnia on 17.03.2016.
//  Copyright © 2016 amichnia. All rights reserved.
//

import UIKit
import AMKSlidingTableViewCell

class SkillTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var skillImageView: UIImageView!
    
    var indexPath: IndexPath!
    
    func configureForSkill(_ skill: Skill, owned: Skill? = nil) {
        self.titleLabel.text = skill.title
        self.skillImageView?.image = skill.circleImage
        self.descriptionLabel.text = skill.skillDescription
        
        if let owned = owned, let image = owned.experience.image {
            let experienceImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
            experienceImageView.image = image
            self.accessoryView = experienceImageView
        }
        else {
            self.accessoryView = nil
        }
    }
    
}
