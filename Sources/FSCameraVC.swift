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
    
    public var usesFrontCamera = false
    public var didCapturePhoto:((UIImage) -> Void)?
    
    private let sessionQueue = DispatchQueue(label: "FSCameraVCSerialQueue")
    let session = AVCaptureSession()
    var device: AVCaptureDevice! {
        return videoInput.device
    }
    var videoInput: AVCaptureDeviceInput!
    let imageOutput = AVCaptureStillImageOutput()
    let focusView = UIView(frame: CGRect(x: 0, y: 0, width: 90, height: 90))
    
    var v = FSCameraView()
    
    
    
    var isPreviewSetup = false
    
    override public func loadView() { view = v }
    
    convenience init() {
        self.init(nibName:nil, bundle:nil)
        title = fsLocalized("YPFusumaPhoto")
        sessionQueue.async { [unowned self] in
            self.setupCaptureSession()
        }
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        v.flashButton.isHidden = true
        v.flashButton.addTarget(self, action: #selector(flashButtonTapped), for: .touchUpInside)
        v.shotButton.addTarget(self, action: #selector(shotButtonTapped), for: .touchUpInside)
        v.flipButton.addTarget(self, action: #selector(flipButtonTapped), for: .touchUpInside)
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !isPreviewSetup {
            setupPreview()
            isPreviewSetup = true
        }
        refreshFlashButton()
    }
    
    func setupPreview() {
        let videoLayer = AVCaptureVideoPreviewLayer(session: session)
        videoLayer?.frame = v.previewViewContainer.bounds
        videoLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
        v.previewViewContainer.layer.addSublayer(videoLayer!)
        let tapRecognizer = UITapGestureRecognizer(target: self, action:#selector(focus(_:)))
        tapRecognizer.delegate = self
        v.previewViewContainer.addGestureRecognizer(tapRecognizer)
    }
    
    private func setupCaptureSession() {
        session.beginConfiguration()
        session.sessionPreset = AVCaptureSessionPresetPhoto
        let cameraPosition: AVCaptureDevicePosition = usesFrontCamera ? .front : .back
        let aDevice = deviceForPosition(cameraPosition)
        videoInput = try? AVCaptureDeviceInput(device: aDevice)
        
        if session.canAddInput(videoInput) {
            session.addInput(videoInput)
        }
        if session.canAddOutput(imageOutput) {
            session.addOutput(imageOutput)
        }
        session.commitConfiguration()
    }
    
    func focus(_ recognizer: UITapGestureRecognizer) {
        let point = recognizer.location(in: v.previewViewContainer)
        let viewsize = v.previewViewContainer.bounds.size
        let newPoint = CGPoint(x:point.x/viewsize.width, y:point.y/viewsize.height)
        setFocusPointOnDevice(device: device, point: newPoint)
        focusView.center = point
        configureFocusView(focusView)
        v.addSubview(focusView)
        animateFocusView(focusView)
    }
    
    func startCamera() {
        sessionQueue.async { [unowned self] in
            let status = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
            switch status {
            case .notDetermined, .restricted, .denied:
                self.session.stopRunning()
            case .authorized:
                self.session.startRunning()
            }
        }
    }
    
    func stopCamera() {
        if session.isRunning {
            sessionQueue.async { [unowned self] in
                self.session.stopRunning()
            }
        }
    }
    
    func flipButtonTapped() {
        sessionQueue.async { [unowned self] in
            self.session.resetInputs()
            self.videoInput = flippedDeviceInputForInput(self.videoInput)
            if self.session.canAddInput(self.videoInput) {
                self.session.addInput(self.videoInput)
            }
            DispatchQueue.main.async {
                self.refreshFlashButton()
            }
        }
    }

    func shotButtonTapped() {
        DispatchQueue.global(qos: .default).async() {
            let videoConnection = self.imageOutput.connection(withMediaType: AVMediaTypeVideo)
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
            
            self.imageOutput.captureStillImageAsynchronously(from: videoConnection) { buffer, error in
                self.session.stopRunning()
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
                            var resizedImage = UIImage(cgImage: imageRef!, scale: sw/iw, orientation: image.imageOrientation)
                            if let device = self.device, let cgImg =  resizedImage.cgImage, device.position == .front {
                                
                                print(image.imageOrientation)
                                resizedImage = UIImage(cgImage: cgImg, scale: resizedImage.scale, orientation:.leftMirrored)
                            }
                            self.didCapturePhoto?(resizedImage)
                        } else {
                            self.didCapturePhoto?(image)
                        }
                    }
                }
            }
        }
    }
    
    func flashButtonTapped() {
        device?.tryToggleFlash()
        refreshFlashButton()
    }
    
    func refreshFlashButton() {
        if let device = device {
            v.flashButton.setImage(flashImage(forAVCaptureFlashMode:device.flashMode), for: .normal)
            v.flashButton.isHidden = !device.hasFlash
        }
    }

    func flashImage(forAVCaptureFlashMode:AVCaptureFlashMode) -> UIImage {
        switch forAVCaptureFlashMode {
        case .on: return flashOnImage!
        case .off: return flashOffImage!
        default: return flashOffImage!
        }
    }
}
