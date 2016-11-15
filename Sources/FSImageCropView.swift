//
//  FZImageCropView.swift
//  Fusuma
//
//  Created by Yuta Akizuki on 2015/11/16.
//  Copyright © 2015年 ytakzk. All rights reserved.
//

import UIKit
import Stevia


class FSGridView: UIView {
    
    let line1 = UIView()
    let line2 = UIView()
    let line3 = UIView()
    let line4 = UIView()
    
    convenience init() {
        self.init(frame:CGRect.zero)
        isUserInteractionEnabled = false
        sv(
            line1,
            line2,
            line3,
            line4
        )
        
        let stroke:CGFloat = 0.5
        line1.top(0).width(stroke).bottom(0)
        addConstraint(item: line1, attribute: .right, toItem: self, attribute: .right, multiplier: 0.33, constant: 0)
    
        line2.top(0).width(stroke).bottom(0)
        addConstraint(item: line2, attribute: .right, toItem: self, attribute: .right, multiplier: 0.66, constant: 0)

        line3.left(0).height(stroke).right(0)
        addConstraint(item: line3, attribute: .bottom, toItem: self, attribute: .bottom, multiplier: 0.33, constant: 0)

        line4.left(0).height(stroke).right(0)
        addConstraint(item: line4, attribute: .bottom, toItem: self, attribute: .bottom, multiplier: 0.66, constant: 0)
    
        
        let color = UIColor.white.withAlphaComponent(0.6)
        line1.backgroundColor = color
        line2.backgroundColor = color
        line3.backgroundColor = color
        line4.backgroundColor = color
    }
}


protocol FSImageCropViewDelegate: class {
    func fsImageCropViewDidLayoutSubviews()
}

final class FSImageCropView: UIScrollView, UIScrollViewDelegate {
    
    weak var myDelegate:FSImageCropViewDelegate?
    var imageView = UIImageView()
    
    var imageSize: CGSize?
    
    var image: UIImage! = nil {
        didSet {
            if image != nil {
                if !imageView.isDescendant(of: self) {
                    imageView.alpha = 1.0
                    addSubview(imageView)
                }
            } else {
                imageView.image = nil
                return
            }
            
            if !fusumaCropImage {
                // Disable scroll view and set image to fit in view
                imageView.frame = frame
                imageView.contentMode = .scaleAspectFit
                isUserInteractionEnabled = false
                imageView.image = image
                return
            }

            let imageSize = self.imageSize ?? image.size
            
            if imageSize.width < frame.width || imageSize.height < frame.height {
                // The width or height of the image is smaller than the frame size
                if imageSize.width > imageSize.height {
                    // Width > Height
                    let ratio = frame.width / imageSize.width
                    imageView.frame = CGRect(
                        origin: CGPoint.zero,
                        size: CGSize(width: frame.width, height: imageSize.height * ratio)
                    )
                } else {
                    // Width <= Height
                    let ratio = frame.height / imageSize.height
                    imageView.frame = CGRect(
                        origin: CGPoint.zero,
                        size: CGSize(width: imageSize.width * ratio, height: frame.size.height)
                    )
                }
                imageView.center = center
            } else {
                // The width or height of the image is bigger than the frame size
                if imageSize.width > imageSize.height {
                    // Width > Height
                    let ratio = frame.height / imageSize.height
                    imageView.frame = CGRect(
                        origin: CGPoint.zero,
                        size: CGSize(width: imageSize.width * ratio, height: frame.height)
                    )
                } else {
                    // Width <= Height
                    let ratio = frame.width / imageSize.width
                    imageView.frame = CGRect(
                        origin: CGPoint.zero,
                        size: CGSize(width: frame.width, height: imageSize.height * ratio)
                    )
                }
                contentOffset = CGPoint(
                    x: imageView.center.x - center.x,
                    y: imageView.center.y - center.y
                )
            }
            contentSize = CGSize(width: imageView.frame.width + 1, height: imageView.frame.height + 1)
            imageView.image = image
            zoomScale = 1.0
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
        bouncesZoom = true
        bounces = true
        delegate = self
        
        
        print(alwaysBounceHorizontal)
        print(alwaysBounceVertical)
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
        contentSize = CGSize(width: imageView.frame.width + 1, height: imageView.frame.height + 1)
    }
}
