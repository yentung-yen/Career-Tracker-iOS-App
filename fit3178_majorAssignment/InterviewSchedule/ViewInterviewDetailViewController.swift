//
//  ViewInterviewDetailViewController.swift
//  jobApplication_prepTrack_app
//
//  Created by Chin Yen Tung on 8/6/2024.
//

import UIKit

class ViewInterviewDetailViewController: UIViewController {
    let DATE_FORMATTER = DateFormatter()
    let DATE_FORMATTER_TIME = DateFormatter()
    
    var currentInterviewDetails: InterviewScheduleDetail?
    weak var databaseController: DatabaseProtocol?
    
    @IBOutlet weak var interviewTitleLabel: UILabel!
    @IBOutlet weak var interviewDayDateLabel: UILabel!
    @IBOutlet weak var interviewTimeLabel: UILabel!
    @IBOutlet weak var videoConferencingTextView: UITextView!
    @IBOutlet weak var locationTextView: UITextView!
    @IBOutlet weak var interviewNotifTextView: UITextView!
    @IBOutlet weak var interviewNotesTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        DATE_FORMATTER.dateFormat = "EEEE, dd-MMM-yyyy"
        DATE_FORMATTER_TIME.dateFormat = "h:mm a"
        
        let startTime = DATE_FORMATTER_TIME.string(from: (currentInterviewDetails?.interviewStartDatetime)!)
        let endTime = DATE_FORMATTER_TIME.string(from: (currentInterviewDetails?.interviewEndDatetime)!)
        let interviewTimeLabelContent = "\(startTime) - \(endTime)"
        
        interviewTitleLabel.text = currentInterviewDetails?.interviewTitle
        interviewDayDateLabel.text = DATE_FORMATTER.string(from: (currentInterviewDetails?.interviewStartDatetime)!)
        interviewTimeLabel.text = interviewTimeLabelContent
        videoConferencingTextView.text = currentInterviewDetails?.interviewVideoLink
        locationTextView.text = currentInterviewDetails?.interviewLocation
        interviewNotifTextView.text = DATE_FORMATTER.string(from: (currentInterviewDetails?.interviewNotifDatetime)!)
        interviewNotesTextView.text = currentInterviewDetails?.interviewNotes
    }
    
    @IBAction func onDeleteInterviewClick(_ sender: Any) {
        guard let delInterview = currentInterviewDetails else { return }

        // get the managed object context
        let context = databaseController?.persistentContainer.viewContext
        context?.delete(delInterview)   // delete interview

        // save context to make the deletion permanent
        do {
            try context?.save()
        } catch {
            print("Failed to save context: \(error)")
        }
        
        // return back to main screen
        navigationController?.popViewController(animated: true)
        navigationController?.popViewController(animated: true)
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "viewToEditInterviewSegue" {
            if let destinationVC = segue.destination as? EditInterviewDetailViewController {
                
                destinationVC.currentInterviewDetails = currentInterviewDetails
            }
        }
    }
    

}
