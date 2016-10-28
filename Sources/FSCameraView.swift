//
//  FSCameraView.swift
//  Fusuma
//
//  Created by Yuta Akizuki on 2015/11/14.
//  Copyright © 2015年 ytakzk. All rights reserved.
//

import UIKit
import Stevia


class FSCameraView: UIView, UIGestureRecognizerDelegate {
    
    let previewViewContainer = UIView()
    let buttonsContainer = UIView()
    let flipButton = UIButton()
    let shotButton = UIButton()
    let flashButton = UIButton()
        
    //    @IBOutlet weak var croppedAspectRatioConstraint: NSLayoutConstraint!
    //    @IBOutlet weak var fullAspectRatioConstraint: NSLayoutConstraint!

    convenience init() {
        self.init(frame:CGRect.zero)
        
        sv(
            previewViewContainer,
            flashButton,
            flipButton,
            buttonsContainer.sv(
                shotButton
            )
        )
        
        layout(
            0,
            |previewViewContainer.heightEqualsWidth()|,
            0,
            |buttonsContainer|,
            0
        )
        
        layout(
            15,
            |-15-flashButton.size(40)
        )
        
        layout(
            15,
            flipButton.size(40)-15-|
        )
        
        shotButton.centerVertically()
        shotButton.size(68).centerHorizontally()
    
        backgroundColor = .clear
        
        previewViewContainer.backgroundColor = .black
    }
}
    


