//
//  AppDelegate.swift
//  LocationTracker
//
//  Created by chuanhd on 7/19/17.
//  Copyright © 2017 tranght. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import AWSCore
import AWSCognito
import AWSS3
import IQKeyboardManagerSwift
import Fingertips

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
 
    var window: MBFingerTipWindow? = MBFingerTipWindow(frame: UIScreen.main.bounds)

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        self.window?.alwaysShowTouches = true
        
        // Initialize Google Maps SDK
        GMSServices.provideAPIKey(Constants.Google_Maps_API_Key);
        GMSPlacesClient.provideAPIKey(Constants.Google_Maps_API_Key);
        
        let credentialProvider = AWSCognitoCredentialsProvider(regionType: .USEast1, identityPoolId: Constants.AmazonS3Config.CognitoIdentityPoolId)
        let configuration = AWSServiceConfiguration(region: .USEast1, credentialsProvider: credentialProvider)
        AWSServiceManager.default().defaultServiceConfiguration = configuration

        IQKeyboardManager.sharedManager().enable = true
        
        //
        let locationManager = LocationService.shared
        locationManager.requestWhenInUseAuthorization()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
        // Store the completion handler.
        AWSS3TransferUtility.interceptApplication(application, handleEventsForBackgroundURLSession: identifier, completionHandler: completionHandler)
    }
}

