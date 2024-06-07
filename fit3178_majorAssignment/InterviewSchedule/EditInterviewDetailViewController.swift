//
//  EditInterviewDetailViewController.swift
//  jobApplication_prepTrack_app
//
//  Created by Chin Yen Tung on 8/6/2024.
//

import UIKit
import CoreData

class EditInterviewDetailViewController: UIViewController {
    var currentInterviewDetails: InterviewScheduleDetail?
    
    var objectID: NSManagedObjectID?
    var managedObjectContext: NSManagedObjectContext?
    weak var databaseController: DatabaseProtocol?

    @IBOutlet weak var interviewTextField: UITextField!
    @IBOutlet weak var interviewStartDatePicker: UIDatePicker!
    @IBOutlet weak var interviewEndDatePicker: UIDatePicker!
    @IBOutlet weak var interviewVidConference: UITextField!
    @IBOutlet weak var interviewLocation: UITextField!
    @IBOutlet weak var interviewNotifDatePicker: UIDatePicker!
    @IBOutlet weak var interviewNotes: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.firebaseDatabaseController
        managedObjectContext = databaseController?.persistentContainer.viewContext
        objectID = currentInterviewDetails?.objectID
        
        // set initial data onto UI
        interviewTextField.text = currentInterviewDetails?.interviewTitle
        interviewStartDatePicker.date = (currentInterviewDetails?.interviewStartDatetime)!
        interviewEndDatePicker.date = (currentInterviewDetails?.interviewEndDatetime)!
        interviewVidConference.text = currentInterviewDetails?.interviewVideoLink
        interviewLocation.text = currentInterviewDetails?.interviewLocation
        interviewNotifDatePicker.date = (currentInterviewDetails?.interviewNotifDatetime)!
        interviewNotes.text = currentInterviewDetails?.interviewNotes
    }
    
    @IBAction func onSaveChangesClick(_ sender: Any) {
        // create new InterviewScheduleDetail object with the same objectID as the one we want to edit
        if let object = managedObjectContext?.object(with: objectID!) as? InterviewScheduleDetail {
            object.interviewTitle = interviewTextField.text
            object.interviewStartDatetime = interviewStartDatePicker.date
            object.interviewEndDatetime = interviewEndDatePicker.date
            object.interviewVideoLink = interviewVidConference.text
            object.interviewLocation = interviewLocation.text
            object.interviewNotifDatetime =  interviewNotifDatePicker.date
            object.interviewNotes = interviewNotes.text
        }
        
        // save the context
        do {
            try managedObjectContext?.save()
            
            // TODO: reload data in viewDataVC instead of move to main screen
            // move to main interview schedule screen
            navigationController?.popViewController(animated: true)
            navigationController?.popViewController(animated: true)
            navigationController?.popViewController(animated: true)
        } catch {
            print("Failed to save context: \(error)")
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
