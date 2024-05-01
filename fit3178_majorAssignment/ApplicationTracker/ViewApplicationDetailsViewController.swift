//
//  ViewApplicationDetailsViewController.swift
//  fit3178_majorAssignment
//
//  Created by Chin Yen Tung on 2/5/2024.
//

import UIKit

class ViewApplicationDetailsViewController: UIViewController {
    var currentApplicationDetails: ApplicationDetails?
    var jobMode: String?
    var applicationStatus: String?
    
    @IBOutlet weak var jobTitleLabel: UILabel!
    @IBOutlet weak var companyLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var jobModeButton: UIButton!
    @IBOutlet weak var salaryLabel: UILabel!
    @IBOutlet weak var postURLLabel: UILabel!
    @IBOutlet weak var applicationStatusButton: UIButton!
    @IBOutlet weak var notesTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // get job mode
        if currentApplicationDetails?.jobMode == 0 {
            jobMode = "Hybrid"
        } else if currentApplicationDetails?.jobMode == 1 {
            jobMode = "In-Person"
        } else if currentApplicationDetails?.jobMode == 2 {
            jobMode = "Online"
        }
        
        // get application status
        if currentApplicationDetails?.applicationStatus == 0 {
            applicationStatus = "Applied"
        } else if currentApplicationDetails?.applicationStatus == 1 {
            applicationStatus = "Online Assessment"
        } else if currentApplicationDetails?.applicationStatus == 2 {
            applicationStatus = "Interview"
        } else if currentApplicationDetails?.applicationStatus == 3 {
            applicationStatus = "Offered"
        }
        
        jobTitleLabel.text = currentApplicationDetails?.jobTitle
        companyLabel.text = currentApplicationDetails?.company
        locationLabel.text = currentApplicationDetails?.jobLocation
        jobModeButton.setTitle(jobMode, for: .normal)
        salaryLabel.text = "$" + String(format: "%.2f", currentApplicationDetails?.salary ?? 0)
        postURLLabel.text = currentApplicationDetails?.postURL
        applicationStatusButton.setTitle(applicationStatus, for: .normal)
        notesTextView.text = currentApplicationDetails?.notes
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "viewToEditApplicationSegue" {
            if let destinationVC = segue.destination as? EditApplicationDetailsViewController {
                destinationVC.currentApplicationDetails = currentApplicationDetails
            }
        }
    }
    

}
