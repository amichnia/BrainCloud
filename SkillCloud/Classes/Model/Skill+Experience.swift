//
// Copyright (c) 2017 amichnia. All rights reserved.
//

import UIKit
import PromiseKit

// MARK: - Experience
extension Skill {
    enum Experience: Int {
        case any = -1
        case beginner = 0
        case intermediate
        case professional
        case expert

        var image: UIImage? {
            switch self {
            case .beginner:
                return UIImage(named: "icon-skill-beginner")
            case .intermediate:
                return UIImage(named: "icon-skill-intermediate")
            case .professional:
                return UIImage(named: "icon-skill-professional")
            case .expert:
                return UIImage(named: "icon-skill-expert")
            default:
                return nil
            }
        }

        var radius: CGFloat {
            switch self {
            case .beginner:
                return 10
            case .intermediate:
                return 15
            case .professional:
                return 20
            case .expert:
                return 25
            default:
                return 0
            }
        }

        var name: String {
            switch self {
            case .any:
                return "Any"
            case .beginner:
                return "Beginner"
            case .intermediate:
                return "Intermediate"
            case .professional:
                return "Professional"
            case .expert:
                return "Expert"
            }
        }
    }
}
