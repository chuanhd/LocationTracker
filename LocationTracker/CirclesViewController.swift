//
//  CirclesViewController.swift
//  LocationTracker
//
//  Created by chuanhd on 7/20/17.
//  Copyright © 2017 tranght. All rights reserved.
//

import UIKit
import GoogleMaps
import RMessage
import SCLAlertView

class CirclesViewController: UIViewController, SegueHandler {
    
    internal let TAG_LIST_GROUP_VIEW                        = 1105
    internal let TAG_SET_DESTINATION_VIEW                   = 1106

    @IBOutlet weak var _gmsMapView: GMSMapView!
    @IBOutlet weak var mMembersCollectionView : UICollectionView!
    @IBOutlet weak var m_ListGroupsView : ListGroupsView!
    @IBOutlet weak var m_GettingDirectionsIndicator : UIActivityIndicatorView!
    
    enum SegueIdentifier : String {
        case PresentCreateNewUserView  = "PresentCreateNewUserView"
        case ShowSideMenuView = "ShowSideMenuView"
        case PresentCreateNewGroupView = "PresentCreateNewGroupView"
        case PresentJoinGroupView = "PresentJoinGroupView"
        case PresentGroupMembersView = "PresentGroupMembersView"
    }
    
    internal let mCirclePresenter = GroupLocationPresenter()
    private let mCircleInfoPresenter = GroupInfoPresenter()
    
    internal var mGroupNameTitleView : GroupNameTitleView?
    
    internal var m_SelectedGroupViewModel : GroupViewModel? {
        didSet {
            guard let _titleView = self.mGroupNameTitleView else {
                return
            }
            
            guard let _group = self.m_SelectedGroupViewModel?.m_Group else {
                return
            }
            
            _titleView.setGroupName(_group.mName)
        }
    }
    
    private var m_RequestUserLocationTimer : Timer?
    private var m_MarkerDict = Dictionary<String, GMSMarker>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mGroupNameTitleView = Bundle.main.loadNibNamed("GroupNameTitleView", owner: self, options: nil)?.first as? GroupNameTitleView
        self.navigationItem.titleView = mGroupNameTitleView
        mGroupNameTitleView?.m_Delegate = self

        self.m_ListGroupsView.translatesAutoresizingMaskIntoConstraints = false
        self.m_ListGroupsView.delegate = self
        
        ConnectionService.load(UserProfile.login, true) {(_ response : ServerResponse, _ myProfile : [Any]?, _ error : Error?) in
            switch response.code {
            case .SUCCESS:
                self.fetchingDataForApp()
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
        _gmsMapView.settings.scrollGestures = true
        _gmsMapView.settings.zoomGestures = true
        _gmsMapView.delegate = self
        
        mCirclePresenter.delegate = self
        
        mMembersCollectionView.register(UINib(nibName: "GroupMemberCollectionViewCell", bundle: Bundle.main), forCellWithReuseIdentifier: Constants.CellIdentifier.MemberCollectionCellIdentifier)
        mMembersCollectionView.delegate = self
        mMembersCollectionView.dataSource = self
        
        let _flowLayout = UICollectionViewFlowLayout()
        _flowLayout.itemSize = CGSize(width: 60, height: 80)
        _flowLayout.sectionInset = UIEdgeInsetsMake(0, 5, 0, 5)
        _flowLayout.scrollDirection = UICollectionViewScrollDirection.horizontal
        _flowLayout.minimumInteritemSpacing = 10
        mMembersCollectionView.collectionViewLayout = _flowLayout
        
        m_GettingDirectionsIndicator.isHidden = true
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
            break
        case .ShowSideMenuView:
            break
        case .PresentCreateNewGroupView:
            guard let _dest = segue.destination as? CreateGroupViewController else {
                fatalError("CreateGroupViewController not found");
            }
            
            _dest.delegate = self
            break
        case .PresentJoinGroupView:
            guard let _dest = segue.destination as? JoinGroupViewController else {
                fatalError("JoinGroupViewController not found");
            }
            
            _dest.modalPresentationStyle = .overCurrentContext
            
            break
        case .PresentGroupMembersView:
            guard let _dest = segue.destination as? GroupMembersViewController else {
                fatalError("GroupMembersViewController not found");
            }
            
            guard let _group = sender as? Group else {
                fatalError("We expected that sender is Group object")
            }

            _dest.m_Group = _group
            _dest.navigationItem.title = _group.mName
            
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
    
    @objc private func handleTapOnGroupTitleView(_ gestureRecognizer : UITapGestureRecognizer) {
        print("Tap on title view")
        //TODO: create list group view controller and add its view to circle view controller
        
        if let _listGroupView = self.view.viewWithTag(TAG_LIST_GROUP_VIEW) {
            _listGroupView.removeFromSuperview()
        } else {
            showListGroupView()
        }
    }

    internal func showListGroupView() {
        
        self.m_ListGroupsView.getAllGroups()
        m_ListGroupsView.tag = TAG_LIST_GROUP_VIEW
        m_ListGroupsView.isHidden = false
        
    }
    
    internal func hideListGroupView() {
        
        m_ListGroupsView.isHidden = true
        mGroupNameTitleView?.imgDropdownIndicator.transform = CGAffineTransform(rotationAngle: 0)
    }
    
    internal func startRequestUserLocationTimer() {
        if m_RequestUserLocationTimer != nil {
            m_RequestUserLocationTimer!.invalidate();
            m_RequestUserLocationTimer = nil;
        }
        
        m_RequestUserLocationTimer = Timer.scheduledTimer(timeInterval: 30, target: self, selector: #selector(CirclesViewController.requestUsersLocation), userInfo: nil, repeats: true);
        
        m_RequestUserLocationTimer!.fire()
    }
    
    internal func requestUsersLocation() {
        guard let _selectedGroup = self.m_SelectedGroupViewModel?.m_Group else {
            return
        }
        for _userInfo in _selectedGroup.mUsers {
            if _userInfo.mId == AppController.sharedInstance.mUniqueToken {
                continue
            } else {
                self.requestUserLocation(_selectedGroup.mId, _userInfo.mId)
            }
        }
    }
    
    internal func requestUserLocation(_ _groupId : Int, _ _userId : String) {
        ConnectionService.load(UserProfile.getUserLocation(_groupId, _userId), false) { (_ response : ServerResponse, _ _positions : [Any]?, _ error : Error?) in
            switch response.code {
            case .SUCCESS:
                
                guard let _positions = _positions as? [Dictionary<String, Float>] else {
                    return
                }
                
                let _lat = _positions[0]["lat"]
                let _lon = _positions[0]["lon"]
                
                DispatchQueue.main.async {
                    self.m_SelectedGroupViewModel?.createOrUpdateMarkerForUser(withId: _userId, withLat: Double(_lat!), withLong: Double(_lon!), onMap: self._gmsMapView)
                }
                
                break
            case .FAILURE:
                print("Fail to get user location")
                break
            default:
                break
            }
        }
    }
    
    internal func fetchingDataForApp() {
        AppController.sharedInstance.fetchOwnProfile(showLoading: true) { (_response, _error) in
            switch _response.code {
            case .SUCCESS:
                
                self.m_SelectedGroupViewModel = GroupViewModel(withGroup: Group(withID: -1, withName: "My Circle"))
                let _contained = self.m_SelectedGroupViewModel!.m_Group!.mUsers.contains(where: { (_profile) -> Bool in
                    if _profile.mId == AppController.sharedInstance.mOwnProfile?.mId {
                        return true
                    }
                    
                    return false
                })
                
                if !_contained {
                    self.m_SelectedGroupViewModel!.m_Group!.mUsers.append(AppController.sharedInstance.mOwnProfile!)
                }
                
                DispatchQueue.main.async {
                    self.mCirclePresenter.startLocationUpdates()
                    self.mMembersCollectionView.reloadData()
                }
                
                break
            case .FAILURE:
                print("Fail to fetch my profile")
                DispatchQueue.main.async {
                    
                    let retryCallback : () -> () = {
                        self.fetchingDataForApp()
                    }
                    
                    RMessage.showNotification(withTitle: "Error", subtitle: "Fail to get app data", iconImage: nil, type: RMessageType.error, customTypeName: nil, duration: TimeInterval(RMessageDuration.automatic.rawValue), callback: nil, buttonTitle: "Retry", buttonCallback: retryCallback, at: RMessagePosition.top, canBeDismissedByUser: false)

                }
                break
            default:
                break
            }
        }
        self.m_ListGroupsView.getAllGroups()
    }
    
    @IBAction func btnNavigationPressed(_ sender: Any) {
        
        guard let _selectedGroup = self.m_SelectedGroupViewModel?.m_Group else {
            return
        }
        
        guard _selectedGroup.mId != -1 else {
            return
        }
        
        guard let _destLat = _selectedGroup.m_DestLat, let _destLon = _selectedGroup.m_DestLon else {
            return
        }
        
        self.m_GettingDirectionsIndicator.startAnimating()
        self.m_GettingDirectionsIndicator.isHidden = false
        
        if let _myProfile = AppController.sharedInstance.mOwnProfile {
            let _origin = CLLocationCoordinate2D(latitude: _myProfile.mLatitude, longitude: _myProfile.mLongtitude)
            let _destination = CLLocationCoordinate2D(latitude: _destLat, longitude: _destLon)
            GoogleMapsDirectionsHelper.getDirection(from: _origin, to: _destination,
                                                    completion: { ( _response, _polyline, _error) in
                                                        
                                                        DispatchQueue.main.async {
                                                            self.m_GettingDirectionsIndicator.stopAnimating()
                                                            self.m_GettingDirectionsIndicator.isHidden = true
                                                        }
                                                        
                                                        switch _response.code {
                                                        case .SUCCESS:
                                                            
                                                            DispatchQueue.main.async {
                                                                _polyline?.map = self._gmsMapView
                                                            }
                                                            
                                                        case .FAILURE:
                                                            print("Fail to get direction from my location to group destination")
                                                            
                                                            DispatchQueue.main.async {
                                                                RMessage.showNotification(withTitle: "Failed", subtitle: "Failed to get direction from your location to your group's destination", type: RMessageType.error, customTypeName: nil, duration: TimeInterval(RMessageDuration.automatic.rawValue), callback: nil)
                                                            }
                                                            
                                                            break
                                                        default:
                                                            break
                                                        }
                                                        
                                                        
            })
        }
        
    }
    
}

extension CirclesViewController : GroupLocationPresenterDelegate {
    func locationDidUpdate(_newLocation : CLLocation) {
        self.view.setNeedsLayout()
        print("new location: \(_newLocation.coordinate)")
        
        if let _myProfile = AppController.sharedInstance.mOwnProfile {
            _myProfile.mLatitude = _newLocation.coordinate.latitude
            _myProfile.mLongtitude = _newLocation.coordinate.longitude
            
            self.m_SelectedGroupViewModel?.createOrUpdateMarkerForUser(withId: _myProfile.mId, withLat: _myProfile.mLatitude, withLong: _myProfile.mLongtitude, onMap: self._gmsMapView)
            
            let _coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(_myProfile.mLatitude), longitude: CLLocationDegrees(_myProfile.mLongtitude))
            let _update = GMSCameraUpdate.setTarget(_coordinate)
            self._gmsMapView.moveCamera(_update)
        }
        
        self.view.layoutIfNeeded()
        
        populateMyCurrentLocation(_newLocation)
    }
}

extension CirclesViewController : CreateUserViewControlerDelegate {
    func userInfoUpdateSuccessful() {
        fetchingDataForApp()
    }
}

extension CirclesViewController : ListGroupViewDelegate {
    func didTapRequestJoinGroup() {
        self.hideListGroupView()
        self.performSegue(withIdentifier: SegueIdentifier.PresentJoinGroupView.rawValue, sender: nil)
        
    }
    
    func didTapCreateGroup() {
        self.hideListGroupView()
        self.performSegue(withIdentifier: SegueIdentifier.PresentCreateNewGroupView.rawValue, sender: nil)
    }
    
    func didSelectGroup(_ _group : Group) {
        self.hideListGroupView()
        self.m_SelectedGroupViewModel = GroupViewModel(withGroup: _group)
        self.getGroupDetails(withGroupId: _group.mId)
        self.mGroupNameTitleView?.setGroupName(_group.mName)
//        self.mGroupNameTitleView?.lblGroupName.text = _group.mName
        DispatchQueue.main.async {
            self.m_SelectedGroupViewModel?.createOrUpdateDestinationMarker(onMap: self._gmsMapView)
        }
        
    }
    
    func didConfigureGroup(_ _group: Group) {
        self.hideListGroupView()
        self.performSegue(withIdentifier: SegueIdentifier.PresentGroupMembersView.rawValue, sender: _group)
    }
}

extension CirclesViewController : CreateGroupViewControllerDelegate {

    func createNewGroupSuccessful(withGroupId _groupId: Int!, withGroupName _groupName: String) {
        
        self.m_SelectedGroupViewModel = GroupViewModel(withGroup: Group(withID: _groupId, withName: _groupName))
        
        self.getGroupDetails(withGroupId: _groupId)
    }
    
    func getGroupDetails(withGroupId _groupId : Int) {
        ConnectionService.load(Group.createGetGroupDetailResource(_groupId)) { (_ response : ServerResponse, _ users : [Any]?, _ error : Error?) in
            switch response.code {
            case .SUCCESS:
                
                guard let users = users as? [UserProfile] else {
                    return
                }
                
                if let _selectedGroup = self.m_SelectedGroupViewModel?.m_Group {
                    _selectedGroup.mUsers = users
                    self.mMembersCollectionView.reloadData()
                    self.startRequestUserLocationTimer()
                }
                break
            case .FAILURE:
                print("Fail to get group details")
                break
            default:
                break
            }
        }
    }
}

extension CirclesViewController : UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let _selectedGroup = self.m_SelectedGroupViewModel?.m_Group {
            let _userProfile = _selectedGroup.mUsers[indexPath.row]
            let _coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(_userProfile.mLatitude), longitude: CLLocationDegrees(_userProfile.mLongtitude))
            let _update = GMSCameraUpdate.setTarget(_coordinate)
            self._gmsMapView.moveCamera(_update)
        } else {
//            if let _myProfile = AppController.sharedInstance.mOwnProfile {
//
//            }
        }
    }
}

extension CirclesViewController : UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let _selectedGroup = self.m_SelectedGroupViewModel?.m_Group {
            return _selectedGroup.mUsers.count
        }
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let _cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.CellIdentifier.MemberCollectionCellIdentifier, for: indexPath) as? GroupMemberCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        if let _selectedGroup = self.m_SelectedGroupViewModel?.m_Group {
            let _userProfile = _selectedGroup.mUsers[indexPath.row] 
            _cell.bindDataToView(_userProfile)
        } else {
            if let _myProfile = AppController.sharedInstance.mOwnProfile {
                _cell.bindDataToView(_myProfile)
            }
        }
        
        return _cell
    }
}

extension CirclesViewController : GroupNameTitleViewDelegate {
    func didTapOnGroupName() {
        if m_ListGroupsView.isHidden {
            showListGroupView()
        } else {
            hideListGroupView()
        }
    }
}

extension CirclesViewController : GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        
    }
    
    func mapView(_ mapView: GMSMapView, didLongPressAt coordinate: CLLocationCoordinate2D) {
//        showSetDestinationView(at: coordinate)
        showActionSheet(at: coordinate)
    }
    
    func showSetDestinationView(at _coordicate : CLLocationCoordinate2D) {
        if let _setDestinationView = self.view.viewWithTag(TAG_SET_DESTINATION_VIEW) as? SetDestinationView {
            let _viewModel = AddressViewModel(withCoordinate: _coordicate)
            _setDestinationView.m_AddressViewModel = _viewModel
        } else {
            guard let _view = Bundle.main.loadNibNamed("SetDestinationView", owner: self, options: nil)?.first as? SetDestinationView else {
                return
            }
            
            let _viewModel = AddressViewModel(withCoordinate: _coordicate)
            _view.tag = TAG_SET_DESTINATION_VIEW
            _view.delegate = self
            _view.m_AddressViewModel = _viewModel
            self._gmsMapView.addSubview(_view)
            
            _view.snp.makeConstraints({ (make) in
                make.centerX.equalTo(self._gmsMapView.snp.centerX)
                make.bottom.equalTo(self._gmsMapView.snp.bottom).offset(-108)
                make.width.equalTo(260)
                make.height.equalTo(125)
            })
            
        }
    }
    
    func showImagesPickerView() {
        
    }
    
    func showActionSheet(at _coordicate : CLLocationCoordinate2D) {
        let _appearance = SCLAlertView.SCLAppearance(
            showCloseButton: false,
            hideWhenBackgroundViewIsTapped : true
        )
        
        let _alert = SCLAlertView(appearance: _appearance)
        _alert.addButton("Add images", target: self, selector: #selector(CirclesViewController.showImagesPickerView))
//        _alert.addButton("Set Destination", target: self, selector: #selector(CirclesViewController.showSetDestinationView(at:)))
        _alert.addButton("Set destination") { [unowned self] in
            self.showSetDestinationView(at: _coordicate)
        }
        
        _alert.showInfo("Select your action", subTitle: "Please select one of below actions")
    }
}

extension CirclesViewController : SetDestinationViewDelegate {
    func didSetDestination(at _coordinate: CLLocationCoordinate2D) {
        if let _setDestinationView = self.view.viewWithTag(TAG_SET_DESTINATION_VIEW) as? SetDestinationView {
        
            guard let _selectedGroup = self.m_SelectedGroupViewModel?.m_Group else {
                return
            }
        
            ConnectionService.load(Group.setDestination(_selectedGroup.mId, AppController.sharedInstance.mUniqueToken, Float(_coordinate.latitude), Float(_coordinate.longitude)), true, completion: { ( _response, _result, _error) in
                switch _response.code {
                case .SUCCESS:
                    
                    DispatchQueue.main.async {
                        self.m_SelectedGroupViewModel!.m_Group?.m_DestLat = _coordinate.latitude
                        self.m_SelectedGroupViewModel!.m_Group?.m_DestLon = _coordinate.longitude
                        self.m_SelectedGroupViewModel!.createOrUpdateDestinationMarker(onMap: self._gmsMapView)
                        
                    }
                    
                    break
                case .FAILURE:
                    print("Fail to set destination of group")
                    break
                default:
                    break
                }
            })
            
            _setDestinationView.removeFromSuperview()
        }
    }
}
