//
//  FusumaVC.swift
//  Fusuma
//
//  Created by Sacha Durand Saint Omer on 25/10/16.
//  Copyright © 2016 ytakzk. All rights reserved.
//

import Foundation
import Stevia

var flashOffImage: UIImage?
var flashOnImage: UIImage?
var videoStartImage: UIImage?
var videoStopImage: UIImage?



extension UIColor {
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat = 1.0) {
        self.init(red: r / 255.0, green: g / 255.0, blue: b / 255.0, alpha: a)
    }
}


public class FusumaVC: FSBottomPager, PagerDelegate {
    
    internal func pagerScrollViewDidScroll(_ scrollView: UIScrollView) {    }

    
    override public var prefersStatusBarHidden : Bool { return true }
    
    //API
    public var didClose:(() -> Void)?
    public var didSelectImage:((UIImage) -> Void)?
    
    enum Mode {
        case library
        case camera
        case video
    }
    
    let albumVC = FSAlbumVC()
    let cameraVC = FSCameraVC()
    let videoVC = FSVideoVC()
    
    var mode = Mode.library
    
    var capturedImage:UIImage?
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(r:247, g:247, b:247)
        cameraVC.didCapturePhoto = { img in
//            self.capturedImage = img
//            self.updateUI()
            
            
            self.didSelectImage?(img)
        }
        videoVC.didCaptureVideo = { videoURL in
        
        }
        delegate = self
        
        updateUI()
        
        //has video set enum contreollers
        
        // Start onCameraMode -> index of selected controller
    }
    
    func pagerDidSelectController(_ vc: UIViewController) {
        
        var changedMode = true
        
        switch mode {
        case .library where vc == albumVC:
            changedMode = false
        case .camera where vc == cameraVC:
            changedMode = false
        case .video where vc == videoVC:
            changedMode = false
        default:()
        }
        
        
        if changedMode {
            
            
            
//            let previousMode = mode

            
            
            // Set new mode
            if vc == albumVC {
                mode = .library
            } else if vc == cameraVC {
                mode = .camera
            } else if vc == videoVC {
                mode = .video
            }
            
            updateUI()
            
            
            
            DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async {
                // Stop cameras not shown on screen.
                if self.mode != .video {
                    self.videoVC.stopCamera()
                }
                if self.mode != .camera {
                    self.cameraVC.stopCamera()
                }
    //
                //Start current camera
                switch self.mode {
                case .library: break
                case .camera: self.cameraVC.startCamera()
                case .video: self.videoVC.startCamera()
                }
            }
//                view.bringSubview(toFront: menuView)
//                navigationItem.rightBarButtonItem?.isHidden = !hasGalleryPermission
//            
//            updateUI()
            
            

        }
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopAll()
    }
    
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if controllers.isEmpty {
            controllers = [albumVC, cameraVC, videoVC]
        }
    }
    
    func updateUI() {
        // Update Nav Bar state.
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.cancel, target: self, action: #selector(close))
        navigationItem.leftBarButtonItem?.tintColor = UIColor(r: 38, g: 38, b: 38)
        switch mode {
        case .library:
            title = albumVC.title
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: UIBarButtonItemStyle.done, target: self, action: #selector(done))
            navigationItem.rightBarButtonItem?.isEnabled = true
        case .camera:
            title = cameraVC.title
            if let _ = capturedImage {
                navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: UIBarButtonItemStyle.done, target: self, action: #selector(done))
            } else {
                navigationItem.rightBarButtonItem = nil
            }
        case .video:
            title = videoVC.title
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: UIBarButtonItemStyle.plain, target: self, action: #selector(done))
            navigationItem.rightBarButtonItem?.isEnabled = false
        }
    }
    
    func close() {
        dismiss(animated: true) {
            self.didClose?()
        }
    }
    
    func done() {
        if mode == .camera {
            if let img = capturedImage {
                didSelectImage?(img)
            }
        } else if mode == .library {
            albumVC.selectedMedia(photo: { img in
                self.didSelectImage?(img)
            }, video: { videoURL in
                print(videoURL)
            })
        }
    }
    
    func stopAll() {
//        if hasVideo {
            videoVC.stopCamera()
//        }
        cameraVC.stopCamera()
    }
    
}



//
//public final class FusumaViewController: UIViewController {
//
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
//
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
//
//extension FusumaViewController: FSAlbumViewDelegate {
//    public func albumViewCameraRollUnauthorized() {
//        cameraRollUnauthorized?()
//    }
//}
//


//}
