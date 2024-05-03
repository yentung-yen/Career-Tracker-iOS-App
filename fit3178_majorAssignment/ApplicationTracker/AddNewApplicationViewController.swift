//
//  AddNewApplicationViewController.swift
//  fit3178_majorAssignment
//
//  Created by Chin Yen Tung on 1/5/2024.
//

import UIKit

class AddNewApplicationViewController: UIViewController {

    @IBOutlet weak var jobTitleTextField: UITextField!
    @IBOutlet weak var companyTextField: UITextField!
    @IBOutlet weak var jobLocationTextField: UITextField!
    @IBOutlet weak var jobModeSegmentControl: UISegmentedControl!
    @IBOutlet weak var salaryTextField: UITextField!
    @IBOutlet weak var jobPostURLTextField: UITextField!
    @IBOutlet weak var applicationStatusSegmentControl: UISegmentedControl!
    @IBOutlet weak var notesTextField: UITextField!
    
    weak var databaseController: DatabaseProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
    }
    
    @IBAction func onAddApplication(_ sender: Any) {
        var errorMsg = ""
        
        // validate the user input
        guard let jobTitle = jobTitleTextField.text,
              let company = companyTextField.text,
              let jobLocation = jobLocationTextField.text,
              let jobMode = JobMode(rawValue: Int(jobModeSegmentControl.selectedSegmentIndex ?? 0)), // default to 0 (not changing option)
              let salary = salaryTextField.text,
              let jobPostURL = jobPostURLTextField.text,
              let applicationStatus = ApplicationStatus(rawValue: Int(applicationStatusSegmentControl.selectedSegmentIndex ?? 0)),
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
        
        let _ = databaseController?.addApplication(jobTitle: jobTitle, 
                                                   company: company,
                                                   jobLocation: jobLocation,
                                                   jobMode: jobMode,
                                                   salary: Double(salary) ?? 0,
                                                   postURL: jobPostURL,
                                                   applicationStatus: applicationStatus,
                                                   notes: notes)
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
