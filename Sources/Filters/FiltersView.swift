//
//  FiltersView.swift
//  photoTaking
//
//  Created by Sacha Durand Saint Omer on 21/10/16.
//  Copyright © 2016 octopepper. All rights reserved.
//


import Stevia

class FiltersView: UIView {
    
    let imageView = UIImageView()
    var collectionView: UICollectionView!
    
    convenience init() {
        self.init(frame:CGRect.zero)
        collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout())
        
        sv(
            imageView,
            collectionView
        )
        
        layout(
            0,
            |imageView|,
            20,
            |collectionView| ~ 170
        )
        imageView.heightEqualsWidth()
        
        backgroundColor = UIColor(r: 247, g: 247, b: 247)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
    }
    
    func layout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 4
        layout.sectionInset = UIEdgeInsets(top: 0, left: 18, bottom: 0, right: 18)
        layout.itemSize = CGSize(width: 100, height: 125)
        return layout
    }
}
