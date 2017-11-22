//
//  CreateUserViewController.swift
//  LocationTracker
//
//  Created by Chuan Ho Danh on 7/26/17.
//  Copyright © 2017 tranght. All rights reserved.
//

import UIKit
import Validator
import RMessage

protocol CreateUserViewControlerDelegate : class {
    func userInfoUpdateSuccessful()
}

enum ValidationErrors : Error{
    case emailInvalid
    case requireField (fieldName : String)
    case minLengthField (fieldName: String, minLength : Int)
}

extension ValidationErrors {
    var message : String {
        switch self {
        case .emailInvalid:
            return "Email is invalid"
        case .requireField(let _fieldName):
            return "\(_fieldName) field must not be empty"
        case .minLengthField(let _fieldName, let minLength):
            return "\(_fieldName) field must have at least \(minLength) characters"
        }
    }
}

class CreateUserViewController: UIViewController {

    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtName : UITextField!
    @IBOutlet weak var txtPhoneNumber : UITextField!
    @IBOutlet weak var btnDone: UIBarButtonItem!
    @IBOutlet weak var lblInputStatus: UILabel!
    @IBOutlet weak var imgViewAvatar : UIImageView!
    @IBOutlet weak var indicatorCheckEmail : UIActivityIndicatorView!
    @IBOutlet weak var indicatorCheckUsername : UIActivityIndicatorView!
    @IBOutlet weak var indicatorCheckPhoneNumber : UIActivityIndicatorView!
    
    @IBOutlet weak var constraintCheckEmailLoadingWidth: NSLayoutConstraint!
    @IBOutlet weak var constraintCheckUsernameLoadingWidth: NSLayoutConstraint!
    @IBOutlet weak var constraintCheckPhoneNumberLoadingWidth: NSLayoutConstraint!
    
    let m_IndicatorLoadingViewWidth : CGFloat = 20.0
    
    var validEmail : Bool = true
    var validName : Bool = true
    var validPhoneNumber : Bool = true
    var validFields : Bool  {
        let result = self.validEmail && self.validName && self.validPhoneNumber
        
//        self.btnDone.isEnabled = result
        self.lblInputStatus.isHidden = result
        
        return result
    }
    
    weak var delegate : CreateUserViewControlerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        validateRequiredFields()
        
        self.imgViewAvatar.isUserInteractionEnabled = true
        self.imgViewAvatar.clipsToBounds = true;
        self.imgViewAvatar.layer.cornerRadius = 4.0;
        
        self.txtName.delegate = self
        self.txtEmail.delegate = self
        self.txtPhoneNumber.delegate = self
        
        self.indicatorCheckEmail.hidesWhenStopped = true
        self.indicatorCheckUsername.hidesWhenStopped = true
        self.indicatorCheckPhoneNumber.hidesWhenStopped = true
        
        self.indicatorCheckEmail.stopAnimating()
        self.indicatorCheckPhoneNumber.stopAnimating()
        self.indicatorCheckUsername.stopAnimating()
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }sel
    */

    @IBAction func doneBtnPressed(_ sender: Any) {
        
        guard validFields else {
            RMessage.showNotification(withTitle: "Error", subtitle: "Some fields are empty or values are in use", type: RMessageType.error, customTypeName: nil, duration: TimeInterval(RMessageDuration.automatic.rawValue), callback: nil)
            return
        }
        
        print("Valid input")
        
        if let _img = self.imgViewAvatar.image {
            ConnectionService.uploadImageToS3Server(_img, true) {(_ url : URL?, _ error : Error?) in
                if let error = error {
                    DispatchQueue.main.async {
                        self.createUserFailed(withError: error)
                    }
                    return
                }

                DispatchQueue.main.async {
                    ConnectionService.load(UserProfile.createUpdateMyInfoResource(self.txtEmail.text, self.txtName.text, self.txtPhoneNumber.text, url?.absoluteString)) { (_ response : ServerResponse, _ myProfile : [Any]?, _ error : Error?) in
                        // MyProfile should be [UserProfile]
                        DispatchQueue.main.async {
                            switch response.code {
                            case .SUCCESS:
                                self.createUserSuccessfully()
                                break
                            case .FAILURE:
                                self.createUserFailed(withError: error)
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
    
    private func createValidationRule(forTextField field : UITextField!, withRules rules : ValidationRuleSet<String>, updateStatusOn _label : UILabel!, handler: @escaping (Bool) -> Void ) {
        
        field.validationRules = rules
        
        field.validationHandler = { [unowned self] result in
            
            var valid : Bool = true
            
            switch result {
            case .valid:
                valid = true
                break;
            case .invalid(let failureErrors):
                valid = false
                guard let errors = failureErrors as? [ValidationErrors] else {
                    break
                }
                let messages = errors.map { $0.message }
                _label.text = messages.first
                break;
            }
            
            self.lblInputStatus.isHidden = self.validFields
            
            handler(valid)
            
        }
        
        field.validateOnInputChange(enabled: true)
        field.validateOnEditingEnd(enabled: true)
    }
    
    private func validateRequiredFields() {
        
        let emailRequiredField = ValidationRuleLength(min: 0, error: ValidationErrors.requireField(fieldName: "Email"))
        let emailRule = ValidationRulePattern(pattern: EmailValidationPattern.standard, error: ValidationErrors.emailInvalid)
        
        var emailRules = ValidationRuleSet<String>()
        emailRules.add(rule: emailRequiredField)
        emailRules.add(rule: emailRule)
        
        createValidationRule(forTextField: self.txtEmail, withRules: emailRules, updateStatusOn: self.lblInputStatus) { valid in
            self.validEmail = valid
        }
        
        let phoneNumMinLengthRule = ValidationRuleLength(min: 10, error: ValidationErrors.minLengthField(fieldName: "Phone number" ,minLength: 10))
        var phoneRules = ValidationRuleSet<String>()
        phoneRules.add(rule: phoneNumMinLengthRule)
        
        createValidationRule(forTextField: self.txtPhoneNumber, withRules: phoneRules, updateStatusOn: self.lblInputStatus) { valid in
            self.validPhoneNumber = valid
        }
        
        let nameMinLengthRule  = ValidationRuleLength(min: 3, error: ValidationErrors.minLengthField(fieldName: "Username", minLength: 3))
        var nameRules = ValidationRuleSet<String>()
        nameRules.add(rule: nameMinLengthRule)
        
        createValidationRule(forTextField: self.txtName, withRules: nameRules, updateStatusOn: self.lblInputStatus) { valid in
            self.validName = valid
        }
        
    }
    
    @IBAction func handleTapOnAvatar(_ sender: Any) {
        let _imgPickerViewController = UIImagePickerController();
        _imgPickerViewController.delegate = self;
        _imgPickerViewController.allowsEditing = false;
        _imgPickerViewController.sourceType = .photoLibrary;
        
        self.present(_imgPickerViewController, animated: true, completion: nil);
        
    }
    
    
    private func createUserSuccessfully() {
        self.dismiss(animated: true, completion: nil);
        
        delegate?.userInfoUpdateSuccessful()
    }
    
    private func createUserFailed(withError _error : Error?) {
        RMessage.showNotification(withTitle: "Error", subtitle: "Some fields are empty or values are in use", type: RMessageType.error, customTypeName: nil, duration: TimeInterval(RMessageDuration.automatic.rawValue), callback: nil)
    }
}

extension CreateUserViewController : UIImagePickerControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil);
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.imgViewAvatar.contentMode = .scaleAspectFill
            self.imgViewAvatar.image = pickedImage
        }
        
        self.dismiss(animated: true, completion: nil);
    }
}

extension CreateUserViewController : UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        textField.validate()
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let _content = textField.text, _content.isEmpty == false else {
            return
        }
        if textField == self.txtEmail {
            self.indicatorCheckEmail.startAnimating()
            ConnectionService.load(UserProfile.checkEmail(_content), false, completion: { (_serverResponse, _data, _error) in
                DispatchQueue.main.async {
                    self.indicatorCheckEmail.stopAnimating()
                    switch _serverResponse.code {
                    case .SUCCESS:
                        break
                    case .FAILURE:
                        self.validEmail = false
                        self.lblInputStatus.text = "Email is already in used"
                        break
                    default:
                        break
                    }
                    self.lblInputStatus.isHidden = self.validFields
                }
            })
        } else if textField == self.txtPhoneNumber {
            self.indicatorCheckPhoneNumber.startAnimating()
            ConnectionService.load(UserProfile.checkPhoneNumber(_content), false, completion: { (_serverResponse, _data, _error) in
                DispatchQueue.main.async {
                    self.indicatorCheckPhoneNumber.stopAnimating()
                    switch _serverResponse.code {
                    case .SUCCESS:
//                        self.phoneNotUsed = true
                        break
                    case .FAILURE:
                        self.validPhoneNumber = false
                        self.lblInputStatus.text = "Phone number is already in used"
                        break
                    default:
                        break
                    }
                    self.lblInputStatus.isHidden = self.validFields
                }
            })
        } else if textField == self.txtName {
            self.indicatorCheckUsername.startAnimating()
            ConnectionService.load(UserProfile.checkUsername(_content), false, completion: { (_serverResponse, _data, _error) in
                DispatchQueue.main.async {
                    self.indicatorCheckUsername.stopAnimating()
                    switch _serverResponse.code {
                    case .SUCCESS:
                        break
                    case .FAILURE:
                        self.validName = false
                        self.lblInputStatus.text = "Username is already in used"
                        break
                    default:
                        break
                    }
                    self.lblInputStatus.isHidden = self.validFields
                }
            })
        }
        
        
    }
}

extension CreateUserViewController : UINavigationControllerDelegate {
    
}

