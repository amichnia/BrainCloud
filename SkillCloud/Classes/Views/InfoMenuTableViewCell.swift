//
//  InfoMenuTableViewCell.swift
//  SkillCloud
//
//  Created by Andrzej Michnia on 10/08/16.
//  Copyright © 2016 amichnia. All rights reserved.
//

import UIKit

class InfoMenuTableViewCell: UITableViewCell {

    // MARK: - Outlets
    @IBOutlet weak var menuIconImage: UIImageView!
    @IBOutlet weak var itemTitle: UILabel!
    @IBOutlet weak var itemSubtitle: UILabel!

    // MARK: - Properties
    var icon: UIImage? {
        didSet {
            self.menuIconImage.image = self.icon?.imageWithRenderingMode(.AlwaysTemplate)
        }
    }
    
    // MARK: - Configuration
    func configureForItem(item: InfoMenuItem) {
        self.icon = item.icon()
        self.itemTitle.text = item.title()
        self.itemSubtitle.text = item.subtitle()
    }
    
}

enum InfoMenuItem {
    
    case Help
    case About
    case Licenses
    case Feedback
    case Rate
    
    static var allItems: [InfoMenuItem] = [Help,About,Licenses,Feedback,Rate]
    
    func title() -> String {
        switch self {
        case .Help:
            return NSLocalizedString("Help", comment: "Help")
        case .About:
            return NSLocalizedString("About", comment: "About")
        case .Licenses:
            return NSLocalizedString("Licenses", comment: "Licenses")
        case .Feedback:
            return NSLocalizedString("Feedback", comment: "Feedback")
        case .Rate:
            return NSLocalizedString("Rate", comment: "Rate")
        }
    }
    
    func subtitle() -> String {
        switch self {
        case .Help:
            return NSLocalizedString("How to use SkillCLoud application", comment: "How to use SkillCLoud application")
        case .About:
            return NSLocalizedString("About SkillCloud and GirAppe Studio", comment: "About SkillCloud and GirAppe Studio")
        case .Licenses:
            return NSLocalizedString("Licenses and 3rd party libraries", comment: "Licenses and 3rd party libraries")
        case .Feedback:
            return NSLocalizedString("Send us your feedback", comment: "Send us your feedback")
        case .Rate:
            return NSLocalizedString("Rate us on AppStore", comment: "Rate us on AppStore")
        }
    }
    
    func icon() -> UIImage? {
        switch self {
        case .Help:
            return UIImage(named: "icon-help")
        case .About:
            return UIImage(named: "icon-info")
        case .Licenses:
            return UIImage(named: "icon-licenses")
        case .Feedback:
            return UIImage(named: "icon-feedback")
        case .Rate:
            return UIImage(named: "icon-rate")
        }
    }
    
}