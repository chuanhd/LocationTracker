//
//  JoinGroupViewController.swift
//  LocationTracker
//
//  Created by chuanhd on 8/21/17.
//  Copyright © 2017 tranght. All rights reserved.
//

import UIKit
import RMessage

protocol JoinGroupViewControllerDelegate : class {
    func didJoinGroupSuccessful(_ _group : Group)
}

class JoinGroupViewController: UIViewController {
    
    @IBOutlet weak var m_ContentView: UIView!
    @IBOutlet weak var m_txtGroupID: UITextField!
    @IBOutlet weak var m_btnJoinGroup: UIButton!
    
    weak var delegate : JoinGroupViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.isOpaque = false
        
        // Do any additional setup after loading the view.
        self.m_btnJoinGroup.layer.masksToBounds = true
        self.m_btnJoinGroup.layer.cornerRadius = 4.0
        
        let _tapGestureRecognizer  = UITapGestureRecognizer.init(target: self, action: #selector(JoinGroupViewController.handleTapOnRestOfView))
        _tapGestureRecognizer.delegate = self
        self.view.addGestureRecognizer(_tapGestureRecognizer)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func btnJoinGroupPressed(_ sender: Any) {
        guard let _groupIdStr = self.m_txtGroupID.text, _groupIdStr.count != 0 else {
            
            let _alertController = Utils.createAlertViewController(withTitle: "Warn", withMessage: "Please input group id")
            self.present(_alertController, animated: true, completion: nil)
            
            return
        }
        
        guard let _groupId = Int(_groupIdStr) else {
            
            let _alertController = Utils.createAlertViewController(withTitle: "Warn", withMessage: "Group id must be a number")
            self.present(_alertController, animated: true, completion: nil)
            
            return
        }
        
        self.joinGroup(withGroupId: _groupId)
    }
    
    internal func handleTapOnRestOfView(_ gestureRecognizer : UITapGestureRecognizer) {
        self.dismiss(animated: true, completion: nil)
    }
    
    internal func joinGroup(withGroupId _groupId : Int) {
        ConnectionService.load(UserProfile.joinGroup(AppController.sharedInstance.mUniqueToken, _groupId)) { (_serverResponse, _data, _error) in
            switch _serverResponse.code {
            case .SUCCESS:
                
                DispatchQueue.main.async {
                    RMessage.showNotification(withTitle: "Success", subtitle: "You have joined group successfully", type: RMessageType.success, customTypeName: nil, duration: TimeInterval(RMessageDuration.automatic.rawValue), callback: nil)
                    
                    guard let _groups = _data as? [Group], let _group = _groups.first else {
                        return
                    }
                    
                    if let _delegateMethod = self.delegate?.didJoinGroupSuccessful {
                        _delegateMethod(_group)
                    }
                    
                    self.dismiss(animated: true, completion: nil)
                    
                }
                
                break
            case .USER_IN_GROUP:
                
                DispatchQueue.main.async {
                    RMessage.showNotification(withTitle: "Notification", subtitle: "You are already in this group", type: RMessageType.warning, customTypeName: nil, duration: TimeInterval(RMessageDuration.automatic.rawValue), callback: nil)
                }
                
                break
            case .FAILURE:
                print("Fail to add member to group")
                
                DispatchQueue.main.async {
                    RMessage.showNotification(withTitle: "Failed", subtitle: "Join group failed. Please check group id or try again later", type: RMessageType.error, customTypeName: nil, duration: TimeInterval(RMessageDuration.automatic.rawValue), callback: nil)
                }
                
                break
            default:
                break
            }
        }
    }
}

extension JoinGroupViewController : UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let _tapGestureRecognizer = gestureRecognizer as? UITapGestureRecognizer else {
            return false
        }
        
        let _touchPoint = _tapGestureRecognizer.location(in: self.view)
        if self.m_ContentView.frame.contains(_touchPoint) {
            return false
        }
        
        return true
    }
}
