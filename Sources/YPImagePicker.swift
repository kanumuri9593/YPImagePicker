//
//  YPImagePicker.swift
//  Fusuma
//
//  Created by Sacha Durand Saint Omer on 27/10/16.
//  Copyright © 2016 ytakzk. All rights reserved.
//

import UIKit

public class YPImagePicker: UINavigationController {
    
    public static var albumName = "DefaultYPImagePickerAlbumName" {
        didSet { PhotoSaver.albumName = albumName }
    }
    
    public var showsVideo = false
    public var usesFrontCamera: Bool {
        get { return fusuma.usesFrontCamera }
        set { fusuma.usesFrontCamera = newValue }
    }
    public var showsFilters = true
    public var didSelectImage:((UIImage) -> Void)?
    public var didSelectVideo:((Data) -> Void)?
    
    private let fusuma = FusumaVC()
    
    public func preheat() {
        _ = self.view
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        fusuma.showsVideo = showsVideo
        viewControllers = [fusuma]
        navigationBar.isTranslucent = false
        fusuma.didSelectImage = { [unowned self] pickedImage, isNewPhoto in
            if self.showsFilters {
                let filterVC = FiltersVC(image:pickedImage)
                filterVC.didSelectImage = { filteredImage, isImageFiltered in
                    self.didSelectImage?(filteredImage)
                    if isNewPhoto || isImageFiltered {
                        PhotoSaver.trySaveImage(filteredImage)
                    }
                }
                
                // Use Fade transition instead of default push animation
                let transition = CATransition()
                transition.duration = 0.3
                transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                transition.type = kCATransitionFade
                self.view.layer.add(transition, forKey: nil)
                
                self.pushViewController(filterVC, animated: false)
            } else {
                self.didSelectImage?(pickedImage)
                if isNewPhoto {
                    PhotoSaver.trySaveImage(pickedImage)
                }
            }
        }
        
        fusuma.didSelectVideo = { [unowned self] in
            if let videoData = FileManager.default.contents(atPath: $0.path) {
                self.didSelectVideo?(videoData)
            }
        }
        //force fusuma load view
        _ = fusuma.view
    }
}
