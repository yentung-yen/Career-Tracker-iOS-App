//
//  ForgotPasswordViewController.swift
//  jobApplication_prepTrack_app
//
//  Created by Chin Yen Tung on 23/5/2024.
//

import UIKit
import Firebase

class ForgotPasswordViewController: UIViewController {
    var authController: Auth?
    
    @IBOutlet weak var emailTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // access authController
        authController = Auth.auth()
    }
    
    // Code reference - https://www.youtube.com/watch?v=ScRSPEqxaNs
    @IBAction func onResetPassword(_ sender: Any) {
        // validate that email exist
        guard let email = emailTextField.text else {
            return
        }
    
        authController?.sendPasswordReset(withEmail: email) { [weak self] (error) in
            guard let self = self else { return }
            
            if let error = error {
                self.displayMessage(title: "Error", message: error.localizedDescription)
                return
            } else {
                self.displayMessage(title: "Success", message: "A reset password email has been sent. Please check your email :)")
            }
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
