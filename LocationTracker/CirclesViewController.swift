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
        case ShowSideMenuView = "ShowSideMenuView"
    }
    
    internal let _myLocationMarker = GMSMarker();
    
    internal let mCirclePresenter = GroupLocationPresenter()
    private let mCircleInfoPresenter = GroupInfoPresenter()
    
    private var mGroupNameTitleView : GroupNameTitleView?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        mGroupNameTitleView = Bundle.main.loadNibNamed("GroupNameTitleView", owner: self, options: nil)?.first as? GroupNameTitleView
        self.navigationItem.titleView = mGroupNameTitleView
        if let _groupNameTitleView = mGroupNameTitleView {
            let _tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(CirclesViewController.handleTapOnGroupTitleView))
            _groupNameTitleView.addGestureRecognizer(_tapGestureRecognizer)
        }
        
        ConnectionService.load(UserProfile.login, true) {(_ response : ServerResponse, _ myProfile : UserProfile?, _ error : Error?) in
            switch response.code {
            case .SUCCESS:
                self.getAllGroup()
                self.mCirclePresenter.startLocationUpdates()
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
            guard let _dest = segue.destination as? CreateUserViewController else {
                fatalError("CreateUserViewController not found");
            }
            
            _dest.delegate = self
            
        case .ShowSideMenuView:
            break
            
        }
    }
    
    private func presentCreateNewUserViewController() {
        self.performSegue(withIdentifier: SegueIdentifier.PresentCreateNewUserView.rawValue, sender: nil)
    }
    
    internal func populateMyCurrentLocation(_ location : CLLocation) {
        ConnectionService.load(UserProfile.createUpdateMyLocationResource(Float(location.coordinate.latitude), Float(location.coordinate.longitude)), false) { (_ response : ServerResponse, result : Any?, error : Error?) in
            switch response.code {
            case .SUCCESS:
                break
            case .FAILURE:
                print("Fail to populate my current position to server")
                break
            default:
                break
            }
        }
    }
    
    internal func getAllGroup() {
//        ConnectionService.load(Group.getAllGroups, true) {(_ response : ServerResponse, _ myProfile : Any?, _ error : Error?) in
//            switch response.code {
//            case .SUCCESS:
//                break
//            case .FAILURE:
//                break
//            default:
//                break
//            }
//        }
    }
    
    @objc private func handleTapOnGroupTitleView(_ gestureRecognizer : UITapGestureRecognizer) {
        print("Tap on title view")
        //TODO: create list group view controller and add its view to circle view controller
        let _listGroupViewController = self.storyboard!.instantiateViewController(withIdentifier: "ListGroupsViewController")
        _listGroupViewController.view.frame = CGRect(x: 0, y: 64, width: self.view.frame.size.width, height: self.view.frame.size.height * 0.5)
        self.addChildViewController(_listGroupViewController)
        self.view.addSubview(_listGroupViewController.view)
        _listGroupViewController.didMove(toParentViewController: self)
        
        self.view.bringSubview(toFront: _listGroupViewController.view)
        
    }

}

extension CirclesViewController : GroupLocationPresenterDelegate {
    func locationDidUpdate(_newLocation : CLLocation) {
        self.view.setNeedsLayout()
        print("new location: \(_newLocation.coordinate)")
        _myLocationMarker.position = _newLocation.coordinate
        _gmsMapView.camera = GMSCameraPosition.camera(withTarget: _newLocation.coordinate, zoom: Constants.GoogleMapsConfigs.DEFAULT_ZOOM)
        self.view.layoutIfNeeded()
        
        populateMyCurrentLocation(_newLocation)
    }
}

extension CirclesViewController : CreateUserViewControlerDelegate {
    func userInfoUpdateSuccessful() {
        self.mCirclePresenter.startLocationUpdates()
        self.getAllGroup()
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
