//
//  EditApplicationDetailsViewController.swift
//  fit3178_majorAssignment
//
//  Created by Chin Yen Tung on 2/5/2024.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class EditApplicationDetailsViewController: UIViewController {
    var currentApplicationDetails: ApplicationDetail?
    var jobMode: Int32?
    var applicationStatus: Int32?
    
    // initialise firestore database and authentication
    var db: Firestore = Firestore.firestore()
    var authController: Auth = Auth.auth()
    
    @IBOutlet weak var jobTitleTextField: UITextField!
    @IBOutlet weak var companyTextField: UITextField!
    @IBOutlet weak var jobLocationTextField: UITextField!
    @IBOutlet weak var jobModeSegment: UISegmentedControl!
    @IBOutlet weak var salaryTextField: UITextField!
    @IBOutlet weak var postURLTextField: UITextField!
    @IBOutlet weak var applicationStatusSegment: UISegmentedControl!
    @IBOutlet weak var notesTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        jobTitleTextField.text = currentApplicationDetails?.jobTitle
        companyTextField.text = currentApplicationDetails?.company
        jobLocationTextField.text = currentApplicationDetails?.jobLocation
        jobModeSegment.selectedSegmentIndex = Int(currentApplicationDetails!.jobMode!)
        salaryTextField.text = String(format: "%.2f", currentApplicationDetails?.salary ?? 0)
        postURLTextField.text = currentApplicationDetails?.postURL
        applicationStatusSegment.selectedSegmentIndex = Int(currentApplicationDetails!.applicationStatus!)
        notesTextField.text = currentApplicationDetails?.notes
    }
    
    @IBAction func onSaveChanges(_ sender: Any) {
        var errorMsg = ""
        
        // validate the user input
        guard let jobTitle = jobTitleTextField.text,
              let company = companyTextField.text,
              let jobLocation = jobLocationTextField.text,
              let _ = JobMode(rawValue: Int(jobModeSegment.selectedSegmentIndex)),
              let jobPostURL = postURLTextField.text,
              let _ = ApplicationStatus(rawValue: Int(applicationStatusSegment.selectedSegmentIndex)),
              let notes = notesTextField.text else {
            return
        }
        
        if jobTitle.isEmpty || company.isEmpty || jobLocation.isEmpty {
            errorMsg = "Ensure these fields are filled:\n"
            
            if jobTitle.isEmpty {
                errorMsg += "- Job Title must be provided\n"
            }
            if company.isEmpty {
                errorMsg += "- Company must be provided\n"
            }
            if jobLocation.isEmpty {
                errorMsg += "- Job location must be provided\n"
            }
            displayMessage(title: "Missing Fields", message: errorMsg)
            return
        }
        
        // validate that salary must be empty (i.e. not required) or a valid number
        if let salaryText = salaryTextField.text, !salaryText.isEmpty { // is salary not empty, check that its numeric
            guard Double(salaryText) != nil else {
                displayMessage(title: "Invalid Input", message: "Salary must be a numeric value.")
                return
            }
        } else { // salary is empty
            let salaryText = 0
        }
        
        // get id of current job application in firebase
        let documentId = currentApplicationDetails?.id
        
        // get database of current user
        let currentUserUID = authController.currentUser?.uid
//        print(currentUserUID!)
        let userDb = db.collection("users").document(currentUserUID!)
        
        // get updated data from UI, edit the document in firebase, and save it
        userDb.collection("applicationDetail").document(documentId!).updateData([
            "applicationStatus": Int(applicationStatusSegment.selectedSegmentIndex),
            "company": company,
            "jobLocation": jobLocation,
            "jobMode": Int(jobModeSegment.selectedSegmentIndex),
            "jobTitle": jobTitle,
            "notes": notes,
            "postURL": jobPostURL,
            "salary": Double(salaryTextField.text!) ?? 0
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated")
            }
        }
        
        // navigate back to previous screen
        navigationController?.popViewController(animated: true)
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
