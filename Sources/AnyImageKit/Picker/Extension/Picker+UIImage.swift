//
//  Picker+UIImage.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2019/9/17.
//  Copyright © 2019-2021 AnyImageProject.org. All rights reserved.
//

import UIKit
import MobileCoreServices
import ImageIO

extension UIImage {
    
    private struct AssociatedKey {
        
        static var _animatedImageDataKey: UInt8 = 0
        static var _imageSourceKey: UInt8 = 0
    }
    
    var _animatedImageData: Data? {
        get {
            AssociatedObject.get(object: self,
                                 key: &AssociatedKey._animatedImageDataKey,
                                 defaultValue: nil)
        }
        set {
            AssociatedObject.set(object: self,
                                 key: &AssociatedKey._animatedImageDataKey,
                                 value: newValue,
                                 policy: .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var _imageSource: CGImageSource? {
        get {
            AssociatedObject.get(object: self,
                                 key: &AssociatedKey._imageSourceKey,
                                 defaultValue: nil)
        }
        set {
            AssociatedObject.set(object: self,
                                 key: &AssociatedKey._imageSourceKey,
                                 value: newValue,
                                 policy: .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

extension UIImage {
    
    static func animatedImage(data: Data, options: ImageCreatingOptions = .init()) -> UIImage? {
        let info: [CFString: Any] = [
            kCGImageSourceShouldCache: true,
            kCGImageSourceTypeIdentifierHint: kUTTypeGIF,
        ]
        
        guard let imageSource = CGImageSourceCreateWithData(data as CFData, info as CFDictionary) else {
            return nil
        }
        
        var image: UIImage?
        if options.preloadAll || options.onlyFirstFrame {
            // Use `images` image if you want to preload all animated data
            guard let animatedImage = GIFAnimatedImage(from: imageSource, for: info, options: options) else {
                return nil
            }
            if options.onlyFirstFrame {
                image = animatedImage.images.first
            } else {
                let duration = options.duration <= 0.0 ? animatedImage.duration : options.duration
                image = .animatedImage(with: animatedImage.images, duration: duration)
            }
            image?._animatedImageData = data
        } else {
            image = UIImage(data: data, scale: options.scale)
            image?._imageSource = imageSource
            image?._animatedImageData = data
        }
        
        return image
    }
}
