//
//  LogInViewController.swift
//  jobApplication_prepTrack_app
//
//  Created by Chin Yen Tung on 23/5/2024.
//

import UIKit
import FirebaseAuth

class LogInViewController: UIViewController {
    weak var databaseController: DatabaseProtocol?
    
    var authController: Auth?
    var authStateListener: AuthStateDidChangeListenerHandle?
    var valid: Bool = false

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        // access authController
        authController = Auth.auth()
    }
    
    
    @IBAction func onLogIn(_ sender: Any) {
        print("login func")
        
        valid = validateLoginSignUp()
        
        if (valid){
            databaseController?.loginUser(email: emailTextField.text!, password: passwordTextField.text!){ authResult, error in
                if let error = error {
                    if self.authController?.currentUser == nil {
                        // unsuccessful login
                        self.displayMessage(title: "Login Error", message: "Wrong email or password.")
                    }
                } else {
                    print("Login Successful")
                }
            }
        }
    }
    
    
    // validation =============================================
    func validateLoginSignUp() -> Bool{
        print("validate login sign up func")
        let result = validateFields() && validateEmail()
        print(result)
        return result
    }
    
    func validateEmail() -> Bool{
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
    
    func validateFields() -> Bool{
        print("validate fields func")
        
        // ensure the user does not leave either field blank
        let email = emailTextField.text
        let pass = passwordTextField.text
        
        if pass == "" || email == "" {
            displayMessage(title: "Invalid Entry", message: "Please fill up both fields.")
            return false
        } else if pass!.count < 6 {
            displayMessage(title: "Invalid Password", message: "Password must be 6 characters long or more.")
            return false
        }
        return true
    }
    
    
    // Listener for Authentication events ==================================================
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        authStateListener = authController?.addStateDidChangeListener { auth, user in
            // Check if user is nil to determine whether user is signed in or not
            if user != nil {
                // User is signed in, navigate to journal entry screen
                self.performSegue(withIdentifier: "currentUserTrueLoginSegue", sender: self)
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let listener = authStateListener {
            authController?.removeStateDidChangeListener(listener)
        }
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
