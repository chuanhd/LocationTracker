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
import Lightbox

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
    }
    
    internal func startRequestUserLocationTimer() {
        if let _timer = m_RequestUserLocationTimer {
            _timer.fire()
            return
        }
        
        m_RequestUserLocationTimer = Timer.scheduledTimer(timeInterval: 30, target: self, selector: #selector(CirclesViewController.fetchingDataTimerCallback), userInfo: nil, repeats: true);
        
        m_RequestUserLocationTimer!.fire()
    }
    
    internal func fetchingDataTimerCallback() {
        guard let _selectedGroup = self.m_SelectedGroupViewModel?.m_Group else {
            return
        }
        
//        self.requestUsersLocation()
        self.getGroupDetails(withGroupId: _selectedGroup.mId, showProgress: false)
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
        
        guard let _selectedGroupViewModel = self.m_SelectedGroupViewModel, let _selectedGroup = m_SelectedGroupViewModel?.m_Group, _selectedGroup.mId != -1 else {
            
            RMessage.showNotification(withTitle: "Notification", subtitle: "Please select or create a group", type: RMessageType.warning, customTypeName: nil, duration: TimeInterval(RMessageDuration.automatic.rawValue), callback: nil)
            
            return
        }
        
        self.m_GettingDirectionsIndicator.startAnimating()
        self.m_GettingDirectionsIndicator.isHidden = false
        
        _selectedGroupViewModel.createOrUpdateRouteToGroupDestination(onMap: self._gmsMapView) { [unowned self] (_error) in
            
            DispatchQueue.main.async {
                self.m_GettingDirectionsIndicator.stopAnimating()
                self.m_GettingDirectionsIndicator.isHidden = true
            }

            if _error != nil {
                DispatchQueue.main.async {
                    RMessage.showNotification(withTitle: "Failed", subtitle: "Failed to get direction from your location to your group's destination", type: RMessageType.error, customTypeName: nil, duration: TimeInterval(RMessageDuration.automatic.rawValue), callback: nil)
                }

            }
        }
    }
    
    @IBAction func btnImageUploadPressed(_ sender: Any) {
        
        guard let _selectedGroup = self.m_SelectedGroupViewModel?.m_Group, _selectedGroup.mId != -1 else {
            
            RMessage.showNotification(withTitle: "Notification", subtitle: "Please select or create a group", type: RMessageType.warning, customTypeName: nil, duration: TimeInterval(RMessageDuration.automatic.rawValue), callback: nil)
            
            return
        }
        
        let _imgPickerViewController = UIImagePickerController();
        _imgPickerViewController.delegate = self;
        _imgPickerViewController.allowsEditing = false;
        _imgPickerViewController.sourceType = .photoLibrary;
        
        self.present(_imgPickerViewController, animated: true, completion: nil);
    }
    
    @IBAction func btnRefreshPressed(_ sender: Any) {
        guard let _group = m_SelectedGroupViewModel?.m_Group else {
            return
        }
        
        if _group.mId == -1 {
            return
        }
        
//        DispatchQueue.main.async {
//            self._gmsMapView.clear()
//            _selectedGroupViewModel.createOrUpdateDestinationMarker(onMap: self._gmsMapView)
//        }
        
        self.getGroupDetails(withGroupId: _group.mId, showProgress: true)
        self.getGroupImages(withGroupId: _group.mId)
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
        self.getGroupImages(withGroupId: _group.mId)
        self.mGroupNameTitleView?.setGroupName(_group.mName)
        DispatchQueue.main.async {
//            self.m_SelectedGroupViewModel?.clearGroupMarkersAndRouteOnMap()
            self.m_SelectedGroupViewModel?.createOrUpdateDestinationMarker(onMap: self._gmsMapView)
            
            if let _myProfile = AppController.sharedInstance.mOwnProfile {
                self.m_SelectedGroupViewModel?.createOrUpdateMarkerForUser(withId: _myProfile.mId, withLat: _myProfile.mLatitude, withLong: _myProfile.mLongtitude, onMap: self._gmsMapView)
            }
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
        
        if let _myProfile = AppController.sharedInstance.mOwnProfile {
            self.m_SelectedGroupViewModel?.createOrUpdateMarkerForUser(withId: _myProfile.mId, withLat: _myProfile.mLatitude, withLong: _myProfile.mLongtitude, onMap: self._gmsMapView)
        }
        
    }
    
    func getGroupDetails(withGroupId _groupId : Int, showProgress _showProgress : Bool = true) {
        ConnectionService.load(Group.createGetGroupDetailResource(_groupId), _showProgress) { (_ response : ServerResponse, _ users : [Any]?, _ error : Error?) in
            switch response.code {
            case .SUCCESS:
                
                guard let users = users as? [UserProfile] else {
                    return
                }
                
                if let _selectedGroup = self.m_SelectedGroupViewModel?.m_Group {
                    _selectedGroup.mUsers = users
                    self.mMembersCollectionView.reloadData()
                    
                    for _userProfile in users {
                        DispatchQueue.main.async {
                            self.m_SelectedGroupViewModel?.createOrUpdateMarkerForUser(withId: _userProfile.mId, withLat: _userProfile.mLatitude, withLong: _userProfile.mLongtitude, onMap: self._gmsMapView)
                        }
                    }
                    
                }
                
                DispatchQueue.main.async {
                   self.m_SelectedGroupViewModel?.updateMarkerImageForUsers()
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
    
    func getGroupImages(withGroupId _groupId: Int) {
        ConnectionService.load(Group.createGetGroupImagesResource(_groupId)) { (_ response : ServerResponse, _ dicts : [Any]?, _ error : Error?) in
            switch response.code {
            case .SUCCESS:
                
                guard let _dicts = dicts as? [Dictionary<String, Any>] else {
                    return
                }
                
                if let _selectedGroupModel = self.m_SelectedGroupViewModel, let _selectedGroup = self.m_SelectedGroupViewModel?.m_Group {
                    var _arr = [GroupImage]()
                    for _dict in _dicts {
                        let _obj = GroupImage(m_Lat: _dict["lat"] as! Double,
                                              m_Lon: _dict["lon"] as! Double,
                                              m_OwnerID: _dict["userid"] as! String,
                                              m_Url: URL(string: _dict["url"] as! String)!)
                        _selectedGroupModel.createOrUpdateImageMarker(withGroupImage: _obj, onMap: self._gmsMapView)
                        _arr.append(_obj)
                        
                    }
                    
                    _selectedGroup.m_ArrGroupImages = _arr
                }
                
                break
            case .FAILURE:
                print("Fail to get group images")
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
        
        guard let _selectedGroup = self.m_SelectedGroupViewModel?.m_Group, _selectedGroup.mId != -1 else {
            
            RMessage.showNotification(withTitle: "Notification", subtitle: "Please select or create a group", type: RMessageType.warning, customTypeName: nil, duration: TimeInterval(RMessageDuration.automatic.rawValue), callback: nil)
            
            return
        }
        
        showSetDestinationView(at: coordinate)
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
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        guard let _groupViewModel = self.m_SelectedGroupViewModel else {
            return false
        }
        
        if _groupViewModel.isImageMarker(marker) {
            
            if let _customMarkerIconView = marker.iconView as? CustomImageMarkerIconView {
                let images = [
                    LightboxImage(imageURL: _customMarkerIconView.m_ImageURL!)
                ]

                let _imageViewController = LightboxController(images: images)
                _imageViewController.dynamicBackground = true
                
                present(_imageViewController, animated: true, completion: nil)
            }
            
            return true
        }
        
        return false
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
                        self.m_SelectedGroupViewModel!.clearRouteOnMap()
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

extension CirclesViewController : UIImagePickerControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil);
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
//            self.imgViewAvatar.contentMode = .scaleAspectFill
//            self.imgViewAvatar.image = pickedImage
            
            self.dismiss(animated: true, completion: nil);
            
            if let _myProfile = AppController.sharedInstance.mOwnProfile,
                let _selectedGroupViewModel = self.m_SelectedGroupViewModel {
                ConnectionService.uploadImageToS3Server(pickedImage, true) {(_ url : URL?, _ error : Error?) in
                    if error != nil {
                        DispatchQueue.main.async {
                            
                            RMessage.showNotification(withTitle: "Failed", subtitle: "Failed to upload image to server", type: RMessageType.error, customTypeName: nil, duration: TimeInterval(RMessageDuration.automatic.rawValue), callback: nil)
                        }
                        return
                    }
                    
                    print("Image uploaded url: \(String(describing: url?.absoluteString))")
                    
                    ConnectionService.load(UserProfile.uploadImage(_myProfile.mLatitude, _myProfile.mLongtitude, url!.absoluteString, _selectedGroupViewModel.m_Group!.mId)) { (_ response : ServerResponse, _ myProfile : [Any]?, _ error : Error?) in
                        DispatchQueue.main.async {
                            switch response.code {
                            case .SUCCESS:
                                
                                DispatchQueue.main.async {
                                    _selectedGroupViewModel.createOrUpdateImageMarker(withUserId: _myProfile.mId, withLat: _myProfile.mLatitude, withLong: _myProfile.mLongtitude, withImageUrl: url!, onMap: self._gmsMapView)
                                }
                                
                                break
                            case .FAILURE:
                                
                                DispatchQueue.main.async {
                                    
                                    RMessage.showNotification(withTitle: "Failed", subtitle: "Failed to upload image for group", type: RMessageType.error, customTypeName: nil, duration: TimeInterval(RMessageDuration.automatic.rawValue), callback: nil)
                                }
                                
                                break
                            default:
                                break
                            }
                        }
                    }
                    
                }
            }
        }
    }
}

extension CirclesViewController : EditProfileViewControllerDelegate {
    func updateInfoSuccessful(withNewModel _newModel: UserViewModel) {
        if let _users = self.m_SelectedGroupViewModel?.m_Group?.mUsers {
            
            for (_index, _profile) in _users.enumerated() {
                if _profile.mId == _newModel.m_UserProfile?.mId {
                    self.m_SelectedGroupViewModel?.m_Group?.mUsers[_index] = _newModel.m_UserProfile!
                    DispatchQueue.main.async {
                        self.mMembersCollectionView.reloadItems(at: [IndexPath(item: _index, section: 0)])
                        self.m_SelectedGroupViewModel?.createOrUpdateMarkerForUser(withId: _profile.mId, withLat: nil, withLong: nil, onMap: self._gmsMapView)
                    }
                }
            }
            
        }
    }
    
    func updateInfoFailed() {
        
    }
}

extension CirclesViewController : UINavigationControllerDelegate {
    
}
