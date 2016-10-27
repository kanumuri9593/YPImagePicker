//
//  FSAlbumView.swift
//  Fusuma
//
//  Created by Yuta Akizuki on 2015/11/14.
//  Copyright © 2015年 ytakzk. All rights reserved.
//

import UIKit

final class FSAlbumView: UIView {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var imageCropView: FSImageCropView!
    @IBOutlet weak var imageCropViewContainer: UIView!
    
    @IBOutlet weak var collectionViewConstraintHeight: NSLayoutConstraint!
    @IBOutlet weak var imageCropViewConstraintTop: NSLayoutConstraint!
}





