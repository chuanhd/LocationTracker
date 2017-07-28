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
    
    var validEmail : Bool = false
    var validName : Bool = false
    var validPhoneNumber : Bool = false
    var validFields : Bool  {
        let result = self.validEmail && self.validName && self.validPhoneNumber
        
        self.btnDone.isEnabled = result
        self.lblInputStatus.isHidden = result
        
        return result
    }
    
    weak var delegate : CreateUserViewControlerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        validateRequiredFields()
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    @IBAction func doneBtnPressed(_ sender: Any) {
        ConnectionService.load(UserProfile.createUpdateMyInfoResource(txtEmail.text, txtName.text, txtPhoneNumber.text)) { (_ response : ServerResponse, _ myProfile : UserProfile?, _ error : Error?) in
            
            switch response.code {
            case .SUCCESS:
                self.createUserSuccessfully()
                break
            case .FAILURE:
                self.createUserFailed()
                break
            default:
                break
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
    
    
    
    private func createUserSuccessfully() {
        self.dismiss(animated: true, completion: nil);
        
        delegate?.userInfoUpdateSuccessful()
    }
    
    private func createUserFailed() {
        
    }
}
