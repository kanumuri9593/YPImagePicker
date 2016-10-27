//
//  FSVideoCameraView.swift
//  Fusuma
//
//  Created by Brendan Kirchner on 3/18/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit
import Stevia

class FSVideoView: UIView, UIGestureRecognizerDelegate {
    
    let previewViewContainer = UIView()
    let flipButton = UIButton()
    let shotButton = UIButton()
    let flashButton = UIButton()
    
    convenience init() {
        self.init(frame:CGRect.zero)
        
        sv(
            previewViewContainer,
            flipButton,
            shotButton,
            flashButton
        )
        
        layout(
            0,
            |previewViewContainer.heightEqualsWidth()|,
            16,
            shotButton.size(68).centerHorizontally()
        )
        alignHorizontally(flipButton, shotButton, flashButton)
        |-15-flipButton.size(40)
        flashButton.size(40)-15-|
        backgroundColor = .clear
    }
}
