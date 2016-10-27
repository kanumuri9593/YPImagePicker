////
////  FusumaViewController.swift
////  Fusuma
////
////  Created by Yuta Akizuki on 2015/11/14.
////  Copyright © 2015年 ytakzk. All rights reserved.
////
//
//import UIKit
//import Photos
//
//
//public final class FusumaViewController: UIViewController {
//
//    
//    lazy var albumView  = FSAlbumView.instance()
//    
//    public var cameraRollUnauthorized:(() -> Void)?
//    
//    fileprivate var hasGalleryPermission: Bool {
//        return PHPhotoLibrary.authorizationStatus() == .authorized
//    }
//    
//    override public func viewDidLoad() {
//        super.viewDidLoad()
//        navigationController?.navigationBar.barTintColor = UIColor(r: 247, g: 247, b: 247)

//        albumView.delegate  = self
//        changeMode(Mode.library)
//        
//        
////        if fusumaCropImage {
////            cameraView.fullAspectRatioConstraint.isActive = false
////            cameraView.croppedAspectRatioConstraint.isActive = true
////        } else {
////            cameraView.fullAspectRatioConstraint.isActive = true
////            cameraView.croppedAspectRatioConstraint.isActive = false
////        }
//    }
//    
//    func done() {
//        let view = albumView.imageCropView
//
//        if fusumaCropImage {
//            let normalizedX = (view?.contentOffset.x)! / (view?.contentSize.width)!
//            let normalizedY = (view?.contentOffset.y)! / (view?.contentSize.height)!
//            
//            let normalizedWidth = (view?.frame.width)! / (view?.contentSize.width)!
//            let normalizedHeight = (view?.frame.height)! / (view?.contentSize.height)!
//            
//            let cropRect = CGRect(x: normalizedX, y: normalizedY, width: normalizedWidth, height: normalizedHeight)
//            
//            DispatchQueue.global(qos: .default).async() {
//                
//                let options = PHImageRequestOptions()
//                options.deliveryMode = .highQualityFormat
//                options.isNetworkAccessAllowed = true
//                options.normalizedCropRect = cropRect
//                options.resizeMode = .exact
//                
//                let targetWidth = floor(CGFloat(self.albumView.phAsset.pixelWidth) * cropRect.width)
//                let targetHeight = floor(CGFloat(self.albumView.phAsset.pixelHeight) * cropRect.height)
//                let dimension = max(min(targetHeight, targetWidth), 1024 * UIScreen.main.scale)
//                
//                let targetSize = CGSize(width: dimension, height: dimension)
//                
//                
//                let asset = self.albumView.phAsset!
//                
//                if asset.mediaType == .video {
//                    PHImageManager.default().requestAVAsset(forVideo: asset,
//                                                            options: nil) { video, audioMix, info in
//                        DispatchQueue.main.async() {
//                            let urlAsset = video as! AVURLAsset
//                            self.didSelectVideo?(urlAsset.url)
//                        }
//                    }
//                } else {
//                    PHImageManager.default()
//                        .requestImage(for: asset,
//                                      targetSize: targetSize,
//                                      contentMode: .aspectFill,
//                                      options: options) { result, info in
//                        DispatchQueue.main.async() {
//                            self.didSelectImage?(result!)
//                        }
//                    }
//                }
//            }
//        } else {
//            didSelectImage?(view!.image)
//        }
//    }
//    
//}
//
//extension FusumaViewController: FSAlbumViewDelegate {
//    public func albumViewCameraRollUnauthorized() {
//        cameraRollUnauthorized?()
//    }
//}
//
//private extension FusumaViewController {
//    
//
//    func changeMode(_ aMode: Mode) {
//        if mode == aMode {
//            return
//        }
//        //operate this switch before changing mode to stop cameras
//        switch mode {
//        case .library:
//            break
//        case .camera:
//            cameraVC.stopCamera()
//        case .video:
//            videoVC.stopCamera()
//        }
//        mode = aMode
//        switch mode {
//        case .library:()
//        case .camera:
//            cameraVC.startCamera()
//        case .video:
//            videoVC.startCamera()
//        }
////        view.bringSubview(toFront: menuView)
////        navigationItem.rightBarButtonItem?.isHidden = !hasGalleryPermission
//    }
//}
//
//
