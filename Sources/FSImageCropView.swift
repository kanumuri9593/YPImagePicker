//
//  FZImageCropView.swift
//  Fusuma
//
//  Created by Yuta Akizuki on 2015/11/16.
//  Copyright © 2015年 ytakzk. All rights reserved.
//

import UIKit

protocol FSImageCropViewDelegate: class {
    func fsImageCropViewDidLayoutSubviews()
    func fsImageCropViewscrollViewDidZoom()
    func fsImageCropViewscrollViewDidEndZooming()
}

final class FSImageCropView: UIScrollView, UIScrollViewDelegate {
    
    
    var isVideoMode = false
    
    
    var squaredZoomScale: CGFloat = 1
    
    weak var myDelegate:FSImageCropViewDelegate?
    var imageView = UIImageView()
    
    var imageSize: CGSize?
    
    var image: UIImage! = nil {
        didSet {
            setZoomScale(1.0, animated: true)
            if image != nil {
                if !imageView.isDescendant(of: self) {
                    imageView.alpha = 1.0
                    addSubview(imageView)
                }
            } else {
                imageView.image = nil
                return
            }
            
            
            if isVideoMode {
                imageView.frame = frame
                imageView.contentMode = .scaleAspectFit
                imageView.image = image
                contentSize = CGSize.zero
                return
            }
            
            
            
            // Set image
//            self.imageView.frame = self.frame
            let screenSize:CGFloat = 375
            self.imageView.frame.size.width = screenSize
            self.imageView.frame.size.height = screenSize
            
            var squareZoomScale: CGFloat = 1.0
            let w = image.size.width
            let h = image.size.height
            
            if w > h { // Landscape
                squareZoomScale = (1.0 / (w / h))
                self.imageView.frame.size.width = screenSize
                self.imageView.frame.size.height = screenSize*squareZoomScale
                
            } else if h > w { // Portrait
                squareZoomScale = (1.0 / (h / w))
                self.imageView.frame.size.width = screenSize*squareZoomScale
                self.imageView.frame.size.height = screenSize
            }
            
            self.imageView.center = center
            
            self.imageView.contentMode = .scaleAspectFill
            self.imageView.image = self.image
            
            
            imageView.clipsToBounds = true
            
            refreshZoomScale()
        }
    }
    
    func refreshZoomScale() {
        var squareZoomScale: CGFloat = 1.0
        let w = image.size.width
        let h = image.size.height
        
        if w > h { // Landscape
            squareZoomScale = (w / h)
        } else if h > w { // Portrait
            squareZoomScale = (h / w)
        }
        squaredZoomScale = squareZoomScale
    }
    
    func setFitImage(_ fit: Bool) {
        refreshZoomScale()
        if fit {
            setZoomScale(squaredZoomScale, animated: true)
        } else {
            setZoomScale(1, animated: true)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        frame.size      = CGSize.zero
        clipsToBounds   = true
        imageView.alpha = 0.0
        imageView.frame = CGRect(origin: CGPoint.zero, size: CGSize.zero)
        maximumZoomScale = 6.0
        minimumZoomScale = 1
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator   = false
        delegate = self
        alwaysBounceHorizontal = true
        alwaysBounceVertical = true
        isScrollEnabled = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        myDelegate?.fsImageCropViewDidLayoutSubviews()
    }
    
    func changeScrollable(_ isScrollable: Bool) {
//        isScrollEnabled = isScrollable
    }
    
    // MARK: UIScrollViewDelegate Protocol
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        myDelegate?.fsImageCropViewscrollViewDidZoom()
        let boundsSize = scrollView.bounds.size
        var contentsFrame = imageView.frame
        if contentsFrame.size.width < boundsSize.width {
            contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0
        } else {
            contentsFrame.origin.x = 0.0
        }
        
        if contentsFrame.size.height < boundsSize.height {
            contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0
        } else {
            contentsFrame.origin.y = 0.0
        }
        imageView.frame = contentsFrame
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        myDelegate?.fsImageCropViewscrollViewDidEndZooming()
        contentSize = CGSize(width: imageView.frame.width + 1, height: imageView.frame.height + 1)
    }
}
