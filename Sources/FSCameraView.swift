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
            buttonsContainer.sv(
                flipButton,
                shotButton,
                flashButton
            )
        )
        
        layout(
            0,
            |previewViewContainer.heightEqualsWidth()|,
            0,
            |buttonsContainer|,
            0
        )
        
        shotButton.centerVertically()
        shotButton.size(68).centerHorizontally()
        alignHorizontally(flipButton, shotButton, flashButton)
        |-15-flipButton.size(40)
        flashButton.size(40)-15-|
        backgroundColor = .clear
        
        previewViewContainer.backgroundColor = .black
    }
}
    


