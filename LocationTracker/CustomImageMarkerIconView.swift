//
//  CustomImageMarkerIconView.swift
//  LocationTracker
//
//  Created by chuanhd on 10/9/17.
//  Copyright © 2017 tranght. All rights reserved.
//

import UIKit
import SDWebImage
import SnapKit

class CustomImageMarkerIconView : UIImageView {
    
    public var m_ImageURL : URL?
    public var m_Obj : GroupImage?
    
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
//        let _borderColor = UIColor(red: 46/255.0, green: 177/255.0, blue: 135/255.0, alpha: 1)
        let _borderColor = UIColor.white
        self.layer.borderColor = _borderColor.cgColor
        self.layer.borderWidth = 2.0
    }
    
    func loadImage(fromURL _url : URL) {
        
        let _activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        self.addSubview(_activityIndicator)
        _activityIndicator.snp.makeConstraints { (maker) in
            maker.center.equalTo(self.snp.center)
            maker.width.equalTo(30.0)
            maker.height.equalTo(30.0)
        }
        
        _activityIndicator.startAnimating()
        
        self.m_ImageURL = _url
        
        self.sd_setImage(with: _url, placeholderImage: UIImage(named: "no_photo_available.png"), options: SDWebImageOptions.continueInBackground) { (_image, _error, _cacheType, _otherUrl) in
            
            print("Load image error: \(_error.debugDescription)")
            
            _activityIndicator.stopAnimating();
            _activityIndicator.removeFromSuperview()
        }
    }
}
