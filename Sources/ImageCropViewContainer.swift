//
//  ImageCropViewContainer.swift
//  Fusuma
//
//  Created by Sacha Durand Saint Omer on 15/11/2016.
//  Copyright © 2016 ytakzk. All rights reserved.
//

import Foundation
import UIKit
import Stevia

class ImageCropViewContainer: UIView, FSImageCropViewDelegate, UIGestureRecognizerDelegate {
    
    var isShown = true
    let grid = FSGridView()
    let curtain = UIView()
    let spinnerView = UIView()
    let spinner = UIActivityIndicatorView(activityIndicatorStyle: .white)
    let squareCropButton = UIButton()
    
    var isVideoMode = false {
        didSet { self.cropView?.isVideoMode = isVideoMode }
    }
    var cropView:FSImageCropView?
    
    var shouldCropToSquare = false
    
    func squareCropButtonTapped() {
        if let cropView = cropView {
            let z = cropView.zoomScale
            if z >= 1 && z < cropView.squaredZoomScale {
                shouldCropToSquare = true
            } else {
                shouldCropToSquare = false
            }
        }
        cropView?.setFitImage(shouldCropToSquare)
        refreshCropModeButtonColor()
    }
    
    func refreshCropModeButtonColor() {
        squareCropButton.backgroundColor = UIColor.black.withAlphaComponent(0.2)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addSubview(grid)
        grid.frame = frame
        clipsToBounds = true
        
        sv(squareCropButton)
        refreshCropModeButtonColor()
        squareCropButton.size(30)
        |-squareCropButton
        squareCropButton.top(300)
        squareCropButton.addTarget(self, action: #selector(squareCropButtonTapped), for: .touchUpInside)
    
        for sv in subviews {
            if let cv = sv as? FSImageCropView {
                cropView = cv
                cropView?.myDelegate = self
            }
        }
        
        grid.alpha = 0
        
        let touchDownGR = UILongPressGestureRecognizer(target: self, action: #selector(handleTouchDown))
        touchDownGR.minimumPressDuration = 0
        addGestureRecognizer(touchDownGR)
        touchDownGR.delegate = self
        
        sv(
            spinnerView.sv(
                spinner
            ),
            curtain
        )
        
        spinnerView.fillContainer()
        spinner.centerInContainer()
        curtain.fillContainer()
        
        spinner.startAnimating()
        spinnerView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        curtain.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        curtain.alpha = 0
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
         return !(touch.view is UIButton)
    }
    
    func handleTouchDown(sender:UILongPressGestureRecognizer) {

        switch sender.state {
        case .began:
            if isShown && !isVideoMode {
                UIView.animate(withDuration: 0.1) {
                    self.grid.alpha = 1
                }
            }
        case .ended:
            UIView.animate(withDuration: 0.3) {
                self.grid.alpha = 0
            }
        default : ()
        }
        
    }
    
    func fsImageCropViewDidLayoutSubviews() {
        let newFrame = cropView!.imageView.convert(cropView!.imageView.bounds, to:self)
        grid.frame = frame.intersection(newFrame)
        grid.layoutIfNeeded()
    }
    
    func fsImageCropViewscrollViewDidZoom() {
        if isShown  && !isVideoMode {
            UIView.animate(withDuration: 0.1) {
                self.grid.alpha = 1
            }
        }
    }
    
    func fsImageCropViewscrollViewDidEndZooming() {
        UIView.animate(withDuration: 0.3) {
            self.grid.alpha = 0
        }
    }
}
