//
//  FSAlbumViewCell.swift
//  Fusuma
//
//  Created by Yuta Akizuki on 2015/11/14.
//  Copyright © 2015年 ytakzk. All rights reserved.
//

import UIKit
import Photos

final class FSAlbumViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    var image: UIImage? {
        didSet {
            imageView.image = image
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        isSelected = false
    }
    
    override var isSelected : Bool {
        didSet {
            layer.borderColor = isSelected ? fusumaTintColor.cgColor : UIColor.clear.cgColor
            layer.borderWidth = isSelected ? 2 : 0
        }
    }
}
