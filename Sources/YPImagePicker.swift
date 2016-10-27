//
//  YPImagePicker.swift
//  Fusuma
//
//  Created by Sacha Durand Saint Omer on 27/10/16.
//  Copyright © 2016 ytakzk. All rights reserved.
//

import UIKit


public class YPimagePicker: UINavigationController {
    
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
        
        
        fusuma.didSelectImage = { pickedImage in
            
            if self.showsFilters {
                let filterVC = FiltersVC(image:pickedImage)
                filterVC.didDissmissWithImage = { filteredImage in
                    print(filteredImage)
                }
                
                let transition = CATransition()
                transition.duration = 1 //0.1//0.5
                transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                transition.type = kCATransitionFade
                self.view.layer.add(transition, forKey: nil)
                
                
                self.pushViewController(filterVC, animated: false)
            } else {
                self.didSelectImage?(pickedImage)
                self.dismiss(animated: true, completion: nil)
            }
        }
        
        fusuma.didSelectVideo = {
            self.didSelectVideo?($0)
            self.dismiss(animated: true, completion: nil)
        }
    }
}
