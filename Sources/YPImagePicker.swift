//
//  YPImagePicker.swift
//  Fusuma
//
//  Created by Sacha Durand Saint Omer on 27/10/16.
//  Copyright © 2016 ytakzk. All rights reserved.
//

import UIKit

public class YPImagePicker: UINavigationController {
    
    public var showsVideo = false
    public var usesFrontCamera = false
    public var startsOnCameraMode = false
    public var showsFilters = true
    public var didSelectImage:((UIImage) -> Void)?
    public var didSelectVideo:((URL) -> Void)?
    
    private let fusuma = FusumaVC()
    
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        fusuma.usesFrontCamera = usesFrontCamera
        fusuma.startsOnCameraMode = startsOnCameraMode
        fusuma.showsVideo = showsVideo
        
        viewControllers = [fusuma]
        
        navigationBar.isTranslucent = false
        
        
        fusuma.didSelectImage = { [unowned self] pickedImage, isNewPhoto in
            if self.showsFilters {
                let filterVC = FiltersVC(image:pickedImage)
                filterVC.didSelectImage = { filteredImage in
                    self.didSelectImage?(filteredImage)
                    UIImageWriteToSavedPhotosAlbum(filteredImage, nil, nil, nil)
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
                    UIImageWriteToSavedPhotosAlbum(pickedImage, nil, nil, nil)
                }
            }
        }
        
        fusuma.didSelectVideo = { [unowned self] in
            self.didSelectVideo?($0)
        }
    }
}
