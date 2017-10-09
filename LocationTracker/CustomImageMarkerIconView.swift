//
//  CustomImageMarkerIconView.swift
//  LocationTracker
//
//  Created by chuanhd on 10/9/17.
//  Copyright © 2017 tranght. All rights reserved.
//

import UIKit
import SDWebImage

class CustomImageMarkerIconView : UIImageView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.setupView()
    }
    
    internal func setupView() {
        self.clipsToBounds = true
        let _borderColor = UIColor(red: 46/255.0, green: 177/255.0, blue: 135/255.0, alpha: 1)
        self.layer.borderColor = _borderColor.cgColor
        self.layer.borderWidth = 2.0
    }
    
    func loadImage(fromURL _url : URL) {
        self.sd_setImage(with: _url, placeholderImage: UIImage(named: "default_avatar.png"), options: SDWebImageOptions.continueInBackground) { (_image, _error, _cacheType, _otherUrl) in
            
        }
    }
}
