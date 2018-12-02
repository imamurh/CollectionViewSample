//
//  ViewController.swift
//  CollectionViewSample
//
//  Created by Hajime Imamura on 2018/12/02.
//  Copyright © 2018 imamurh. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!{
        didSet {
            collectionView.setCollectionViewLayout(CustomFlowLayout(), animated: false)
        }
    }

    enum CellType: String {
        case red
        case green
        case blue

        static func random() -> CellType {
            switch arc4random_uniform(3) {
            case 0: return .red
            case 1: return .green
            default: return .blue
            }
        }
    }

    struct ItemData {
        var cellType: CellType
    }

    struct SectionData {
        var items: [ItemData]

        mutating func deleteItems(cellType: CellType) {
            items = items.filter { $0.cellType == cellType }
        }
    }

    lazy var sections: [SectionData] = {
        return (1...10).enumerated().map { _ in
            return SectionData(items: (1...150).enumerated().map { _ in
                return ItemData(cellType: .random())
            })
        }
    }()

    func deleteItems(cellType: CellType, at section: Int) {
        guard section < sections.count else { return }
        let indexPaths: [IndexPath] = sections[section].items.enumerated().compactMap { (index, item) in
            guard item.cellType != cellType else { return nil }
            return IndexPath(item: index, section: section)
        }
        sections[section].deleteItems(cellType: cellType)
        collectionView.deleteItems(at: indexPaths)
    }
}

extension ViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sections[section].items.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = sections[indexPath.section].items[indexPath.item]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: item.cellType.rawValue, for: indexPath)
        return cell
    }
}

extension ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = sections[indexPath.section].items[indexPath.item]
        deleteItems(cellType: item.cellType, at: indexPath.section)
    }
}

class CustomFlowLayout: UICollectionViewFlowLayout {

    var minIndexPath: IndexPath?
    var maxIndexPath: IndexPath?

    override func prepare(forCollectionViewUpdates updateItems: [UICollectionViewUpdateItem]) {
        print("prepare(forCollectionViewUpdates:)")
        super.prepare(forCollectionViewUpdates: updateItems)
        guard
            let minIndexPath = updateItems.compactMap({ $0.indexPathBeforeUpdate ?? $0.indexPathAfterUpdate }).min(),
            let maxIndexPath = updateItems.compactMap({ $0.indexPathBeforeUpdate ?? $0.indexPathAfterUpdate }).max()
            else { return }
        print("    min index path:", minIndexPath)
        print("    max index path:", maxIndexPath)
        self.minIndexPath = minIndexPath
        self.maxIndexPath = maxIndexPath
    }

    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint) -> CGPoint {
        print("targetContentOffset(forProposedContentOffset:)")
        let targetContentOffset = super.targetContentOffset(forProposedContentOffset: proposedContentOffset)
        guard let collectionView = collectionView,
            let minIndexPath = minIndexPath,
            let maxIndexPath = maxIndexPath,
            let minAttributes = layoutAttributesForItem(at: minIndexPath),
            let maxAttributes = layoutAttributesForItem(at: maxIndexPath)
            else { return targetContentOffset }

        let viewTop = collectionView.contentOffset.y
        let viewBottom = viewTop + collectionView.frame.size.height
        print("        view range: \(viewTop) - \(viewBottom)")

        let updateTop = minAttributes.frame.origin.y
        let updateBottom = maxAttributes.frame.origin.y
        print("      update range: \(updateTop) - \(updateBottom)")

        let currentHeight = collectionView.contentSize.height
        let newHeight = collectionViewContentSize.height
        print("    current height:", currentHeight)
        print("        new height:", newHeight)

        if currentHeight > newHeight,
            viewBottom > updateBottom {
            let diff = currentHeight - newHeight
            return CGPoint(x: targetContentOffset.x,
                           y: max(collectionView.contentOffset.y - diff, 0))
        }
        return targetContentOffset
    }

    override func finalizeCollectionViewUpdates() {
        print("finalizeCollectionViewUpdates()")
        super.finalizeCollectionViewUpdates()
        minIndexPath = nil
        maxIndexPath = nil
    }
}
