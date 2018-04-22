import UIKit

protocol PagedCollectionViewDelegate: class {
    func didSelectItem(atIndex: Int)
}

class PagedCollectionView: UICollectionView {
    weak var pagedCollectionDelegate: PagedCollectionViewDelegate?
    var marginFactor: CGFloat = 0.1

    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        guard let layout = self.collectionViewLayout as? UICollectionViewFlowLayout else {
            fatalError("collection view flow layout should be kind of `UICollectionViewFlowLayout`")
        }

        layout.itemSize = bounds.size

        guard let pagedLayout = layout as? PagedCollectionViewFlowLayout else {
            return
        }

        pagedLayout.margin = bounds.width * marginFactor
    }

    func setup() {
        let scrollView = self as UIScrollView
        scrollView.delegate = self

        guard let layout = self.collectionViewLayout as? UICollectionViewFlowLayout else {
            fatalError("collection view flow layout should be kind of `UICollectionViewFlowLayout`")
        }

        layout.itemSize = bounds.size
        contentInset = .zero
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.scrollDirection = .horizontal
    }
}

extension PagedCollectionView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        collectionViewLayout.invalidateLayout()
        select(at: resolvedIndexPath())
    }

    private func resolvedIndexPath() -> IndexPath? {
        let cell = self.visibleCells.map { (cell) -> (CGSize, UICollectionViewCell) in
            return (self.bounds.intersection(cell.frame.intersection(self.bounds)).size, cell)
        }.max { (lhs, rhs) -> Bool in
            return lhs.0.width < rhs.0.width
        }?.1

        guard let foundCell = cell, let indexPath = self.indexPath(for: foundCell) else {
            return nil
        }

        return indexPath
    }

    private func select(at indexPath: IndexPath?) {
        guard let indexPath = indexPath else { return }

        pagedCollectionDelegate?.didSelectItem(atIndex: indexPath.row)
    }
}

class PagedCollectionViewFlowLayout: UICollectionViewFlowLayout {
    var minScale: CGFloat = 0.8
    var maxScale: CGFloat = 1.0
    var margin: CGFloat = 20
    var overlapFactor: CGFloat = 8 / 5

    private var itemOffset: CGFloat {
        return margin * overlapFactor
    }
    private var currentOffset: CGPoint {
        return self.collectionView?.contentOffset ?? .zero
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let attributesArray = super.layoutAttributesForElements(in: rect) else {
            return nil
        }

        guard margin > 0 else {
            return attributesArray
        }

        return attributesArray.map { attributes -> UICollectionViewLayoutAttributes in
            guard attributes.frame.width > 0 else { return attributes }

            let itemFrame = attributes.frame
            let offset = itemFrame.origin.x - currentOffset.x
            let callibration = offset / itemSize.width
            let finalFrame = itemFrame
            let absCallibration = Swift.max(Swift.min((1 - Swift.abs(callibration)),1),0)
            let scale = minScale + (maxScale - minScale) * absCallibration
            let translation = callibration >= 0 ? -(itemSize.width - (scale * itemSize.width)) : (itemSize.width - (scale * itemSize.width))
            let transform = CGAffineTransform(scaleX: scale, y: scale).translatedBy(x: translation / 2, y: 0)

            let newAttributes = UICollectionViewLayoutAttributes(forCellWith: attributes.indexPath)
            newAttributes.frame = finalFrame
            newAttributes.transform = transform
            
            return newAttributes
        }
    }
}
