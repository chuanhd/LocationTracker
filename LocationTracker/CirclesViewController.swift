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
    
    internal let TAG_LIST_GROUP_VIEW                        = 1105
    internal let TAG_SET_DESTINATION_VIEW                   = 1106

    @IBOutlet weak var _gmsMapView: GMSMapView!
    @IBOutlet weak var mMembersCollectionView : UICollectionView!
    @IBOutlet weak var m_ListGroupsView : ListGroupsView!
    
    enum SegueIdentifier : String {
        case PresentCreateNewUserView  = "PresentCreateNewUserView"
        case ShowSideMenuView = "ShowSideMenuView"
        case PresentCreateNewGroupView = "PresentCreateNewGroupView"
        case PresentJoinGroupView = "PresentJoinGroupView"
        case PresentGroupMembersView = "PresentGroupMembersView"
    }
    
    internal let _myLocationMarker = GMSMarker();
    
    internal let mCirclePresenter = GroupLocationPresenter()
    private let mCircleInfoPresenter = GroupInfoPresenter()
    
    internal var mGroupNameTitleView : GroupNameTitleView?
    
    internal var mSelectedGroup : Group?
    
    private var m_RequestUserLocationTimer : Timer?
    private var m_MarkerDict = Dictionary<String, GMSMarker>()
    
    // Hack for iOS 11
    private lazy var m_NavBarActionButton_iOS11 = UIButton()
    
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
                self.m_ListGroupsView.getAllGroups()
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
        _gmsMapView.settings.scrollGestures = true
        _gmsMapView.settings.zoomGestures = true
        _gmsMapView.delegate = self
        
        // Creates a marker in the center of the map.
        _myLocationMarker.position = CLLocationCoordinate2D(latitude: -33.86, longitude: 151.20)
        _myLocationMarker.title = "Sydney"
        _myLocationMarker.snippet = "Australia"
        _myLocationMarker.map = _gmsMapView
        
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
//        let _listGroupViewController = self.storyboard!.instantiateViewController(withIdentifier: "ListGroupsViewController") as! ListGroupsViewController
//        mListGroupViewController.view.frame = CGRect(x: 0, y: 64, width: self.view.frame.size.width, height: self.view.frame.size.height * 0.5)
//        mListGroupViewController.delegate = self
//        self.addChildViewController(mListGroupViewController)
//        self.view.addSubview(mListGroupViewController.view)
//        mListGroupViewController.didMove(toParentViewController: self)
//
//        self.view.bringSubview(toFront: mListGroupViewController.view)
//        mListGroupViewController.view.tag = TAG_LIST_GROUP_VIEW
//
//        mGroupNameTitleView?.imgDropdownIndicator.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
        
        m_ListGroupsView.tag = TAG_LIST_GROUP_VIEW
        m_ListGroupsView.isHidden = false
        
    }
    
    internal func hideListGroupView() {
        
//        if let _childViewController = self.childViewControllers[0] as? ListGroupsViewController {
//            _childViewController.delegate = nil
//            _childViewController.removeFromParentViewController()
//        }
//        
//        if let _listGroupView = self.view.viewWithTag(TAG_LIST_GROUP_VIEW) {
//            _listGroupView.removeFromSuperview()
//        }
        
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
        guard let _selectedGroup = self.mSelectedGroup else {
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
                    self.syncUserLocationMarker(_userId, _lat!, _lon!)
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
    
    internal func syncUserLocationMarker(_ userId : String, _ lat : Float, _ lon : Float) {
        if let _marker = m_MarkerDict[userId] {
            let _newLocation = CLLocation(latitude: Double(lat), longitude: Double(lon))
            _marker.position = _newLocation.coordinate
        } else {
            
            let position = CLLocationCoordinate2D(latitude: Double(lat), longitude: Double(lon))
            let _marker = GMSMarker(position: position)
            _marker.map = _gmsMapView
            let _customMarkerIconView = CustomMarkerIconView(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
            if let _selectedGroup = self.mSelectedGroup {
                if let _userProfile = (_selectedGroup.mUsers.filter { $0.mId == userId}).first {
                    _customMarkerIconView.loadImage(fromURL: URL(string: _userProfile.mAvatarURLStr)!)
                }
            }
            
            _marker.iconView = _customMarkerIconView
            m_MarkerDict[userId] = _marker
            
        }
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
        self.m_ListGroupsView.getAllGroups()
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
        self.mSelectedGroup = _group
        self.getGroupDetails(withGroupId: _group.mId)
        self.mGroupNameTitleView?.setGroupName(_group.mName)
//        self.mGroupNameTitleView?.lblGroupName.text = _group.mName
    }
    
    func didConfigureGroup(_ _group: Group) {
        self.hideListGroupView()
        self.performSegue(withIdentifier: SegueIdentifier.PresentGroupMembersView.rawValue, sender: _group)
    }
}

extension CirclesViewController : CreateGroupViewControllerDelegate {
    func createNewGroupSuccessful(withGroupId _groupId: Int!) {
        self.getGroupDetails(withGroupId: _groupId)
    }
    
    func getGroupDetails(withGroupId _groupId : Int) {
        ConnectionService.load(Group.createGetGroupDetailResource(_groupId)) { (_ response : ServerResponse, _ users : [Any]?, _ error : Error?) in
            switch response.code {
            case .SUCCESS:
                
                guard let users = users as? [UserProfile] else {
                    return
                }
                
                if let _selectedGroup = self.mSelectedGroup {
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
        
    }
}

extension CirclesViewController : UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let _selectedGroup = self.mSelectedGroup {
            return _selectedGroup.mUsers.count
        }
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let _cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.CellIdentifier.MemberCollectionCellIdentifier, for: indexPath) as? GroupMemberCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        if let _selectedGroup = self.mSelectedGroup {
            let _userProfile = _selectedGroup.mUsers[indexPath.row] 
            _cell.bindDataToView(_userProfile)
        } else {
            
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
        showSetDestinationView(at: coordinate)
    }
    
    func mapView(_ mapView: GMSMapView, didLongPressAt coordinate: CLLocationCoordinate2D) {
        
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
}

extension CirclesViewController : SetDestinationViewDelegate {
    func didSetDestination(at _coordinate: CLLocationCoordinate2D) {
        if let _setDestinationView = self.view.viewWithTag(TAG_SET_DESTINATION_VIEW) as? SetDestinationView {
            _setDestinationView.removeFromSuperview()
            // TODO: Sent destination coordinate to server
        }
    }
}
