//
//  AddNewSkillTableViewCell.swift
//  Brain Cloud
//
//  Created by Andrzej Michnia on 17.03.2016.
//  Copyright © 2016 amichnia. All rights reserved.
//

import UIKit
import AMKSlidingTableViewCell

class SkillTableViewCell: MKActionTableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    func configureForSkill(skill: Skill) {
        self.titleLabel.text = skill.title
        self.imageView?.image = skill.image
    }
    
}