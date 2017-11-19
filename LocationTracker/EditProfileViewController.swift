//
//  EditProfileViewController.swift
//  LocationTracker
//
//  Created by chuanhd on 10/29/17.
//  Copyright © 2017 tranght. All rights reserved.
//

import UIKit
import SDWebImage
import RMessage

protocol EditProfileViewControllerDelegate : class{
    func updateInfoSuccessful(withNewModel _newModel : UserViewModel)
    func updateInfoFailed()
}

class EditProfileViewController: UIViewController {
    
    @IBOutlet weak var lblUsername : UILabel!
    @IBOutlet weak var txtEmail : UITextField!
    @IBOutlet weak var txtPhoneNumber : UITextField!
    @IBOutlet weak var imgAvatar : UIImageView!
    @IBOutlet weak var btnEdit : UIBarButtonItem!
    
    var isEmailValid = true
    var isPhoneNumberValid  = true
    
    weak var delegate : EditProfileViewControllerDelegate?
    
    enum ControllerState : Int {
        case VIEW = 0
        case EDIT = 1
    }
    
    private var m_State = ControllerState.VIEW
    public var m_UserProfile : UserViewModel?
    internal var m_AvatarChanged = false
    
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?, withUser _userViewModel : UserViewModel) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        self.m_UserProfile = _userViewModel;
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.m_UserProfile = UserViewModel(withProfile: AppController.sharedInstance.mOwnProfile!)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.syncViewModelInfo()
        
        self.txtEmail.isEnabled = false
        self.txtPhoneNumber.isEnabled = false
        
        self.txtEmail.delegate = self
        self.txtPhoneNumber.delegate = self
        
        let _tapAvatarGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(EditProfileViewController.handleTapOnAvatarGesture(_:)))
        self.imgAvatar.addGestureRecognizer(_tapAvatarGestureRecognizer)
        self.imgAvatar.isUserInteractionEnabled = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func syncViewModelInfo() {
        self.lblUsername.text = self.m_UserProfile?.m_Username
        self.txtPhoneNumber.text = self.m_UserProfile?.m_PhoneNumber
        self.txtEmail.text = self.m_UserProfile?.m_Email
        self.imgAvatar.sd_setImage(with: self.m_UserProfile?.m_AvatarURL, placeholderImage: #imageLiteral(resourceName: "default_avatar"), options: SDWebImageOptions.continueInBackground) { (_image : UIImage?, _error : Error?, _cachedType : SDImageCacheType, _url : URL?) in
            
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func btnEditProfilePressed(_ sender : Any) {
        if self.m_State == ControllerState.VIEW {
            self.syncEditStatus(true)
        } else {
            
            guard let _phoneNumberContent = self.txtPhoneNumber.text, _phoneNumberContent.count > 0,
                let _emailContent = self.txtEmail.text, _emailContent.count > 0 else {
                
                RMessage.showNotification(withTitle: "Error", subtitle: "Email and phone number are required", type: RMessageType.error, customTypeName: nil, duration: TimeInterval(RMessageDuration.automatic.rawValue), callback: nil)
                
                return
            }
            
            guard isEmailValid && isPhoneNumberValid else {
                
                RMessage.showNotification(withTitle: "Error", subtitle: "Email or phone number is in use", type: RMessageType.error, customTypeName: nil, duration: TimeInterval(RMessageDuration.automatic.rawValue), callback: nil)
                
                return
            }
            
            self.updateProfile()
//            self.syncEditStatus(false)
        }
    }
    
    func syncEditStatus(_ _isEditting : Bool) {
        if _isEditting {
            self.m_State = ControllerState.EDIT
            self.imgAvatar.isUserInteractionEnabled = true
            self.txtPhoneNumber.isEnabled = true
            self.txtEmail.isEnabled = true
            
            self.btnEdit.title = "Update"
        } else {
            self.m_State = ControllerState.VIEW
            self.imgAvatar.isUserInteractionEnabled = false
            self.txtPhoneNumber.isEnabled = false
            self.txtEmail.isEnabled = false
            
            self.btnEdit.title = "Edit"
        }
    }
    
    func handleTapOnAvatarGesture(_ recognizer : UITapGestureRecognizer) {
        let _imgPickerViewController = UIImagePickerController();
        _imgPickerViewController.delegate = self;
        _imgPickerViewController.allowsEditing = false;
        _imgPickerViewController.sourceType = .photoLibrary;
        
        self.present(_imgPickerViewController, animated: true, completion: nil);
    }
    
    private func updateProfile() {
        if self.m_AvatarChanged, let _img = self.imgAvatar.image {
            ConnectionService.uploadImageToS3Server(_img, true) {(_ url : URL?, _ error : Error?) in
                if let error = error {
                    DispatchQueue.main.async {
                        self.updateUserFailed(withError: error)
                    }
                    return
                }
                
                DispatchQueue.main.async {
                ConnectionService.load(UserProfile.createUpdateMyInfoResource(self.txtEmail.text, self.m_UserProfile?.m_Username, self.txtPhoneNumber.text, url?.absoluteString), true) { (_ response : ServerResponse, _ myProfile : [Any]?, _ error : Error?) in
                        // MyProfile should be [UserProfile]
                        DispatchQueue.main.async {
                            switch response.code {
                            case .SUCCESS:
                                self.updateUserProfileSuccessfully(url?.absoluteString)
                                break
                            case .FAILURE:
                                self.updateUserFailed(withError: error)
                                break
                            default:
                                break
                            }
                        }
                    }
                }
                
            }
        } else {
            ConnectionService.load(UserProfile.createUpdateMyInfoResource(self.txtEmail.text, self.m_UserProfile?.m_Username, self.txtPhoneNumber.text, self.m_UserProfile?.m_AvatarURL?.absoluteString), true) { (_ response : ServerResponse, _ myProfile : [Any]?, _ error : Error?) in
                // MyProfile should be [UserProfile]
                DispatchQueue.main.async {
                    switch response.code {
                    case .SUCCESS:
                        self.updateUserProfileSuccessfully(nil)
                        break
                    case .FAILURE:
                        self.updateUserFailed(withError: error)
                        break
                    default:
                        break
                    }
                }
            }
        }
    }
    
    private func updateUserProfileSuccessfully(_ avatarUrlString : String?) {
        
        self.m_UserProfile!.updateUserProfileModel(self.txtEmail.text, self.txtPhoneNumber.text, avatarUrlString)
        AppController.sharedInstance.mOwnProfile = self.m_UserProfile!.m_UserProfile
        
        DispatchQueue.main.async {
            self.syncEditStatus(false)
            
            RMessage.showNotification(withTitle: "Success", subtitle: "Update profile successfully", type: RMessageType.success, customTypeName: nil, duration: TimeInterval(RMessageDuration.automatic.rawValue), callback: nil)
        }
        
        if let _delegateMethod = self.delegate?.updateInfoSuccessful {
            _delegateMethod(self.m_UserProfile!)
        }
    }
    
    private func updateUserFailed(withError _error : Error?) {
        
        DispatchQueue.main.async {
            RMessage.showNotification(withTitle: "Error", subtitle: "Update profile failed", type: RMessageType.error, customTypeName: nil, duration: TimeInterval(RMessageDuration.automatic.rawValue), callback: nil)
        }
    }

}

extension EditProfileViewController : UIImagePickerControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil);
        self.m_AvatarChanged = false
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.imgAvatar.contentMode = .scaleAspectFill
            self.imgAvatar.image = pickedImage
            self.m_AvatarChanged = true
        } else {
            self.m_AvatarChanged = false
        }
        
        self.dismiss(animated: true, completion: nil);
    }
}

extension EditProfileViewController : UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let _content = textField.text else {
            return
        }
        
        if textField == self.txtEmail {
            ConnectionService.load(UserProfile.checkEmail(_content), false, completion: { (_serverResponse, _data, _error) in
                DispatchQueue.main.async {
                    switch _serverResponse.code {
                    case .SUCCESS:
                        self.isEmailValid = true
                        break
                    case .FAILURE:
                        RMessage.showNotification(withTitle: "Error", subtitle: "Email is already in use", type: RMessageType.error, customTypeName: nil, duration: TimeInterval(RMessageDuration.automatic.rawValue), callback: nil)
                        self.isEmailValid = false
                        break
                    default:
                        break
                    }
                }
            })
        } else if textField == self.txtPhoneNumber {
            ConnectionService.load(UserProfile.checkPhoneNumber(_content), false, completion: { (_serverResponse, _data, _error) in
                DispatchQueue.main.async {
                    switch _serverResponse.code {
                    case .SUCCESS:
                        self.isPhoneNumberValid = true
                        break
                    case .FAILURE:
                        RMessage.showNotification(withTitle: "Error", subtitle: "Phone number is already in use", type: RMessageType.error, customTypeName: nil, duration: TimeInterval(RMessageDuration.automatic.rawValue), callback: nil)
                        self.isPhoneNumberValid = false
                        break
                    default:
                        break
                    }
                }
            })
        }
    }
}

extension EditProfileViewController : UINavigationControllerDelegate {
    
}
