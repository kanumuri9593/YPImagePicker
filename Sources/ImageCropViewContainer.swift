//
//  ImageCropViewContainer.swift
//  Fusuma
//
//  Created by Sacha Durand Saint Omer on 15/11/2016.
//  Copyright © 2016 ytakzk. All rights reserved.
//

import Foundation


class ImageCropViewContainer: UIView, FSImageCropViewDelegate, UIGestureRecognizerDelegate {
    
    
    var isShown = true
    let grid = FSGridView()
    let curtain = UIView()
    let spinnerView = UIView()
    let spinner = UIActivityIndicatorView(activityIndicatorStyle: .white)
    
    
    var cropView:FSImageCropView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addSubview(grid)
        grid.frame = frame
        clipsToBounds = true
        
        
        
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
    
    func handleTouchDown(sender:UILongPressGestureRecognizer) {

        switch sender.state {
        case .began:
            if isShown {
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
        if isShown {
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
