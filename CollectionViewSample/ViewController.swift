//
//  ViewController.swift
//  CollectionViewSample
//
//  Created by Hajime Imamura on 2018/12/02.
//  Copyright © 2018 imamurh. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!

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
