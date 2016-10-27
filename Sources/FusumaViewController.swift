//
//  FusumaViewController.swift
//  Fusuma
//
//  Created by Yuta Akizuki on 2015/11/14.
//  Copyright © 2015年 ytakzk. All rights reserved.
//

import UIKit
import Photos


public enum FusumaModeOrder {
    case cameraFirst
    case libraryFirst
}


public final class FusumaViewController: UIViewController {
    
    enum Mode {
        case camera
        case library
        case video
    }

    public var hasVideo = false
    public var startsOnCameraMode = false

    var mode: Mode = Mode.camera
    public var modeOrder: FusumaModeOrder = .libraryFirst
    var willFilter = true

    @IBOutlet weak var photoLibraryViewerContainer: UIView!
    @IBOutlet weak var cameraShotContainer: UIView!
    @IBOutlet weak var videoShotContainer: UIView!
    @IBOutlet weak var libraryButton: UIButton!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var videoButton: UIButton!

    @IBOutlet var libraryFirstConstraints: [NSLayoutConstraint]!
    @IBOutlet var cameraFirstConstraints: [NSLayoutConstraint]!
    
    lazy var albumView  = FSAlbumView.instance()
    public lazy var cameraVC = FSCameraVC()
    lazy var videoVC = FSVideoVC()
    
    public var didSelectImage:((UIImage) -> Void)?
    public var didSelectVideo:((URL) -> Void)?
    public var cameraRollUnauthorized:(() -> Void)?
    
    fileprivate var hasGalleryPermission: Bool {
        return PHPhotoLibrary.authorizationStatus() == .authorized
    }
    
    override public func loadView() {
        if let view = UINib(nibName: "FusumaViewController", bundle: Bundle(for: self.classForCoder)).instantiate(withOwner: self, options: nil).first as? UIView {
            self.view = view
        }
    }
    
    func setImageForAllStates(button: UIButton, image: UIImage?) {
        button.setImage(image, for: .normal)
        button.setImage(image, for: .highlighted)
        button.setImage(image, for: .selected)
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.barTintColor = UIColor(r: 247, g: 247, b: 247)
        view.backgroundColor = fusumaBackgroundColor
//        cameraVC.delegate = self
        albumView.delegate  = self
        videoVC.delegate = self
//        menuView.backgroundColor = fusumaBackgroundColor
//        menuView.addBottomBorder(UIColor.black, width: 1.0)
        
        let bundle = Bundle(for: self.classForCoder)
        // Get the custom button images if they're set
        let albumImage = fusumaAlbumImage != nil ? fusumaAlbumImage : UIImage(named: "ic_insert_photo", in: bundle, compatibleWith: nil)
        let cameraImage = fusumaCameraImage != nil ? fusumaCameraImage : UIImage(named: "ic_photo_camera", in: bundle, compatibleWith: nil)
        let videoImage = fusumaVideoImage != nil ? fusumaVideoImage : UIImage(named: "ic_videocam", in: bundle, compatibleWith: nil)
        let checkImage = fusumaCheckImage != nil ? fusumaCheckImage : UIImage(named: "ic_check", in: bundle, compatibleWith: nil)
        let closeImage = fusumaCloseImage != nil ? fusumaCloseImage : UIImage(named: "ic_close", in: bundle, compatibleWith: nil)
        
        if fusumaTintIcons {
            
            setImageForAllStates(button: libraryButton,
                                 image: albumImage?.withRenderingMode(.alwaysTemplate))
            libraryButton.tintColor = fusumaTintColor
            libraryButton.adjustsImageWhenHighlighted = false

            setImageForAllStates(button: cameraButton,
                                 image: cameraImage?.withRenderingMode(.alwaysTemplate))
            cameraButton.tintColor  = fusumaTintColor
            cameraButton.adjustsImageWhenHighlighted  = false
            
            setImageForAllStates(button: videoButton,
                                 image: videoImage?.withRenderingMode(.alwaysTemplate))
            videoButton.tintColor = fusumaTintColor
            videoButton.adjustsImageWhenHighlighted = false

            
        } else {
            setImageForAllStates(button: libraryButton, image: albumImage)
            setImageForAllStates(button: cameraButton, image: cameraImage)
            setImageForAllStates(button: videoButton, image: videoImage)
            
            libraryButton.tintColor = nil
            cameraButton.tintColor = nil
            videoButton.tintColor = nil
        }
        
        cameraButton.clipsToBounds  = true
        libraryButton.clipsToBounds = true
        videoButton.clipsToBounds = true

        changeMode(Mode.library)
        
        photoLibraryViewerContainer.addSubview(albumView)
        cameraShotContainer.addSubview(cameraVC.view)
        videoShotContainer.addSubview(videoVC.view)
        
        
        if !hasVideo {
            videoButton.removeFromSuperview()
            view.addConstraint(NSLayoutConstraint(
                item:       view,
                attribute:  .trailing,
                relatedBy:  .equal,
                toItem:     cameraButton,
                attribute:  .trailing,
                multiplier: 1.0,
                constant:   0
                )
            )
            view.layoutIfNeeded()
        }
        
//        if fusumaCropImage {
//            cameraView.fullAspectRatioConstraint.isActive = false
//            cameraView.croppedAspectRatioConstraint.isActive = true
//        } else {
//            cameraView.fullAspectRatioConstraint.isActive = true
//            cameraView.croppedAspectRatioConstraint.isActive = false
//        }
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if startsOnCameraMode {
            changeMode(.camera)
        }
    }

    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        albumView.frame  = CGRect(origin: CGPoint.zero, size: photoLibraryViewerContainer.frame.size)
        albumView.layoutIfNeeded()
        cameraVC.view.frame = CGRect(origin: CGPoint.zero, size: cameraShotContainer.frame.size)
        cameraVC.view.layoutIfNeeded()

        albumView.initialize()
        
        if hasVideo {
            videoVC.view.frame = CGRect(origin: CGPoint.zero, size: videoShotContainer.frame.size)
            videoVC.view.layoutIfNeeded()
//            videoVC.view.initialize()// TODO only if present?
        }
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopAll()
    }

    override public var prefersStatusBarHidden : Bool { return true }
    

    
    @IBAction func libraryButtonPressed(_ sender: UIButton) {
        changeMode(Mode.library)
    }
    
    @IBAction func photoButtonPressed(_ sender: UIButton) {
        changeMode(Mode.camera)
    }
    
    @IBAction func videoButtonPressed(_ sender: UIButton) {
        changeMode(Mode.video)
    }
    
    func done() {
        let view = albumView.imageCropView

        if fusumaCropImage {
            let normalizedX = (view?.contentOffset.x)! / (view?.contentSize.width)!
            let normalizedY = (view?.contentOffset.y)! / (view?.contentSize.height)!
            
            let normalizedWidth = (view?.frame.width)! / (view?.contentSize.width)!
            let normalizedHeight = (view?.frame.height)! / (view?.contentSize.height)!
            
            let cropRect = CGRect(x: normalizedX, y: normalizedY, width: normalizedWidth, height: normalizedHeight)
            
            DispatchQueue.global(qos: .default).async() {
                
                let options = PHImageRequestOptions()
                options.deliveryMode = .highQualityFormat
                options.isNetworkAccessAllowed = true
                options.normalizedCropRect = cropRect
                options.resizeMode = .exact
                
                let targetWidth = floor(CGFloat(self.albumView.phAsset.pixelWidth) * cropRect.width)
                let targetHeight = floor(CGFloat(self.albumView.phAsset.pixelHeight) * cropRect.height)
                let dimension = max(min(targetHeight, targetWidth), 1024 * UIScreen.main.scale)
                
                let targetSize = CGSize(width: dimension, height: dimension)
                
                
                let asset = self.albumView.phAsset!
                
                if asset.mediaType == .video {
                    PHImageManager.default().requestAVAsset(forVideo: asset,
                                                            options: nil) { video, audioMix, info in
                        DispatchQueue.main.async() {
                            let urlAsset = video as! AVURLAsset
                            self.didSelectVideo?(urlAsset.url)
                        }
                    }
                } else {
                    PHImageManager.default()
                        .requestImage(for: asset,
                                      targetSize: targetSize,
                                      contentMode: .aspectFill,
                                      options: options) { result, info in
                        DispatchQueue.main.async() {
                            self.didSelectImage?(result!)
                        }
                    }
                }
            }
        } else {
            didSelectImage?(view!.image)
        }
    }
    
}

extension FusumaViewController: FSVideoCameraViewDelegate {
    func videoFinished(withFileURL fileURL: URL) {
        didSelectVideo?(fileURL)
    }
}

extension FusumaViewController: FSAlbumViewDelegate {
    public func albumViewCameraRollUnauthorized() {
        cameraRollUnauthorized?()
    }
}

private extension FusumaViewController {
    
    func stopAll() {
        if hasVideo {
            videoVC.stopCamera()
        }
        cameraVC.stopCamera()
    }
    
    func changeMode(_ aMode: Mode) {
        if mode == aMode {
            return
        }
        //operate this switch before changing mode to stop cameras
        switch mode {
        case .library:
            break
        case .camera:
            cameraVC.stopCamera()
        case .video:
            videoVC.stopCamera()
        }
        mode = aMode
        dishighlightButtons()
        switch aMode {
        case .library:
            highlightButton(libraryButton)
            view.bringSubview(toFront: photoLibraryViewerContainer)
        case .camera:
            highlightButton(cameraButton)
            view.bringSubview(toFront: cameraShotContainer)
            cameraVC.startCamera()
        case .video:
            highlightButton(videoButton)
            view.bringSubview(toFront: videoShotContainer)
            videoVC.startCamera()
        }
        
//        view.bringSubview(toFront: menuView)
        
        
        
        

//        navigationItem.rightBarButtonItem?.isHidden = !hasGalleryPermission

        
        
    }
    
    
    func dishighlightButtons() {
        cameraButton.tintColor  = fusumaBaseTintColor
        libraryButton.tintColor = fusumaBaseTintColor
        
        if let sl = cameraButton.layer.sublayers, sl.count > 1 {
        
            for layer in cameraButton.layer.sublayers! {
                if let borderColor = layer.borderColor , UIColor(cgColor: borderColor) == fusumaTintColor {
                    layer.removeFromSuperlayer()
                }
            }
        }
        
        if let sl = libraryButton.layer.sublayers, sl.count > 1 {
            for layer in libraryButton.layer.sublayers! {
                if let borderColor = layer.borderColor , UIColor(cgColor: borderColor) == fusumaTintColor {
                    layer.removeFromSuperlayer()
                }
            }
        }
        
        if let videoButton = videoButton {
            videoButton.tintColor = fusumaBaseTintColor
            if let sl = videoButton.layer.sublayers, sl.count > 1 {
                for layer in videoButton.layer.sublayers! {
                    if let borderColor = layer.borderColor , UIColor(cgColor: borderColor) == fusumaTintColor {
                        layer.removeFromSuperlayer()
                    }
                }
            }
        }
    }
    
    func highlightButton(_ button: UIButton) {
        button.tintColor = fusumaTintColor
        button.addBottomBorder(fusumaTintColor, width: 3)
    }
}


extension UIColor {
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat = 1.0) {
        self.init(red: r / 255.0, green: g / 255.0, blue: b / 255.0, alpha: a)
    }
}
