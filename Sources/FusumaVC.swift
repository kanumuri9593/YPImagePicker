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
    
    public var showsVideo = false
    public var usesFrontCamera = false
    
    override public var prefersStatusBarHidden : Bool { return true }
    
    public var didClose:(() -> Void)?
    public var didSelectImage:((UIImage, Bool) -> Void)?
    public var didSelectVideo:((URL) -> Void)?
    
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
    
    func imageFromBundle(_ named:String) -> UIImage {
        let bundle = Bundle(for: self.classForCoder)
        return UIImage(named: named, in: bundle, compatibleWith: nil) ?? UIImage()
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        flashOnImage = imageFromBundle("yp_iconFlash_on")
        flashOffImage = imageFromBundle("yp_iconFlash_off")
        
        
        albumVC.showsVideo = showsVideo
        cameraVC.usesFrontCamera = usesFrontCamera
        
        
        view.backgroundColor = UIColor(r:247, g:247, b:247)
        cameraVC.didCapturePhoto = { [unowned self] img in
            self.didSelectImage?(img, true)
        }
        videoVC.didCaptureVideo = { [unowned self] videoURL in
            self.didSelectVideo?(videoURL)
        }
        delegate = self
        
        if controllers.isEmpty {
            if showsVideo {
                controllers = [albumVC, cameraVC, videoVC]
            } else {
                controllers = [albumVC, cameraVC]
            }
        }
        
        showPage(1, animated:false)
        
        
        updateUI()
    }
    
    internal func pagerScrollViewDidScroll(_ scrollView: UIScrollView) {    }
    
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
                
                //Start current camera
                switch self.mode {
                case .library: break
                case .camera: self.cameraVC.startCamera()
                case .video: self.videoVC.startCamera()
                }
            }
        }
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopAll()
    }
    
    func updateUI() {
        // Update Nav Bar state.
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.cancel, target: self, action: #selector(close))
        navigationItem.leftBarButtonItem?.tintColor = UIColor(r: 38, g: 38, b: 38)
        switch mode {
        case .library:
            title = albumVC.title
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: fsLocalized("YPFusumaNext"), style: UIBarButtonItemStyle.done, target: self, action: #selector(done))
            navigationItem.rightBarButtonItem?.isEnabled = true
        case .camera:
            title = cameraVC.title
            navigationItem.rightBarButtonItem = nil
        case .video:
            title = videoVC.title
            navigationItem.rightBarButtonItem = nil
        }
    }
    
    func close() {
        dismiss(animated: true) {
            self.didClose?()
        }
    }
    
    func done() {
        if mode == .library {
            albumVC.selectedMedia(photo: { img in
                self.didSelectImage?(img, false)
            }, video: { videoURL in
                self.didSelectVideo?(videoURL)
            })
        }
    }
    
    func stopAll() {
        videoVC.stopCamera()
        cameraVC.stopCamera()
    }
}
