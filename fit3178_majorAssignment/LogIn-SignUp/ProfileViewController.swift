//
//  ProfileViewController.swift
//  jobApplication_prepTrack_app
//
//  Created by Chin Yen Tung on 23/5/2024.
//

import UIKit
import FirebaseAuth

class ProfileViewController: UIViewController {
    weak var databaseController: DatabaseProtocol?
    
    // listener to listen for changes in authentication states
    var authStateListener: AuthStateDidChangeListenerHandle?
    var authController: Auth?

    @IBOutlet weak var emailLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        // access authController
        authController = Auth.auth()
        
        // setup initial views to show user email
        // (https://stackoverflow.com/questions/51346492/ios-firauth-is-there-any-way-to-get-user-email-from-user-uid)
        let user = authController?.currentUser
        
        if let user = user {
            emailLabel.text = user.email
        }
    }
    
    @IBAction func onSignOut(_ sender: Any) {
        databaseController?.signOutUser()
        
        authStateListener = authController?.addStateDidChangeListener { auth, user in
            // Check if user is nil to determine whether user is signed in or not
            if user == nil {
                // User is signed out, navigate to login screen
                self.performSegue(withIdentifier: "logOutSegue", sender: self)
            }
        }
    }
    
    // remove authentication listener after view disappears
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
