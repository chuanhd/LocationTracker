//
//  Consts.swift
//  LocationTracker
//
//  Created by chuanhd on 7/20/17.
//  Copyright © 2017 tranght. All rights reserved.
//

import Foundation

struct Constants {
    static let Google_Maps_API_Key = "AIzaSyBT0JQMPPrgs7WOwAJOk_COZNDzAILPeBk"
    
    struct GoogleMapsConfigs {
        static let DEFAULT_ZOOM : Float = 12.0;
    }
    
    struct CellIdentifier {
        static let MemberCollectionCellIdentifier = "MemberCollectionCellIdentifier"
        static let GroupTableViewCellIdentifier = "GroupTableViewCellIdentifier"
        static let GroupMemberTableViewCellIdentifier = "GroupMemberTableViewCellIdentifier"
        static let UserProfileTableViewCell = "UserProfileTableViewCell"
        static let SideMenuTableViewCell = "SideMenuTableViewCell"
    }
    
    struct AmazonS3Config {
        static let BucketName = "location-tracker-assets"
        static let CognitoIdentityPoolId = "us-east-1:12da076d-d6de-44b5-a23e-e5392db50659"
        static let AmazonS3BaseURL = "https://s3.amazonaws.com/"
    }
    
    struct ErrorCode {
        static let INVALID_DATA = 1412001 // Happens when a data is not correct (incorrect type, nil, ...)
        static let EXTERNAL_LIB_ERROR = 1412002
    }
    
    enum ZIndex : Int32 {
        case ZERO = 0
        case ONE = 1
        case TWO = 2
        case THREE = 3
    }
    
}
