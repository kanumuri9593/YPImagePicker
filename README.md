## YPFusuma

### Warning, This is a Fusuma fork and not ready for production (yet!)

Fusuma is a Swift library that provides an Instagram-like photo browser and a camera feature with a few line of code.  
You can use Fusuma instead of UIImagePickerController. It also has a feature to take a square-sized photo.

[![Version](https://img.shields.io/cocoapods/v/Fusuma.svg?style=flat)](http://cocoapods.org/pods/Fusuma)
[![Platform](https://img.shields.io/cocoapods/p/Fusuma.svg?style=flat)](http://cocoapods.org/pods/Fusuma)
[![CI Status](http://img.shields.io/travis/ytakzk/Fusuma.svg?style=flat)](https://travis-ci.org/ytakzk/Fusuma)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![codebeat badge](https://codebeat.co/badges/6a591267-c444-4c88-a410-56270d8ed9bc)](https://codebeat.co/projects/github-com-yummypets-ypfusuma)

## Improvements
YPFusuma is built from the great Fusuma library.

Here are the improvements we added :
- Improve Overall Code Quality
- Simpler API
- Added Filters View ala Instagram
- Replaces icons with lighter Text
- Preselect Front camera (e.g for avatars)
- Scroll between tabs which feels smoother
- Grab videos form the library view as well
- Replaces Delegate based with callbacks based api
- Uses Native Navigation bar over custom View (gotta be a good UIKit citizen)

## Preview

<img src="https://raw.githubusercontent.com/Yummypets/YPFusuma/master/Images/library.PNG" width="340px">
<img src="https://raw.githubusercontent.com/Yummypets/YPFusuma/master/Images/photo.PNG" width="340px">
<img src="https://raw.githubusercontent.com/Yummypets/YPFusuma/master/Images/video.PNG" width="340px">
<img src="https://raw.githubusercontent.com/Yummypets/YPFusuma/master/Images/filters.PNG" width="340px">

## Features
- [x] UIImagePickerController alternative
- [x] Cropping images in camera roll
- [x] Taking a square-sized photo and a video using AVFoundation
- [x] Flash: On Off
- [x] Camera Mode: Front Back
- [x] Video Mode

Those features are available just with a few lines of code!

## Installation

Drop in the Classes folder to your Xcode project.  
You can also use CocoaPods or Carthage.

#### Using [CocoaPods](http://cocoapods.org/)

Add `pod 'Fusuma'` to your `Podfile` and run `pod install`. Also add `use_frameworks!` to the `Podfile`.

```
use_frameworks!
pod 'Fusuma'
```

#### Using [Carthage](https://github.com/Carthage/Carthage)

Add `github "Yummypets/YPFusuma"` to your `Cartfile` and run `carthage update`. If unfamiliar with Carthage then checkout their [Getting Started section](https://github.com/Carthage/Carthage#getting-started).

```
github "Yummypets/YPFusuma"
```

## Usage
Import Fusuma ```import Fusuma``` then use the following codes in some function except for viewDidLoad and give FusumaDelegate to the view controller.  

```swift
let picker = YPImagePicker()
// picker.showsFilters = false
// picker.startsOnCameraMode = true
// picker.usesFrontCamera = true
// picker.showsVideo = true
picker.didSelectImage = { img in
    // image picked
}
picker.didSelectVideo = { videoURL in
    // video picked
}
present(picker, animated: true, completion: nil)
```


## Original Author
ytakzk  
[http://ytakzk.me](http://ytakzk.me)

## License
Fusuma is released under the MIT license.  
See LICENSE for details.
