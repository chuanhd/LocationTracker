//
//  CirclesViewController.swift
//  LocationTracker
//
//  Created by chuanhd on 7/20/17.
//  Copyright © 2017 tranght. All rights reserved.
//

import UIKit
import GoogleMaps

class CirclesViewController: UIViewController, SegueHandler {

    @IBOutlet weak var _gmsMapView: GMSMapView!
    @IBOutlet weak var mMembersCollectionView : UICollectionView!
    
    enum SegueIdentifier : String {
        case PresentCreateNewUserView  = "PresentCreateNewUserView"
    }
    
    internal let _myLocationMarker = GMSMarker();
    
    private let mCirclePresenter = GroupLocationPresenter()
    private let mCircleInfoPresenter = GroupInfoPresenter()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        ConnectionService.load(UserProfile.login) {(_ response : ServerResponse, _ myProfile : UserProfile?, _ error : Error?) in
            switch response.code {
            case .SUCCESS:
                break
            case .USER_NOT_EXIST:
                self.presentCreateNewUserViewController()
                break
            default:
                break
            }
        }
        
        let _camera = GMSCameraPosition.camera(withLatitude: -33.86, longitude: 151.20, zoom: Constants.GoogleMapsConfigs.DEFAULT_ZOOM);
        _gmsMapView.camera = _camera;
        
        // Creates a marker in the center of the map.
        _myLocationMarker.position = CLLocationCoordinate2D(latitude: -33.86, longitude: 151.20)
        _myLocationMarker.title = "Sydney"
        _myLocationMarker.snippet = "Australia"
        _myLocationMarker.map = _gmsMapView
        
        mCirclePresenter.delegate = self
        mCirclePresenter.startLocationUpdates()
        
//        mMembersCollectionView.delegate = self
//        mMembersCollectionView.dataSource = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        switch (segueIdentifier(for: segue)) {
            case .PresentCreateNewUserView:
                guard let _ = segue.destination as? CreateUserViewController else {
                    fatalError("CreateUserViewController not found");
                }
            
            
        }
    }
    
    private func presentCreateNewUserViewController() {
        self.performSegue(withIdentifier: SegueIdentifier.PresentCreateNewUserView.rawValue, sender: nil)
    }

}

extension CirclesViewController : GroupLocationPresenterDelegate {
    func locationDidUpdate(_newLocation : CLLocation) {
        _myLocationMarker.position = _newLocation.coordinate
        _gmsMapView.camera = GMSCameraPosition.camera(withTarget: _newLocation.coordinate, zoom: Constants.GoogleMapsConfigs.DEFAULT_ZOOM)
    }
}

extension CirclesViewController : UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
}

extension CirclesViewController : UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let _cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.CellIdentifier.MemberCollectionCellIdentifier, for: indexPath)
        
        return _cell
    }
}
