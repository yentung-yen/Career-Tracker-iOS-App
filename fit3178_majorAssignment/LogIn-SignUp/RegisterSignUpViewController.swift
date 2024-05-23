//
//  RegisterSignUpViewController.swift
//  jobApplication_prepTrack_app
//
//  Created by Chin Yen Tung on 23/5/2024.
//

import UIKit
import FirebaseAuth

class RegisterSignUpViewController: UIViewController {
    weak var databaseController: DatabaseProtocol?
    var valid: Bool = false

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.firebaseDatabaseController
    }
    
    @IBAction func onRegisterSignUp(_ sender: Any) {
        print("register func")
        valid = validateRegister()
        print("register is \(valid)")
        
        if (valid){
            databaseController?.createUser(email: emailTextField.text!, password: passwordTextField.text!){ authResult, error in
                if let error = error {
                    self.displayMessage(title: "Error", message: error.localizedDescription)
                    
                } else if self.databaseController!.successfulSignUp {  // if true (ie new user was created successfully)
                    // reset successfulSignUp switch to false so that future users can still register on this device
                    self.databaseController!.successfulSignUp = false
                    
                    // go back to login screen
                    self.performSegue(withIdentifier: "registerToSignInSegue", sender: self)
                }
            }
        }
    }
    
    // validation =============================================
    func validateRegister() -> Bool {
        print("validate login sign up func")
        let result = validateEmail() && validateFields() && validatePassword()
        return result
    }
    
    func validateEmail() -> Bool {
        print("validate email func")
        
        let email = emailTextField.text
        
        // regular expression for email format
        let emailRegex = "[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"

        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        let result = emailPredicate.evaluate(with: email)
        print("Is this a valid email?:")
        print(emailPredicate.evaluate(with: email))
        
        if (result){
            return true
        } else {
            displayMessage(title: "Invalid Entry", message: "Invalid email")
            return false
        }
    }
    
    func validateFields() -> Bool {
        print("validate fields func")
        
        // ensure the user does not leave either field blank
        let email = emailTextField.text
        let pass = passwordTextField.text
        let confirmPass = confirmPasswordTextField.text
        
        if pass == "" || email == "" || confirmPass == "" {
            displayMessage(title: "Invalid Entry", message: "Please fill up all fields.")
            return false
        } else if pass!.count < 6 {
            displayMessage(title: "Invalid Password", message: "Password must be 6 characters long or more.")
            return false
        }
        return true
    }
    
    func validatePassword() -> Bool {
        print("check that password is the same")
        
        let pass = passwordTextField.text
        let confirmPass = confirmPasswordTextField.text
        
        if pass != confirmPass {
            displayMessage(title: "Error", message: "Password do not match.")
            return false
        }
        return true
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
