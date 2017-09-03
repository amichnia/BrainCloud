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
            self.menuIconImage.image = self.icon?.withRenderingMode(.alwaysTemplate)
        }
    }
    
    // MARK: - Configuration
    func configureForItem(_ item: InfoMenuItem) {
        self.icon = item.icon()
        self.itemTitle.text = item.title()
        self.itemSubtitle.text = item.subtitle()
    }
    
}

enum InfoMenuItem {
    
    case help
    case about
    case licenses
    case feedback
    case rate(rated: Bool)
    
    func title() -> String {
        switch self {
        case .help:
            return NSLocalizedString("Help", comment: "Help")
        case .about:
            return NSLocalizedString("About", comment: "About")
        case .licenses:
            return NSLocalizedString("Licenses", comment: "Licenses")
        case .feedback:
            return NSLocalizedString("Feedback", comment: "Feedback")
        case .rate:
            return NSLocalizedString("Rate", comment: "Rate")
        }
    }
    
    func subtitle() -> String {
        switch self {
        case .help:
            return NSLocalizedString("How to use SkillCLoud application", comment: "How to use SkillCLoud application")
        case .about:
            return NSLocalizedString("About SkillCloud and GirAppe Studio", comment: "About SkillCloud and GirAppe Studio")
        case .licenses:
            return NSLocalizedString("Licenses and 3rd party libraries", comment: "Licenses and 3rd party libraries")
        case .feedback:
            return NSLocalizedString("Send us your feedback", comment: "Send us your feedback")
        case .rate:
            return NSLocalizedString("Rate us on AppStore", comment: "Rate us on AppStore")
        }
    }
    
    func icon() -> UIImage? {
        switch self {
        case .help:
            return UIImage(named: "icon-help")
        case .about:
            return UIImage(named: "icon-info")
        case .licenses:
            return UIImage(named: "icon-licenses")
        case .feedback:
            return UIImage(named: "icon-feedback")
        case .rate(let rated):
            return UIImage(named: rated ? "icon-rated" : "icon-rate")
        }
    }
    
}
