//
//  Copyright © 2017 amichnia. All rights reserved.
//

import UIKit

protocol HelpCollectionViewCellType {
    var image: UIImage? { get  set }
}

class HelpCollectionViewCell: UICollectionViewCell, HelpCollectionViewCellType {
    @IBOutlet weak var infoImageView: UIImageView!

    var image: UIImage? {
        get { return  infoImageView.image }
        set { infoImageView.image = newValue }
    }
}
