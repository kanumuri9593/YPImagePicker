//
//  FusumaVC.swift
//  Fusuma
//
//  Created by Sacha Durand Saint Omer on 25/10/16.
//  Copyright © 2016 ytakzk. All rights reserved.
//

import Foundation
import Stevia



public class FusumaVC: UIViewController {
    
    //API
    public var didClose:(() -> Void)?
    public var didSelectImage:((UIImage) -> Void)?
    
    enum Mode {
        case camera
        case library
        case video
    }
    
    let cameraVC = FSCameraVC()
    
    let mode = Mode.camera
    
    var capturedImage:UIImage?
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(r:247, g:247, b:247)
        addCameraVCToView()
        cameraVC.didCapturePhoto = { img in
            self.capturedImage = img
            self.updateUI()
        }
        updateUI()
    }
    
    func addCameraVCToView() {
        addChildViewController(cameraVC)
        view.sv(
            cameraVC.view
        )
        cameraVC.view.fillContainer()
    }
    
    func updateUI() {
        // Update Nav Bar state.
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.cancel, target: self, action: #selector(close))
        navigationItem.leftBarButtonItem?.tintColor = UIColor(r: 38, g: 38, b: 38)
        switch mode {
        case .library:
            title = NSLocalizedString(fusumaCameraRollTitle, comment: "").capitalized
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: UIBarButtonItemStyle.done, target: self, action: #selector(done))
        case .camera:
            title = NSLocalizedString(fusumaCameraTitle, comment: "").capitalized
            if let _ = capturedImage {
                navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: UIBarButtonItemStyle.done, target: self, action: #selector(done))
            } else {
                navigationItem.rightBarButtonItem = nil
            }
        case .video:
            title = NSLocalizedString(fusumaVideoTitle, comment: "").capitalized
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
        }
    }
    
}
