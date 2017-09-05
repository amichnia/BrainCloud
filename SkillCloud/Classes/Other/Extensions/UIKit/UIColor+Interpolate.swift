//
// Copyright (c) 2017 amichnia. All rights reserved.
//

import UIKit

extension UIColor {
    static func interpolate(_ A:UIColor, B:UIColor, t: CGFloat) -> UIColor {
        var Argba : (CGFloat,CGFloat,CGFloat,CGFloat) = (0,0,0,0)
        var Brgba : (CGFloat,CGFloat,CGFloat,CGFloat) = (0,0,0,0)
        A.getRed(&Argba.0, green: &Argba.1, blue: &Argba.2, alpha: &Argba.3)
        B.getRed(&Brgba.0, green: &Brgba.1, blue: &Brgba.2, alpha: &Brgba.3)

        var rgba : (CGFloat,CGFloat,CGFloat,CGFloat) = (0,0,0,0)
        rgba.0 = (Argba.0 * (1-t)) + (Brgba.0 * t)
        rgba.1 = (Argba.1 * (1-t)) + (Brgba.1 * t)
        rgba.2 = (Argba.2 * (1-t)) + (Brgba.2 * t)
        rgba.3 = (Argba.3 * (1-t)) + (Brgba.3 * t)

        return UIColor(rgba: rgba)
    }
}
