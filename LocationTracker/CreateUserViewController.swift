//
//  CreateUserViewController.swift
//  LocationTracker
//
//  Created by Chuan Ho Danh on 7/26/17.
//  Copyright © 2017 tranght. All rights reserved.
//

import UIKit
import Validator

protocol CreateUserViewControlerDelegate : class {
    func userInfoUpdateSuccessful()
}

enum ValidationErrors : Error{
    case emailInvalid
    case requireField
    case minLengthField (minLength : Int)
}

extension ValidationErrors {
    var message : String {
        switch self {
        case .emailInvalid:
            return "Email is invalid"
        case .requireField:
            return "This field must not be empty"
        case .minLengthField(let minLength):
            return "This field must have at least \(minLength) characters"
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
    
    var validEmail : Bool = false
    var validName : Bool = false
    var validPhoneNumber : Bool = false
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
        
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }sel
    */

    @IBAction func doneBtnPressed(_ sender: Any) {
        
        if let _img = self.imgViewAvatar.image {
            ConnectionService.uploadImageToS3Server(_img) {(_ url : URL?, _ error : Error?) in
                if let error = error {
                    DispatchQueue.main.async {
                        self.createUserFailed(withError: error)
                    }
                    return
                }
                
                ConnectionService.load(UserProfile.createUpdateMyInfoResource(self.txtEmail.text, self.txtName.text, self.txtPhoneNumber.text, url?.absoluteString)) { (_ response : ServerResponse, _ myProfile : UserProfile?, _ error : Error?) in
                    
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
    
    private func createValidationRule(forTextField field : UITextField!, withRules rules : ValidationRuleSet<String>, updateStatusOn _label : UILabel!, handler: @escaping (Bool) -> Void ) {
        field.validationRules = rules
        
        field.validationHandler = { result in
            
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
            
            handler(valid)
            
        }
        
        field.validateOnInputChange(enabled: true)
    }
    
    private func validateRequiredFields() {
        
        let requiredField = ValidationRuleLength(min: 0, error: ValidationErrors.requireField)
        let emailRule = ValidationRulePattern(pattern: EmailValidationPattern.standard, error: ValidationErrors.emailInvalid)
        
        var emailRules = ValidationRuleSet<String>()
        emailRules.add(rule: requiredField)
        emailRules.add(rule: emailRule)
        
        createValidationRule(forTextField: self.txtEmail, withRules: emailRules, updateStatusOn: self.lblInputStatus) { valid in
            self.validEmail = valid
        }
        
        let phoneNumMinLengthRule = ValidationRuleLength(min: 10, error: ValidationErrors.minLengthField(minLength: 10))
        var phoneRules = ValidationRuleSet<String>()
        phoneRules.add(rule: phoneNumMinLengthRule)
        
        createValidationRule(forTextField: self.txtPhoneNumber, withRules: phoneRules, updateStatusOn: self.lblInputStatus) { valid in
            self.validPhoneNumber = valid
        }
        
        let nameMinLengthRule  = ValidationRuleLength(min: 3, error: ValidationErrors.minLengthField(minLength: 3))
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

extension CreateUserViewController : UINavigationControllerDelegate {
    
}

