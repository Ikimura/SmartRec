//
//  UIImageExtensions.swift
//  SmartRec
//
//  Created by Artsiom Karseka on 11/12/14.
//  Copyright (c) 2014 con.epam.evnt. All rights reserved.
//

import AVFoundation
import UIKit

extension AVAsset {
    
    func thumbnailWithSize(#size: CGSize) -> UIImage {
        
        let duration: CMTime = self.duration;
        
        let generator: AVAssetImageGenerator = AVAssetImageGenerator(asset: self);
        //
        var time: CMTime = self.duration;
        time.value = 1000;
        
        let maxSize: CGSize = size;
        
        generator.maximumSize = maxSize;
        
        //Snatch a frame
        let frameRef: CGImageRef = generator.copyCGImageAtTime(time, actualTime: nil, error: nil);
        let resImage: UIImage = UIImage(CGImage: frameRef)!;
        
        let image: UIImage = UIImage(CGImage: resImage.CGImage, scale: 1.0, orientation: .Right)!;
        
        return image;
    }
}