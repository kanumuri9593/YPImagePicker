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
    let timeElapsedLabel = UILabel()
    let progressBar = UIProgressView()
    //    @IBOutlet weak var croppedAspectRatioConstraint: NSLayoutConstraint!
    //    @IBOutlet weak var fullAspectRatioConstraint: NSLayoutConstraint!

    convenience init() {
        self.init(frame:CGRect.zero)
        
        sv(
            previewViewContainer,
            progressBar,
            timeElapsedLabel,
            flashButton,
            flipButton,
            buttonsContainer.sv(
                shotButton
            )
        )
        
        layout(
            0,
            |previewViewContainer.heightEqualsWidth()|,
            -2,
            |progressBar|,
            0,
            |buttonsContainer|,
            0
        )
        
        layout(
            15,
            |-15-flashButton.size(42)
        )
        
        layout(
            15,
            flipButton.size(42)-15-|
        )
        
        addConstraint(item: timeElapsedLabel, attribute: .bottom,
                      toItem: previewViewContainer, constant: -15)
        
        timeElapsedLabel-15-|
        
        shotButton.centerVertically()
        shotButton.size(84).centerHorizontally()
        
        backgroundColor = .clear
        previewViewContainer.backgroundColor = .black
        timeElapsedLabel.style { l in
            l.textColor = .white
            l.text = "00:00"
            l.isHidden = true
            l.font = .monospacedDigitSystemFont(ofSize: 13, weight: UIFontWeightMedium)
        }
        progressBar.trackTintColor = .clear
        progressBar.tintColor = .red
    }
}
    


