//
//  FSCameraVC.swift
//  Fusuma
//
//  Created by Sacha Durand Saint Omer on 25/10/16.
//  Copyright © 2016 ytakzk. All rights reserved.
//

import UIKit
import AVFoundation

public class FSCameraVC: UIViewController, UIGestureRecognizerDelegate {
    
    public var useFrontCamera = false
    public var didCapturePhoto:((UIImage) -> Void)?
    
    
    var session: AVCaptureSession?
    var device: AVCaptureDevice?
    var videoInput: AVCaptureDeviceInput?
    var imageOutput: AVCaptureStillImageOutput?
    var focusView: UIView?
    var flashOffImage: UIImage?
    var flashOnImage: UIImage?
    
    var v = FSCameraView()
    
    override public func loadView() { view = v }
    
    convenience init() {
        self.init(nibName:nil, bundle:nil)
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        setupButtons()
        v.flashButton.tap(flashButtonTapped)
        v.shotButton.tap(shotButtonTapped)
        v.flipButton.tap(flipButtonTapped)
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startCaptureSession()
    }
    
    func setupButtons() {
        flashOnImage = fusumaFlashOnImage ?? imageFromBundle("ic_flash_on")
        flashOffImage = fusumaFlashOffImage ?? imageFromBundle("ic_flash_off")
        let flipImage = fusumaFlipImage ?? imageFromBundle("ic_loop")
        let shotImage = fusumaShotImage ??  imageFromBundle("ic_radio_button_checked")
        
        if fusumaTintIcons {
            v.flashButton.tintColor = fusumaBaseTintColor
            v.flipButton.tintColor  = fusumaBaseTintColor
            v.shotButton.tintColor  = fusumaBaseTintColor
        }
        
        if(fusumaTintIcons) {
            v.flashButton.setImage(flashOffImage?.withRenderingMode(.alwaysTemplate), for: .normal)
            v.flipButton.setImage(flipImage.withRenderingMode(.alwaysTemplate), for: .normal)
            v.shotButton.setImage(shotImage.withRenderingMode(.alwaysTemplate), for: .normal)
        } else {
            v.flashButton.setImage(flashOffImage, for: .normal)
            v.flipButton.setImage(flipImage, for: .normal)
            v.shotButton.setImage(shotImage, for: .normal)
        }
    }
    
    func imageFromBundle(_ named:String) -> UIImage {
        let bundle = Bundle(for: self.classForCoder)
        return UIImage(named: named, in: bundle, compatibleWith: nil) ?? UIImage()
    }
    
    private func startCaptureSession() {
        session = AVCaptureSession()
        for device in AVCaptureDevice.devices() {
            let cameraPosition: AVCaptureDevicePosition = useFrontCamera
                ? .front
                : .back
            if let device = device as? AVCaptureDevice , device.position == cameraPosition {
                self.device = device
                if !device.hasFlash {
                    v.flashButton.isHidden = true
                }
            }
        }
        
        do {
            if let session = session {
                videoInput = try AVCaptureDeviceInput(device: device)
                session.addInput(videoInput)
                imageOutput = AVCaptureStillImageOutput()
                session.addOutput(imageOutput)
                let videoLayer = AVCaptureVideoPreviewLayer(session: session)
                videoLayer?.frame = v.previewViewContainer.bounds
                print(v.previewViewContainer.bounds)
                videoLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
                v.previewViewContainer.layer.addSublayer(videoLayer!)
                session.sessionPreset = AVCaptureSessionPresetPhoto
                session.startRunning()
            }
            
            // Focus View
            focusView = UIView(frame: CGRect(x: 0, y: 0, width: 90, height: 90))
            let tapRecognizer = UITapGestureRecognizer(target: self, action:#selector(focus(_:)))
            tapRecognizer.delegate = self
            v.previewViewContainer.addGestureRecognizer(tapRecognizer)
        } catch { }
        disableFlash()
        startCamera()
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForegroundNotification(_:)), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
    }
    
    func willEnterForegroundNotification(_ notification: Notification) {
        let status = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
        if status == AVAuthorizationStatus.authorized {
            session?.startRunning()
        } else if status == AVAuthorizationStatus.denied || status == AVAuthorizationStatus.restricted {
            session?.stopRunning()
        }
    }
    
    @objc func focus(_ recognizer: UITapGestureRecognizer) {
        let point = recognizer.location(in: v)
        let viewsize = v.bounds.size
        let newPoint = CGPoint(x: point.y/viewsize.height, y: 1.0-point.x/viewsize.width)
        
        let device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        
        do {
            try device?.lockForConfiguration()
        } catch _ {
            return
        }
        
        if device?.isFocusModeSupported(AVCaptureFocusMode.autoFocus) == true {
            device?.focusMode = AVCaptureFocusMode.autoFocus
            device?.focusPointOfInterest = newPoint
        }
        
        if device?.isExposureModeSupported(AVCaptureExposureMode.continuousAutoExposure) == true {
            device?.exposureMode = AVCaptureExposureMode.continuousAutoExposure
            device?.exposurePointOfInterest = newPoint
        }
        
        device?.unlockForConfiguration()
        
        if let fv = focusView {
            fv.center = point
            configureFocusView(fv)
            v.addSubview(fv)
            animateFocusView(fv)
        }
    }
    
    func startCamera() {
        let status = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
        if status == AVAuthorizationStatus.authorized {
            session?.startRunning()
        } else if status == AVAuthorizationStatus.denied || status == AVAuthorizationStatus.restricted {
            session?.stopRunning()
        }
    }
    
    func stopCamera() {
        session?.stopRunning()
    }
    
    
    func disableFlash() {
        device?.disableFlash()
        refreshFlashButton()
    }
    
    func cameraIsAvailable() -> Bool {
        return AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo) == .authorized
    }
    
    func flipButtonTapped() {
        if let deviceInput = videoInput, let s = session, cameraIsAvailable()  {
            videoInput = flipCameraFor(captureDeviceInput: deviceInput, onSession: s)
        }
    }
    
    func shotButtonTapped() {
        guard let imageOutput = imageOutput else {
            return
        }
        
        DispatchQueue.global(qos: .default).async() {
            let videoConnection = imageOutput.connection(withMediaType: AVMediaTypeVideo)
            let orientation: UIDeviceOrientation = UIDevice.current.orientation
            switch (orientation) {
            case .portrait:
                videoConnection?.videoOrientation = .portrait
            case .portraitUpsideDown:
                videoConnection?.videoOrientation = .portraitUpsideDown
            case .landscapeRight:
                videoConnection?.videoOrientation = .landscapeLeft
            case .landscapeLeft:
                videoConnection?.videoOrientation = .landscapeRight
            default:
                videoConnection?.videoOrientation = .portrait
            }
            
            imageOutput.captureStillImageAsynchronously(from: videoConnection) { buffer, error in
                self.session?.stopRunning()
                let data = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(buffer)
                if let image = UIImage(data: data!) {
                    
                    // Image size
                    var iw: CGFloat
                    var ih: CGFloat
                    
                    switch (orientation) {
                    case .landscapeLeft, .landscapeRight:
                        // Swap width and height if orientation is landscape
                        iw = image.size.height
                        ih = image.size.width
                    default:
                        iw = image.size.width
                        ih = image.size.height
                    }
                    // Frame size
                    let sw = self.v.previewViewContainer.frame.width
                    // The center coordinate along Y axis
                    let rcy = ih * 0.5
                    let imageRef = image.cgImage?.cropping(to: CGRect(x: rcy-iw*0.5, y: 0 , width: iw, height: iw))
                    DispatchQueue.main.async() {
                        if fusumaCropImage {
                            let resizedImage = UIImage(cgImage: imageRef!, scale: sw/iw, orientation: image.imageOrientation)
                            self.didCapturePhoto?(resizedImage)
                        } else {
                            self.didCapturePhoto?(image)
                        }
                        
                        self.session = nil
                        self.device = nil
                        self.imageOutput = nil
                    }
                }
            }
        }
    }
    
    func flashButtonTapped() {
        if !cameraIsAvailable() {
            return
        }
        device?.tryToggleFlash()
        refreshFlashButton()
    }
    
    func refreshFlashButton() {
        if let device = device {
            v.flashButton.setImage(flashImage(forAVCaptureFlashMode:device.flashMode), for: .normal)
        }
    }

    func flashImage(forAVCaptureFlashMode:AVCaptureFlashMode) -> UIImage {
        switch forAVCaptureFlashMode {
        case .on: return flashOnImage!
        case .off: return flashOffImage!
        default: return flashOffImage!
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}



// HELPERS




extension AVCaptureDevice {
    func tryToggleFlash() {
        guard hasFlash else { return }
        do {
            try lockForConfiguration()
            if flashMode == .off {
                flashMode = .on
            } else if flashMode == .on {
                flashMode = .off
            }
            unlockForConfiguration()
        } catch _ { }
    }
    
    func disableFlash() {
        guard hasFlash else { return }
        do {
            try lockForConfiguration()
            flashMode = .off
            unlockForConfiguration()
        } catch _ { }
    }
}



func flipCameraFor(captureDeviceInput:AVCaptureDeviceInput, onSession s:AVCaptureSession) -> AVCaptureDeviceInput? {
    var out:AVCaptureDeviceInput?
    s.stopRunning()
    s.beginConfiguration()
    for input in s.inputs {
        s.removeInput(input as! AVCaptureInput)
    }
    let position:AVCaptureDevicePosition = (captureDeviceInput.device.position == .front)
        ? .back
        : .front
    
    for device in AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo) {
        if let device = device as? AVCaptureDevice , device.position == position {
            out = try? AVCaptureDeviceInput(device: device)
            s.addInput(captureDeviceInput)
        }
    }
    s.commitConfiguration()
    s.startRunning()
    return out
}



func configureFocusView(_ v:UIView) {
    v.alpha = 0.0
    v.backgroundColor = UIColor.clear
    v.layer.borderColor = fusumaBaseTintColor.cgColor
    v.layer.borderWidth = 1.0
    v.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
}

func animateFocusView(_ v:UIView) {
    UIView.animate(withDuration: 0.8, delay: 0.0, usingSpringWithDamping: 0.8,
                   initialSpringVelocity: 3.0, options: UIViewAnimationOptions.curveEaseIn,
                   animations: {
        v.alpha = 1.0
        v.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
    }, completion: { finished in
        v.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        v.removeFromSuperview()
    })
}
