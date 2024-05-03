//
//  EditApplicationDetailsViewController.swift
//  fit3178_majorAssignment
//
//  Created by Chin Yen Tung on 2/5/2024.
//

import UIKit

class EditApplicationDetailsViewController: UIViewController {
    var currentApplicationDetails: ApplicationDetail?
    var jobMode: Int32?
    var applicationStatus: Int32?
    
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
        jobModeSegment.selectedSegmentIndex = Int(currentApplicationDetails!.jobMode)
        salaryTextField.text = String(format: "%.2f", currentApplicationDetails?.salary ?? 0)
        postURLTextField.text = currentApplicationDetails?.postURL
        applicationStatusSegment.selectedSegmentIndex = Int(currentApplicationDetails!.applicationStatus)
        notesTextField.text = currentApplicationDetails?.notes
    }
    
    @IBAction func onSaveChanges(_ sender: Any) {
        
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
