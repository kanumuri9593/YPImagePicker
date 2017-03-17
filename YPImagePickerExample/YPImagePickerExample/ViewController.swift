//
//  ViewController.swift
//  YPImagePickerExample
//
//  Created by Sacha DSO on 17/03/2017.
//  Copyright © 2017 Octopepper. All rights reserved.
//

import UIKit
import YPImagePicker

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let picker = YPImagePicker()
        // picker.showsFilters = false
        // picker.startsOnCameraMode = true
        // picker.usesFrontCamera = true
        picker.showsVideo = true
        picker.didSelectImage = { img in
            // image picked
        }
        picker.didSelectVideo = { videoData in
            // video picked
        }
        present(picker, animated: true, completion: nil)
    }
}

