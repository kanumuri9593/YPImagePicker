//
//  Filter.swift
//  photoTaking
//
//  Created by Sacha Durand Saint Omer on 21/10/16.
//  Copyright © 2016 octopepper. All rights reserved.
//

import UIKit
import CoreImage

var _filterSharedContext:CIContext!


struct Filter {
    
    private var name = ""
    
    init(_ name:String) {
        self.name = name
    }
    
    func filter(_ image:UIImage) -> UIImage {
        if name == "" {
            return image
        }
        let context = filterSharedContext()
        let ciImage = CIImage(image: image)
        if let filter = CIFilter(name: name) {
            filter.setValue(ciImage, forKey: kCIInputImageKey)
            if let outputImage = filter.outputImage,
                let cgImg = context.createCGImage(outputImage, from: outputImage.extent) {
                return UIImage(cgImage:cgImg)
            } else {
                return UIImage()
            }
        }
        return UIImage()
    }
    
    func filterSharedContext() -> CIContext {
        if _filterSharedContext == nil {
            let openGLContext = EAGLContext(api: .openGLES3)! // 3 or 2
            _filterSharedContext = CIContext(eaglContext: openGLContext) // faster?
            return _filterSharedContext
        } else {
            return _filterSharedContext
        }
    }
}
