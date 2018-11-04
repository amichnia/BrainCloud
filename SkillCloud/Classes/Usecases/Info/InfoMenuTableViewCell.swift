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
    case privacyPolicy
    
    func title() -> String {
        switch self {
        case .help:
            return R.string.localize.infoOptionHelpTitle()
        case .about:
            return R.string.localize.infoOptionAboutTitle()
        case .licenses:
            return R.string.localize.infoOptionLicensesTitle()
        case .feedback:
            return R.string.localize.infoOptionFeedbackTitle()
        case .rate:
            return R.string.localize.infoOptionRateTitle()
        case .privacyPolicy:
            return R.string.localize.infoOptionPolicyTitle()
        }
    }
    
    func subtitle() -> String {
        switch self {
        case .help:
            return R.string.localize.infoOptionHelpSubtitle()
        case .about:
            return R.string.localize.infoOptionAboutSubtitle()
        case .licenses:
            return R.string.localize.infoOptionLicensesSubtitle()
        case .feedback:
            return R.string.localize.infoOptionFeedbackSubtitle()
        case .rate:
            return R.string.localize.infoOptionRateSubtitle()
        case .privacyPolicy:
            return R.string.localize.infoOptionPolicySubtitle()
        }
    }
    
    func icon() -> UIImage? {
        switch self {
        case .help:
            return R.image.iconHelp()
        case .about:
            return R.image.iconInfo()
        case .licenses:
            return R.image.iconLicenses()
        case .feedback:
            return R.image.iconFeedback()
        case .rate(let rated):
            return rated ? R.image.iconRated() : R.image.iconRate()
        case .privacyPolicy:
            return R.image.iconPolicy()
        }
    }
}
