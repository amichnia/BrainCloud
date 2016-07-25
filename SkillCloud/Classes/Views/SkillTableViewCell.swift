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
    @IBOutlet weak var skillImageView: UIImageView!
    
    func configureForSkill(skill: Skill) {
        self.titleLabel.text = skill.title
        self.skillImageView?.image = skill.circleImage
    }
    
}