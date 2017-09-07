//
//  Copyright © 2017 amichnia. All rights reserved.
//

import UIKit
import Rswift
import LTMorphingLabel

struct HelpPage {
    let image: UIImage?
    let top: String
    let bottom: String
}

class HelpViewController: UIViewController {
    @IBOutlet weak var collectionView: PagedCollectionView!
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var topInfoLabel: LTMorphingLabel!
    @IBOutlet weak var bottomInfoLabel: LTMorphingLabel!
    @IBOutlet weak var pageControl: UIPageControl!

    var pages = [
        HelpPage(image: R.image.help.image1(), top: R.string.localize.helpPage1Top(), bottom: R.string.localize.helpPage1Bottom()),
        HelpPage(image: R.image.help.image2(), top: R.string.localize.helpPage2Top(), bottom: R.string.localize.helpPage2Bottom()),
        HelpPage(image: R.image.help.image3(), top: R.string.localize.helpPage3Top(), bottom: R.string.localize.helpPage3Bottom()),
        HelpPage(image: R.image.help.image4(), top: R.string.localize.helpPage4Top(), bottom: R.string.localize.helpPage4Bottom()),
        HelpPage(image: R.image.help.image5(), top: R.string.localize.helpPage5Top(), bottom: R.string.localize.helpPage5Bottom()),
        HelpPage(image: nil, top: "", bottom: "")
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        pageControl.numberOfPages = pages.count
        collectionView.pagedCollectionDelegate = self
        didSelectItem(atIndex: 0)
    }

    @IBAction func skipAction(_ sender: Any) {
        let root = self.presentingViewController as? RootTabBarViewController

        self.dismiss(animated: true) {
            root?.viewDidAppear(true)
        }
    }
}

extension HelpViewController: PagedCollectionViewDelegate {
    func didSelectItem(atIndex: Int) {
        pageControl.currentPage = atIndex
        let page = pages[atIndex]

        topInfoLabel.text = page.top
        bottomInfoLabel.text = page.bottom

        if atIndex == pages.count - 1 {
            skipAction(self)
        }
    }
}

extension HelpViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pages.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.helpCollectionViewCell, for: indexPath)!
        cell.image = pages[indexPath.row].image
        return cell
    }
}
